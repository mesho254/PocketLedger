package com.pocketledger.auth.dto;

import java.time.LocalDateTime;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {
  private UUID id;
  private String email;
  private String fullName;
  private String currency;
  private LocalDateTime createdAt;
  private String token;
}
