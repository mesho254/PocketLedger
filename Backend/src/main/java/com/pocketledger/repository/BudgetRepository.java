package com.pocketledger.repository;

import com.pocketledger.model.Budget;
import com.pocketledger.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface BudgetRepository extends JpaRepository<Budget, UUID> {
    List<Budget> findByUserAndYearAndMonth(User user, int year, int month);
    Optional<Budget> findByUserAndYearAndMonthAndCategory(User user, int year, int month, String category);
    Optional<Budget> findByIdAndUser(UUID id, User user);
}
