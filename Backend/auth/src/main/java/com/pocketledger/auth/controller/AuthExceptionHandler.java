package com.pocketledger.auth.controller;

import com.pocketledger.auth.exception.BadRequestException;
import com.pocketledger.auth.exception.ResourceNotFoundException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice(basePackages = "com.pocketledger.auth")
public class AuthExceptionHandler {

  @ExceptionHandler(ResourceNotFoundException.class)
  public ResponseEntity<Map<String, Object>> handleNotFound(ResourceNotFoundException ex) {
    log.warn("Auth API not found: {}", ex.getMessage());
    return buildErrorResponse(HttpStatus.NOT_FOUND, ex.getMessage(), null);
  }

  @ExceptionHandler(BadRequestException.class)
  public ResponseEntity<Map<String, Object>> handleBadRequest(BadRequestException ex) {
    log.warn("Auth API bad request: {}", ex.getMessage());
    return buildErrorResponse(HttpStatus.BAD_REQUEST, ex.getMessage(), null);
  }

  @ExceptionHandler(BadCredentialsException.class)
  public ResponseEntity<Map<String, Object>> handleBadCredentials(BadCredentialsException ex) {
    log.warn("Auth API invalid credentials");
    return buildErrorResponse(HttpStatus.UNAUTHORIZED, "Invalid email or password", null);
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ResponseEntity<Map<String, Object>> handleValidationExceptions(
      MethodArgumentNotValidException ex) {
    Map<String, String> fieldErrors = new HashMap<>();
    for (FieldError error : ex.getBindingResult().getFieldErrors()) {
      fieldErrors.put(error.getField(), error.getDefaultMessage());
    }
    return buildErrorResponse(HttpStatus.BAD_REQUEST, "Validation failed", fieldErrors);
  }

  @ExceptionHandler(RuntimeException.class)
  public ResponseEntity<Map<String, Object>> handleRuntime(RuntimeException ex) {
    log.warn("Auth API error: {}", ex.getMessage());
    HttpStatus status = ex.getMessage() != null && ex.getMessage().toLowerCase().contains("not found")
        ? HttpStatus.NOT_FOUND
        : HttpStatus.BAD_REQUEST;
    return buildErrorResponse(status, ex.getMessage(), null);
  }

  private ResponseEntity<Map<String, Object>> buildErrorResponse(
      HttpStatus status, String message, Object details) {
    Map<String, Object> body = new HashMap<>();
    body.put("timestamp", LocalDateTime.now());
    body.put("status", status.value());
    body.put("error", status.getReasonPhrase());
    body.put("message", message);
    if (details != null) {
      body.put("details", details);
    }
    return new ResponseEntity<>(body, status);
  }
}
