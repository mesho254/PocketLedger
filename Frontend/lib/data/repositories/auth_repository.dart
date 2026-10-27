import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/auth_model.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SecureStorageService storageService;

  AuthRepository({
    required this.apiClient,
    required this.storageService,
  });

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
    String currency = 'USD',
  }) async {
    final response = await apiClient.post(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'currency': currency,
      },
    );

    final authResponse = AuthResponseModel.fromJson(response.data);
    await storageService.saveToken(authResponse.token);
    await storageService.saveUser(authResponse.user.toJson());
    return authResponse;
  }

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final authResponse = AuthResponseModel.fromJson(response.data);
    await storageService.saveToken(authResponse.token);
    await storageService.saveUser(authResponse.user.toJson());
    return authResponse;
  }

  Future<UserModel> getProfile() async {
    final response = await apiClient.get(ApiConstants.me);
    final user = UserModel.fromJson(response.data);
    await storageService.saveUser(user.toJson());
    return user;
  }

  Future<void> logout() async {
    await storageService.clearAuth();
  }

  Future<String?> getToken() => storageService.getToken();
  Future<Map<String, dynamic>?> getCachedUser() => storageService.getUser();
}
