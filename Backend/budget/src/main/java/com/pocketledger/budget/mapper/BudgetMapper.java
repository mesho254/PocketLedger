package com.pocketledger.budget.mapper;

import com.pocketledger.auth.mapper.PocketLedgerMapperConfig;
import com.pocketledger.auth.model.User;
import com.pocketledger.budget.dto.BudgetRequest;
import com.pocketledger.budget.dto.BudgetResponse;
import com.pocketledger.budget.entity.Budget;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.Named;

@Mapper(config = PocketLedgerMapperConfig.class)
public interface BudgetMapper {

  @Mapping(target = "user", source = "user")
  @Mapping(target = "category", expression = "java(normalizeCategory(request.getCategory()))")
  @Mapping(target = "monthlyLimit", source = "request.monthlyLimit")
  @Mapping(target = "month", source = "request.month")
  @Mapping(target = "year", source = "request.year")
  @Mapping(target = "id", ignore = true)
  @Mapping(target = "createdAt", ignore = true)
  @Mapping(target = "updatedAt", ignore = true)
  @Mapping(target = "createdBy", ignore = true)
  @Mapping(target = "lastModifiedBy", ignore = true)
  Budget toEntity(BudgetRequest request, User user);

  @Mapping(target = "category", expression = "java(normalizeCategory(request.getCategory()))")
  @Mapping(target = "monthlyLimit", source = "request.monthlyLimit")
  @Mapping(target = "month", source = "request.month")
  @Mapping(target = "year", source = "request.year")
  @Mapping(target = "id", ignore = true)
  @Mapping(target = "user", ignore = true)
  @Mapping(target = "createdAt", ignore = true)
  @Mapping(target = "updatedAt", ignore = true)
  @Mapping(target = "createdBy", ignore = true)
  @Mapping(target = "lastModifiedBy", ignore = true)
  void apply(@MappingTarget Budget budget, BudgetRequest request);

  BudgetResponse toResponse(Budget budget);

  @Named("normalizeCategory")
  default String normalizeCategory(String category) {
    return category == null ? null : category.trim().toUpperCase();
  }
}
