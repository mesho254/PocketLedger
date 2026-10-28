package com.pocketledger.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateProfileRequest {

  @NotBlank(message = "Full name is required")
  @Size(min = 2, max = 100, message = "Full name must be between 2 and 100 characters")
  private String fullName;

  @Email(message = "Please provide a valid email address")
  private String email;

  @Size(min = 3, max = 10, message = "Currency code must be between 3 and 10 characters")
  private String currency;
}
