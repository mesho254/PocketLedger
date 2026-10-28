package com.pocketledger.savings.repository;

import com.pocketledger.auth.model.User;
import com.pocketledger.savings.entity.SavingsGoal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SavingsGoalRepository extends JpaRepository<SavingsGoal, UUID> {
  List<SavingsGoal> findByUserOrderByCreatedAtDesc(User user);

  Optional<SavingsGoal> findByIdAndUser(UUID id, User user);
}
