package com.pocketledger.auth.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Deque;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedDeque;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class RateLimitingFilter extends OncePerRequestFilter {

  private static final long WINDOW_MS = 60_000L;
  private static final int MAX_AUTH_REQUESTS_PER_MINUTE = 10;
  private static final int MAX_API_REQUESTS_PER_MINUTE = 120;

  private final Map<String, Deque<Long>> requestWindows = new ConcurrentHashMap<>();

  @Override
  protected void doFilterInternal(
      @NonNull HttpServletRequest request,
      @NonNull HttpServletResponse response,
      @NonNull FilterChain filterChain)
      throws ServletException, IOException {

    String uri = request.getRequestURI();
    if (uri.endsWith("/health") || uri.equals("/")) {
      filterChain.doFilter(request, response);
      return;
    }

    boolean isSensitiveAuthEndpoint = uri.contains("/auth/login")
        || uri.contains("/auth/register")
        || uri.contains("/auth/change-password");

    int limit = isSensitiveAuthEndpoint
        ? MAX_AUTH_REQUESTS_PER_MINUTE
        : MAX_API_REQUESTS_PER_MINUTE;
    String bucketKey = (isSensitiveAuthEndpoint ? "AUTH:" : "API:") + resolveClientIp(request);

    long now = System.currentTimeMillis();
    Deque<Long> timestamps = requestWindows.computeIfAbsent(
        bucketKey, k -> new ConcurrentLinkedDeque<>());

    synchronized (timestamps) {
      while (!timestamps.isEmpty() && now - timestamps.peekFirst() > WINDOW_MS) {
        timestamps.pollFirst();
      }
      if (timestamps.size() >= limit) {
        response.setStatus(429);
        response.setContentType("application/json");
        response.setHeader("Retry-After", "60");
        response
            .getWriter()
            .write(
                "{\"status\":429,\"error\":\"Too Many Requests\",\"message\":\"Too many requests. Please wait a minute before trying again.\"}");
        return;
      }
      timestamps.addLast(now);
    }

    filterChain.doFilter(request, response);
  }

  private String resolveClientIp(HttpServletRequest request) {
    String forwarded = request.getHeader("X-Forwarded-For");
    if (forwarded != null && !forwarded.isBlank()) {
      int commaIdx = forwarded.indexOf(',');
      return (commaIdx > 0 ? forwarded.substring(0, commaIdx) : forwarded).trim();
    }
    return request.getRemoteAddr() != null ? request.getRemoteAddr() : "unknown";
  }
}
