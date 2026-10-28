package com.pocketledger.auth.controller;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pocketledger.auth.dto.AuthResponse;
import com.pocketledger.auth.dto.LoginRequest;
import com.pocketledger.auth.dto.RegisterRequest;
import com.pocketledger.auth.security.CustomUserDetailsService;
import com.pocketledger.auth.security.JwtService;
import com.pocketledger.auth.service.AuthService;
import com.pocketledger.auth.service.TokenBlacklistService;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(AuthController.class)
@AutoConfigureMockMvc(addFilters = false)
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AuthService authService;

    @MockBean
    private JwtService jwtService;

    @MockBean
    private CustomUserDetailsService userDetailsService;

    @MockBean
    private TokenBlacklistService tokenBlacklistService;

    @Test
    @DisplayName("POST /api/v1/auth/register - Should return 201 on valid registration")
    void testRegisterEndpointSuccess() throws Exception {
        RegisterRequest request = RegisterRequest.builder()
                .email("alex@example.com")
                .password("password123")
                .fullName("Alex Morgan")
                .currency("USD")
                .build();

        AuthResponse authResponse = AuthResponse.builder()
                .token("jwt.token.here")
                .userId(UUID.randomUUID())
                .email("alex@example.com")
                .fullName("Alex Morgan")
                .currency("USD")
                .build();

        when(authService.register(any(RegisterRequest.class))).thenReturn(authResponse);

        mockMvc
                .perform(
                        post("/api/v1/auth/register")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.token").value("jwt.token.here"))
                .andExpect(jsonPath("$.email").value("alex@example.com"))
                .andExpect(jsonPath("$.fullName").value("Alex Morgan"));
    }

    @Test
    @DisplayName("POST /api/v1/auth/register - Should return 400 Bad Request on invalid input")
    void testRegisterValidationFailure() throws Exception {
        RegisterRequest invalidRequest = RegisterRequest.builder().email("not-an-email").password("123").fullName("")
                .build();

        mockMvc
                .perform(
                        post("/api/v1/auth/register")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(invalidRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.message").value("Validation failed"));
    }

    @Test
    @DisplayName("POST /api/v1/auth/login - Should return 200 on valid credentials")
    void testLoginEndpointSuccess() throws Exception {
        LoginRequest request = LoginRequest.builder().email("alex@example.com").password("password123").build();

        AuthResponse authResponse = AuthResponse.builder()
                .token("jwt.token.here")
                .userId(UUID.randomUUID())
                .email("alex@example.com")
                .fullName("Alex Morgan")
                .currency("USD")
                .build();

        when(authService.login(any(LoginRequest.class))).thenReturn(authResponse);

        mockMvc
                .perform(
                        post("/api/v1/auth/login")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").value("jwt.token.here"))
                .andExpect(jsonPath("$.email").value("alex@example.com"));
    }
}
