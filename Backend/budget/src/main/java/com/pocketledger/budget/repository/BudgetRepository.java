package com.pocketledger.budget.repository;

import com.pocketledger.auth.model.User;
import com.pocketledger.budget.entity.Budget;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BudgetRepository extends JpaRepository<Budget, UUID> {
  List<Budget> findByUserAndYearAndMonth(User user, int year, int month);

  Optional<Budget> findByUserAndYearAndMonthAndCategory(
      User user, int year, int month, String category);

  Optional<Budget> findByIdAndUser(UUID id, User user);
}
