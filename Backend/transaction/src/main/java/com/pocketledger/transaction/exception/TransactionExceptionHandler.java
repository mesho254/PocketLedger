package com.pocketledger.transaction.exception;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice(basePackages = "com.pocketledger.transaction")
public class TransactionExceptionHandler {

  @ExceptionHandler(TransactionNotFoundException.class)
  public ResponseEntity<Map<String, Object>> handleNotFound(TransactionNotFoundException ex) {
    log.warn("Transaction API not found: {}", ex.getMessage());
    return buildErrorResponse(HttpStatus.NOT_FOUND, ex.getMessage(), null);
  }

  @ExceptionHandler(TransactionValidationException.class)
  public ResponseEntity<Map<String, Object>> handleValidation(TransactionValidationException ex) {
    log.warn("Transaction API bad request: {}", ex.getMessage());
    return buildErrorResponse(HttpStatus.BAD_REQUEST, ex.getMessage(), null);
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ResponseEntity<Map<String, Object>> handleBeanValidation(
      MethodArgumentNotValidException ex) {
    Map<String, String> fieldErrors = new HashMap<>();
    for (FieldError error : ex.getBindingResult().getFieldErrors()) {
      fieldErrors.put(error.getField(), error.getDefaultMessage());
    }
    return buildErrorResponse(HttpStatus.BAD_REQUEST, "Validation failed", fieldErrors);
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
