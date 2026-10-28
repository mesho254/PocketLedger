package com.pocketledger.savings.repository;

import com.pocketledger.savings.entity.SavingsContribution;
import com.pocketledger.savings.entity.SavingsGoal;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SavingsContributionRepository extends JpaRepository<SavingsContribution, UUID> {
  List<SavingsContribution> findBySavingsGoalOrderByContributionDateDescCreatedAtDesc(
      SavingsGoal savingsGoal);
}
