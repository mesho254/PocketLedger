package com.pocketledger.savings.mapper;

import com.pocketledger.auth.mapper.PocketLedgerMapperConfig;
import com.pocketledger.savings.dto.SavingsContributionResponse;
import com.pocketledger.savings.dto.SavingsGoalResponse;
import com.pocketledger.savings.entity.SavingsContribution;
import com.pocketledger.savings.entity.SavingsGoal;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(config = PocketLedgerMapperConfig.class)
public interface SavingsMapper {

  @Mapping(target = "percentageCompleted", ignore = true)
  SavingsGoalResponse toGoalResponse(SavingsGoal goal);

  SavingsContributionResponse toContributionResponse(SavingsContribution contribution);
}
