package com.pocketledger.auth.controller;

import com.pocketledger.auth.dto.UserProfileResponse;
import com.pocketledger.auth.security.UserPrincipal;
import com.pocketledger.auth.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping({ "/api/v1/users", "/api/users" })
@RequiredArgsConstructor
@Tag(name = "Users", description = "Endpoints for user profile management")
public class UserController {

  private final AuthService authService;

  @GetMapping("/me")
  @Operation(summary = "Get current authenticated user profile")
  public ResponseEntity<UserProfileResponse> getMyProfile(
      @AuthenticationPrincipal UserPrincipal principal) {
    return ResponseEntity.ok(authService.getCurrentUser(principal));
  }
}
