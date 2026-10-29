class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String currency;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.currency,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      currency: json['currency'] ?? 'USD',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'currency': currency,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? currency,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AuthResponseModel {
  final String token;
  final String? refreshToken;
  final String tokenType;
  final UserModel user;

  AuthResponseModel({
    required this.token,
    this.refreshToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken']?.toString(),
      tokenType: json['tokenType'] ?? 'Bearer',
      user: UserModel.fromJson(json),
    );
  }
}
