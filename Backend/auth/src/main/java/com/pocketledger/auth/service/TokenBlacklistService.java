package com.pocketledger.auth.service;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Service;

@Service
public class TokenBlacklistService {

  private final Map<String, Instant> blacklist = new ConcurrentHashMap<>();

  public void blacklist(String token, long validitySeconds) {
    if (token != null && validitySeconds > 0) {
      blacklist.put(token, Instant.now().plusSeconds(validitySeconds));
    }
  }

  public boolean isBlacklisted(String token) {
    if (token == null) {
      return false;
    }
    Instant expiry = blacklist.get(token);
    if (expiry == null) {
      return false;
    }
    if (Instant.now().isAfter(expiry)) {
      blacklist.remove(token);
      return false;
    }
    return true;
  }
}
