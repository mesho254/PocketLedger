package com.pocketledger.auth.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pocketledger.auth.dto.AuthResponse;
import com.pocketledger.auth.dto.LoginRequest;
import com.pocketledger.auth.dto.RegisterRequest;
import com.pocketledger.auth.exception.BadRequestException;
import com.pocketledger.auth.model.User;
import com.pocketledger.auth.repository.UserRepository;
import com.pocketledger.auth.security.JwtService;
import com.pocketledger.auth.security.UserPrincipal;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

  @Mock
  private UserRepository userRepository;

  @Mock
  private PasswordEncoder passwordEncoder;

  @Mock
  private JwtService jwtService;

  @Mock
  private AuthenticationManager authenticationManager;

  private AuthServiceImpl authService;

  private User sampleUser;

  @BeforeEach
  void setUp() {
    authService = new AuthServiceImpl(userRepository, passwordEncoder, jwtService, authenticationManager);
    sampleUser = User.builder()
        .id(UUID.randomUUID())
        .email("test@pocketledger.com")
        .passwordHash("hashed_password")
        .fullName("Jane Doe")
        .currency("USD")
        .build();
  }

  @Test
  @DisplayName("Should successfully register a new user")
  void testRegisterSuccess() {
    RegisterRequest request = RegisterRequest.builder()
        .email("test@pocketledger.com")
        .password("secret123")
        .fullName("Jane Doe")
        .currency("USD")
        .build();

    when(userRepository.existsByEmail("test@pocketledger.com")).thenReturn(false);
    when(passwordEncoder.encode("secret123")).thenReturn("hashed_password");
    when(userRepository.save(any(User.class))).thenReturn(sampleUser);
    when(jwtService.generateToken(any(UserPrincipal.class))).thenReturn("mock-jwt-token");

    AuthResponse response = authService.register(request);

    assertThat(response).isNotNull();
    assertThat(response.getToken()).isEqualTo("mock-jwt-token");
    assertThat(response.getEmail()).isEqualTo("test@pocketledger.com");
    assertThat(response.getFullName()).isEqualTo("Jane Doe");

    verify(userRepository, times(1)).save(any(User.class));
  }

  @Test
  @DisplayName("Should throw BadRequestException when email is already registered")
  void testRegisterDuplicateEmail() {
    RegisterRequest request = RegisterRequest.builder()
        .email("test@pocketledger.com")
        .password("secret123")
        .fullName("Jane Doe")
        .build();

    when(userRepository.existsByEmail("test@pocketledger.com")).thenReturn(true);

    assertThatThrownBy(() -> authService.register(request))
        .isInstanceOf(BadRequestException.class)
        .hasMessageContaining("already exists");

    verify(userRepository, never()).save(any(User.class));
  }

  @Test
  @DisplayName("Should authenticate and return JWT on valid login")
  void testLoginSuccess() {
    LoginRequest request = LoginRequest.builder().email("test@pocketledger.com").password("secret123").build();

    UserPrincipal principal = UserPrincipal.create(sampleUser);
    Authentication authentication = mock(Authentication.class);
    when(authentication.getPrincipal()).thenReturn(principal);

    when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
        .thenReturn(authentication);
    when(jwtService.generateToken(principal)).thenReturn("valid-jwt-token");
    when(userRepository.findByEmail("test@pocketledger.com")).thenReturn(Optional.of(sampleUser));

    AuthResponse response = authService.login(request);

    assertThat(response).isNotNull();
    assertThat(response.getToken()).isEqualTo("valid-jwt-token");
    assertThat(response.getEmail()).isEqualTo("test@pocketledger.com");
  }
}
