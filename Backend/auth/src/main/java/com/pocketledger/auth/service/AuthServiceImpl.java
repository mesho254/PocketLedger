package com.pocketledger.auth.service;

import com.pocketledger.auth.dto.AuthResponse;
import com.pocketledger.auth.dto.LoginRequest;
import com.pocketledger.auth.dto.RegisterRequest;
import com.pocketledger.auth.dto.UpdateProfileRequest;
import com.pocketledger.auth.dto.UserProfileResponse;
import com.pocketledger.auth.enums.Role;
import com.pocketledger.auth.exception.BadRequestException;
import com.pocketledger.auth.exception.ResourceNotFoundException;
import com.pocketledger.auth.model.RefreshToken;
import com.pocketledger.auth.model.User;
import com.pocketledger.auth.repository.RefreshTokenRepository;
import com.pocketledger.auth.repository.UserRepository;
import com.pocketledger.auth.security.JwtService;
import com.pocketledger.auth.security.UserPrincipal;
import java.time.Instant;
import java.util.UUID;
import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthServiceImpl implements AuthService {

  private final UserRepository userRepository;
  private final PasswordEncoder passwordEncoder;
  private final JwtService jwtService;
  private final AuthenticationManager authenticationManager;
  private final RefreshTokenRepository refreshTokenRepository;
  private final TokenBlacklistService tokenBlacklistService;

  @Autowired
  public AuthServiceImpl(
      UserRepository userRepository,
      PasswordEncoder passwordEncoder,
      JwtService jwtService,
      AuthenticationManager authenticationManager,
      RefreshTokenRepository refreshTokenRepository,
      TokenBlacklistService tokenBlacklistService) {
    this.userRepository = userRepository;
    this.passwordEncoder = passwordEncoder;
    this.jwtService = jwtService;
    this.authenticationManager = authenticationManager;
    this.refreshTokenRepository = refreshTokenRepository;
    this.tokenBlacklistService = tokenBlacklistService;
  }

  public AuthServiceImpl(
      UserRepository userRepository,
      PasswordEncoder passwordEncoder,
      JwtService jwtService,
      AuthenticationManager authenticationManager) {
    this(userRepository, passwordEncoder, jwtService, authenticationManager, null, null);
  }

  @Override
  @Transactional
  public AuthResponse register(RegisterRequest request) {
    String cleanEmail = request.getEmail().toLowerCase().trim();
    if (userRepository.existsByEmail(cleanEmail)) {
      throw new BadRequestException("An account with this email already exists: " + cleanEmail);
    }

    User user = User.builder()
        .email(cleanEmail)
        .passwordHash(passwordEncoder.encode(request.getPassword()))
        .fullName(request.getFullName().trim())
        .currency(
            request.getCurrency() != null && !request.getCurrency().isBlank()
                ? request.getCurrency().toUpperCase().trim()
                : "USD")
        .role(Role.USER)
        .build();

    User savedUser = userRepository.save(user);
    UserPrincipal userPrincipal = UserPrincipal.create(savedUser);
    String token = jwtService.generateToken(userPrincipal);
    String refreshToken = savedUser.getId() != null
        ? jwtService.generateRefreshToken(savedUser.getId().toString())
        : null;
    if (refreshToken != null && refreshTokenRepository != null) {
      saveNewRefreshToken(savedUser, refreshToken);
    }

    return AuthResponse.builder()
        .token(token)
        .refreshToken(refreshToken)
        .userId(savedUser.getId())
        .email(savedUser.getEmail())
        .fullName(savedUser.getFullName())
        .currency(savedUser.getCurrency())
        .build();
  }

  @Override
  @Transactional
  public AuthResponse login(LoginRequest request) {
    Authentication authentication = authenticationManager.authenticate(
        new UsernamePasswordAuthenticationToken(
            request.getEmail().toLowerCase().trim(), request.getPassword()));

    UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
    String token = jwtService.generateToken(userPrincipal);

    User user = userRepository
        .findByEmail(userPrincipal.getEmail())
        .orElseThrow(() -> new ResourceNotFoundException("User not found"));

    String refreshToken = user.getId() != null ? jwtService.generateRefreshToken(user.getId().toString()) : null;
    if (refreshToken != null && refreshTokenRepository != null) {
      saveNewRefreshToken(user, refreshToken);
    }

    return AuthResponse.builder()
        .token(token)
        .refreshToken(refreshToken)
        .userId(user.getId())
        .email(user.getEmail())
        .fullName(user.getFullName())
        .currency(user.getCurrency())
        .build();
  }

  @Override
  @Transactional
  public AuthResponse refresh(String refreshToken) {
    if (refreshTokenRepository == null) {
      throw new BadRequestException("Refresh token repository not configured");
    }
    String tokenHash = hash(refreshToken);
    RefreshToken stored = refreshTokenRepository
        .findByTokenHash(tokenHash)
        .orElseThrow(() -> new BadRequestException("Invalid refresh token"));

    if (stored.isRevoked() || stored.getExpiryDate().isBefore(Instant.now())) {
      throw new BadRequestException("Refresh token expired");
    }

    stored.setRevoked(true);
    refreshTokenRepository.save(stored);

    User user = stored.getUser();
    UserPrincipal principal = UserPrincipal.create(user);
    String newAccessToken = jwtService.generateToken(principal);
    String newRefreshToken = jwtService.generateRefreshToken(user.getId().toString());
    saveNewRefreshToken(user, newRefreshToken);

    return AuthResponse.builder()
        .token(newAccessToken)
        .refreshToken(newRefreshToken)
        .userId(user.getId())
        .email(user.getEmail())
        .fullName(user.getFullName())
        .currency(user.getCurrency())
        .build();
  }

  @Override
  @Transactional
  public void logout(String refreshToken) {
    if (tokenBlacklistService != null && refreshToken != null && !refreshToken.isBlank()) {
      long expiry = jwtService.getRemainingValidity(refreshToken);
      tokenBlacklistService.blacklist(refreshToken, expiry);
    }
    if (refreshTokenRepository != null && refreshToken != null && !refreshToken.isBlank()) {
      String tokenHash = hash(refreshToken);
      RefreshToken stored = refreshTokenRepository
          .findByTokenHash(tokenHash)
          .orElseThrow(() -> new BadRequestException("Invalid refresh token"));
      stored.setRevoked(true);
      refreshTokenRepository.save(stored);
    }
  }

  @Override
  @Transactional
  public void logout(String accessToken, String refreshToken) {
    if (tokenBlacklistService != null && accessToken != null && !accessToken.isBlank()) {
      long expiry = jwtService.getRemainingValidity(accessToken);
      if (expiry > 0) {
        tokenBlacklistService.blacklist(accessToken, expiry);
      }
    }
    if (refreshToken != null && !refreshToken.isBlank()) {
      if (tokenBlacklistService != null) {
        long refreshExpiry = jwtService.getRemainingValidity(refreshToken);
        if (refreshExpiry > 0) {
          tokenBlacklistService.blacklist(refreshToken, refreshExpiry);
        }
      }
      if (refreshTokenRepository != null) {
        String tokenHash = hash(refreshToken);
        refreshTokenRepository
            .findByTokenHash(tokenHash)
            .ifPresent(
                stored -> {
                  stored.setRevoked(true);
                  refreshTokenRepository.save(stored);
                });
      }
    }
  }

  @Override
  @Transactional
  public void changePassword(UUID userId, String currentPassword, String newPassword) {
    User user = userRepository
        .findById(userId)
        .orElseThrow(() -> new ResourceNotFoundException("User not found"));

    if (currentPassword != null && !currentPassword.isEmpty()) {
      if (!passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
        throw new BadRequestException("Current password is incorrect");
      }
    }

    if (newPassword == null || newPassword.length() < 6) {
      throw new BadRequestException("New password must be at least 6 characters long");
    }

    user.setPasswordHash(passwordEncoder.encode(newPassword));
    userRepository.save(user);
    if (refreshTokenRepository != null) {
      refreshTokenRepository.revokeAllByUserId(userId);
    }
  }

  @Override
  @Transactional(readOnly = true)
  public UserProfileResponse getCurrentUser(UserPrincipal userPrincipal) {
    User user = getUserEntity(userPrincipal);
    return UserProfileResponse.builder()
        .id(user.getId())
        .email(user.getEmail())
        .fullName(user.getFullName())
        .currency(user.getCurrency())
        .createdAt(user.getCreatedAt())
        .build();
  }

  @Override
  @Transactional
  public UserProfileResponse updateProfile(
      UserPrincipal userPrincipal, UpdateProfileRequest request) {
    User user = getUserEntity(userPrincipal);

    if (request.getFullName() != null && !request.getFullName().isBlank()) {
      user.setFullName(request.getFullName().trim());
    }

    if (request.getEmail() != null && !request.getEmail().isBlank()) {
      String cleanEmail = request.getEmail().toLowerCase().trim();
      if (!cleanEmail.equalsIgnoreCase(user.getEmail())) {
        if (userRepository.existsByEmail(cleanEmail)) {
          throw new BadRequestException("An account with this email already exists: " + cleanEmail);
        }
        user.setEmail(cleanEmail);
      }
    }

    if (request.getCurrency() != null && !request.getCurrency().isBlank()) {
      user.setCurrency(request.getCurrency().toUpperCase().trim());
    }

    User savedUser = userRepository.save(user);
    UserPrincipal updatedPrincipal = UserPrincipal.create(savedUser);
    String newToken = jwtService.generateToken(updatedPrincipal);

    return UserProfileResponse.builder()
        .id(savedUser.getId())
        .email(savedUser.getEmail())
        .fullName(savedUser.getFullName())
        .currency(savedUser.getCurrency())
        .createdAt(savedUser.getCreatedAt())
        .token(newToken)
        .build();
  }

  @Override
  @Transactional(readOnly = true)
  public User getUserEntity(UserPrincipal userPrincipal) {
    if (userPrincipal == null) {
      throw new ResourceNotFoundException("Authenticated user principal is required");
    }
    return userRepository
        .findById(userPrincipal.getId())
        .orElseThrow(
            () -> new ResourceNotFoundException("User not found with ID: " + userPrincipal.getId()));
  }

  @Override
  public String hash(String token) {
    return DigestUtils.sha256Hex(token);
  }

  private void saveNewRefreshToken(User user, String refreshToken) {
    RefreshToken rt = new RefreshToken();
    rt.setUser(user);
    rt.setTokenHash(hash(refreshToken));
    rt.setExpiryDate(Instant.now().plusSeconds(60L * 60 * 24 * 7)); // 7 days
    rt.setRevoked(false);
    refreshTokenRepository.save(rt);
  }
}
