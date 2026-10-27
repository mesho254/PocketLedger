package com.pocketledger.repository;

import com.pocketledger.model.SavingsContribution;
import com.pocketledger.model.SavingsGoal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface SavingsContributionRepository extends JpaRepository<SavingsContribution, UUID> {
    List<SavingsContribution> findBySavingsGoalOrderByContributionDateDescCreatedAtDesc(SavingsGoal savingsGoal);
}
