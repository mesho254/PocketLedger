package com.pocketledger.service;

import com.pocketledger.dto.AuthResponse;
import com.pocketledger.dto.LoginRequest;
import com.pocketledger.dto.RegisterRequest;
import com.pocketledger.dto.UserProfileResponse;
import com.pocketledger.exception.BadRequestException;
import com.pocketledger.exception.ResourceNotFoundException;
import com.pocketledger.model.User;
import com.pocketledger.repository.UserRepository;
import com.pocketledger.security.JwtService;
import com.pocketledger.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("An account with this email already exists: " + request.getEmail());
        }

        User user = User.builder()
            .email(request.getEmail().toLowerCase().trim())
            .passwordHash(passwordEncoder.encode(request.getPassword()))
            .fullName(request.getFullName().trim())
            .currency(request.getCurrency() != null && !request.getCurrency().isBlank() ? request.getCurrency().toUpperCase().trim() : "USD")
            .build();

        User savedUser = userRepository.save(user);
        UserPrincipal userPrincipal = UserPrincipal.create(savedUser);
        String token = jwtService.generateToken(userPrincipal);

        return AuthResponse.builder()
            .token(token)
            .userId(savedUser.getId())
            .email(savedUser.getEmail())
            .fullName(savedUser.getFullName())
            .currency(savedUser.getCurrency())
            .build();
    }

    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(
                request.getEmail().toLowerCase().trim(),
                request.getPassword()
            )
        );

        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        String token = jwtService.generateToken(userPrincipal);

        User user = userRepository.findByEmail(userPrincipal.getEmail())
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        return AuthResponse.builder()
            .token(token)
            .userId(user.getId())
            .email(user.getEmail())
            .fullName(user.getFullName())
            .currency(user.getCurrency())
            .build();
    }

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

    @Transactional(readOnly = true)
    public User getUserEntity(UserPrincipal userPrincipal) {
        return userRepository.findById(userPrincipal.getId())
            .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + userPrincipal.getId()));
    }
}
