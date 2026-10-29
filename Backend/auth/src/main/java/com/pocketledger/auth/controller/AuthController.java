package com.pocketledger.auth.controller;

import com.pocketledger.auth.dto.AuthResponse;
import com.pocketledger.auth.dto.ChangePasswordRequest;
import com.pocketledger.auth.dto.LoginRequest;
import com.pocketledger.auth.dto.RefreshRequest;
import com.pocketledger.auth.dto.RegisterRequest;
import com.pocketledger.auth.dto.UpdateProfileRequest;
import com.pocketledger.auth.dto.UserProfileResponse;
import com.pocketledger.auth.security.UserPrincipal;
import com.pocketledger.auth.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping({ "/api/v1/auth", "/api/auth" })
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Endpoints for user registration, login, and profile")
public class AuthController {

  private final AuthService authService;

  @PostMapping("/register")
  @Operation(summary = "Register a new user account")
  public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
    AuthResponse response = authService.register(request);
    return new ResponseEntity<>(response, HttpStatus.CREATED);
  }

  @PostMapping("/login")
  @Operation(summary = "Authenticate user and generate JWT token")
  public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
    AuthResponse response = authService.login(request);
    return ResponseEntity.ok(response);
  }

  @PostMapping("/refresh")
  @Operation(summary = "Refresh JWT access token using refresh token")
  public ResponseEntity<AuthResponse> refresh(@Valid @RequestBody RefreshRequest request) {
    return ResponseEntity.ok(authService.refresh(request.getRefreshToken()));
  }

  @PostMapping("/logout")
  @Operation(summary = "Revoke refresh token and blacklist active JWT access token")
  public ResponseEntity<Void> logout(
      @RequestHeader(value = "Authorization", required = false) String authHeader,
      @RequestBody(required = false) RefreshRequest request) {
    String accessToken =
        (authHeader != null && authHeader.startsWith("Bearer "))
            ? authHeader.substring(7)
            : null;
    String refreshToken = request != null ? request.getRefreshToken() : null;
    if (accessToken != null) {
      authService.logout(accessToken, refreshToken);
    } else if (refreshToken != null && !refreshToken.isBlank()) {
      authService.logout(refreshToken);
    }
    return ResponseEntity.noContent().build();
  }

  @PostMapping("/change-password")
  @Operation(summary = "Change authenticated user password")
  public ResponseEntity<Map<String, String>> changePassword(
      @AuthenticationPrincipal UserPrincipal principal,
      @Valid @RequestBody ChangePasswordRequest request) {
    authService.changePassword(
        principal.getId(), request.getCurrentPassword(), request.getNewPassword());
    return ResponseEntity.ok(Map.of("message", "Password changed successfully"));
  }

  @GetMapping("/me")
  @Operation(summary = "Get currently authenticated user profile")
  public ResponseEntity<UserProfileResponse> getCurrentUser(
      @AuthenticationPrincipal UserPrincipal principal) {
    UserProfileResponse response = authService.getCurrentUser(principal);
    return ResponseEntity.ok(response);
  }

  @PutMapping({ "/me", "/profile" })
  @Operation(summary = "Update currently authenticated user profile and currency")
  public ResponseEntity<UserProfileResponse> updateProfile(
      @AuthenticationPrincipal UserPrincipal principal,
      @Valid @RequestBody UpdateProfileRequest request) {
    UserProfileResponse response = authService.updateProfile(principal, request);
    return ResponseEntity.ok(response);
  }
}
