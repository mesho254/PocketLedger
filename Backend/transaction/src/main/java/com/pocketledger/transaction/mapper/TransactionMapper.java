package com.pocketledger.transaction.mapper;

import com.pocketledger.auth.mapper.PocketLedgerMapperConfig;
import com.pocketledger.auth.model.User;
import com.pocketledger.transaction.dto.TransactionRequest;
import com.pocketledger.transaction.dto.TransactionResponse;
import com.pocketledger.transaction.entity.Transaction;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.Named;

@Mapper(config = PocketLedgerMapperConfig.class)
public interface TransactionMapper {

  @Mapping(target = "user", source = "user")
  @Mapping(target = "amount", source = "request.amount")
  @Mapping(target = "type", source = "request.type")
  @Mapping(target = "category", expression = "java(normalizeCategory(request.getCategory()))")
  @Mapping(target = "transactionDate", source = "request.transactionDate")
  @Mapping(target = "description", expression = "java(trim(request.getDescription()))")
  @Mapping(target = "id", ignore = true)
  @Mapping(target = "createdAt", ignore = true)
  @Mapping(target = "updatedAt", ignore = true)
  @Mapping(target = "createdBy", ignore = true)
  @Mapping(target = "lastModifiedBy", ignore = true)
  Transaction toEntity(TransactionRequest request, User user);

  @Mapping(target = "amount", source = "request.amount")
  @Mapping(target = "type", source = "request.type")
  @Mapping(target = "category", expression = "java(normalizeCategory(request.getCategory()))")
  @Mapping(target = "transactionDate", source = "request.transactionDate")
  @Mapping(target = "description", expression = "java(trim(request.getDescription()))")
  @Mapping(target = "id", ignore = true)
  @Mapping(target = "user", ignore = true)
  @Mapping(target = "createdAt", ignore = true)
  @Mapping(target = "updatedAt", ignore = true)
  @Mapping(target = "createdBy", ignore = true)
  @Mapping(target = "lastModifiedBy", ignore = true)
  void apply(@MappingTarget Transaction transaction, TransactionRequest request);

  TransactionResponse toResponse(Transaction transaction);

  @Named("normalizeCategory")
  default String normalizeCategory(String category) {
    return category == null ? null : category.trim().toUpperCase();
  }

  @Named("trim")
  default String trim(String value) {
    return value == null ? null : value.trim();
  }
}
