package com.pocketledger.service;

import com.pocketledger.dto.AuthResponse;
import com.pocketledger.dto.LoginRequest;
import com.pocketledger.dto.RegisterRequest;
import com.pocketledger.exception.BadRequestException;
import com.pocketledger.model.User;
import com.pocketledger.repository.UserRepository;
import com.pocketledger.security.JwtService;
import com.pocketledger.security.UserPrincipal;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

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

    @InjectMocks
    private AuthService authService;

    private User sampleUser;

    @BeforeEach
    void setUp() {
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
        LoginRequest request = LoginRequest.builder()
            .email("test@pocketledger.com")
            .password("secret123")
            .build();

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
