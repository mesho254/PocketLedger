package com.pocketledger.transaction.repository;

import com.pocketledger.auth.model.User;
import com.pocketledger.transaction.entity.Transaction;
import com.pocketledger.transaction.enums.TransactionType;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface TransactionRepository
        extends JpaRepository<Transaction, UUID>, JpaSpecificationExecutor<Transaction> {

    Optional<Transaction> findByIdAndUser(UUID id, User user);

    Page<Transaction> findByUserOrderByTransactionDateDescCreatedAtDesc(User user, Pageable pageable);

    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t "
            + "WHERE t.user = :user AND t.type = :type "
            + "AND t.transactionDate BETWEEN :startDate AND :endDate")
    BigDecimal sumAmountByUserAndTypeAndDateRange(
            @Param("user") User user,
            @Param("type") TransactionType type,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    @Query("SELECT t.category as category, SUM(t.amount) as totalAmount FROM Transaction t "
            + "WHERE t.user = :user AND t.type = :type "
            + "AND t.transactionDate BETWEEN :startDate AND :endDate "
            + "GROUP BY t.category "
            + "ORDER BY totalAmount DESC")
    List<CategorySumProjection> sumAmountByCategory(
            @Param("user") User user,
            @Param("type") TransactionType type,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    interface CategorySumProjection {
        String getCategory();

        BigDecimal getTotalAmount();
    }
}
