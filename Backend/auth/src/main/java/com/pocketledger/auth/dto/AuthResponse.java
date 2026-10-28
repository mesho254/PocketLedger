package com.pocketledger.auth.dto;

import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {

  private String token;

  private String refreshToken;

  @Builder.Default
  private String tokenType = "Bearer";

  private UUID userId;
  private String email;
  private String fullName;
  private String currency;
}
