package com.pocketledger.repository;

import com.pocketledger.model.SavingsGoal;
import com.pocketledger.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SavingsGoalRepository extends JpaRepository<SavingsGoal, UUID> {
    List<SavingsGoal> findByUserOrderByCreatedAtDesc(User user);
    Optional<SavingsGoal> findByIdAndUser(UUID id, User user);
}
