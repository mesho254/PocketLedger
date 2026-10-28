package com.pocketledger.auth.service;

import com.pocketledger.auth.dto.AuthResponse;
import com.pocketledger.auth.dto.LoginRequest;
import com.pocketledger.auth.dto.RegisterRequest;
import com.pocketledger.auth.dto.UpdateProfileRequest;
import com.pocketledger.auth.dto.UserProfileResponse;
import com.pocketledger.auth.model.User;
import com.pocketledger.auth.security.UserPrincipal;
import java.util.UUID;

public interface AuthService {

  AuthResponse register(RegisterRequest request);

  AuthResponse login(LoginRequest request);

  AuthResponse refresh(String refreshToken);

  void logout(String refreshToken);

  void changePassword(UUID userId, String currentPassword, String newPassword);

  UserProfileResponse getCurrentUser(UserPrincipal userPrincipal);

  UserProfileResponse updateProfile(UserPrincipal userPrincipal, UpdateProfileRequest request);

  User getUserEntity(UserPrincipal userPrincipal);

  String hash(String token);
}
