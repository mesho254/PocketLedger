package com.pocketledger.auth.mapper;

import com.pocketledger.auth.dto.UserProfileResponse;
import com.pocketledger.auth.model.User;
import org.mapstruct.Mapper;

@Mapper(config = PocketLedgerMapperConfig.class)
public interface UserMapper {

  UserProfileResponse toProfileResponse(User user);
}
