import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../domain/entities/user_entity.dart';
import '../datasources/local/storage_service.dart';
import '../datasources/remote/api_service.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository(this._apiService, this._storageService);

  Future<UserEntity> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.success == true &&
          authResponse.data?.token != null &&
          authResponse.data?.user != null) {
        // Guardar datos en storage
        await _storageService.saveToken(authResponse.data!.token!);
        await _storageService.saveUserId(authResponse.data!.user!.id ?? '');
        await _storageService.saveUserEmail(authResponse.data!.user!.email);
        await _storageService.saveUserName(authResponse.data!.user!.name);
        await _storageService.saveUserRole(authResponse.data!.user!.role);
        await _storageService.setLoggedIn(true);

        return authResponse.data!.user!.toEntity();
      } else {
        throw ServerException(
            authResponse.message ?? 'Error al iniciar sesión');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Error al iniciar sesión: ${e.toString()}');
    }
  }

  Future<UserEntity> register(
      String email, String password, String name) async {
    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        name: name,
        role: 'VENDEDOR', // Por defecto es VENDEDOR (en mayúsculas)
      );

      final response = await _apiService.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.success == true &&
          authResponse.data?.token != null &&
          authResponse.data?.user != null) {
        // Guardar datos en storage
        await _storageService.saveToken(authResponse.data!.token!);
        await _storageService.saveUserId(authResponse.data!.user!.id ?? '');
        await _storageService.saveUserEmail(authResponse.data!.user!.email);
        await _storageService.saveUserName(authResponse.data!.user!.name);
        await _storageService.saveUserRole(authResponse.data!.user!.role);
        await _storageService.setLoggedIn(true);

        return authResponse.data!.user!.toEntity();
      } else {
        throw ServerException(
            authResponse.message ?? 'Error al registrar usuario');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Error al registrar usuario: ${e.toString()}');
    }
  }

  Future<UserEntity?> getCurrentUser() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return null;

      final response = await _apiService.get(ApiConstants.me);

      // Manejar respuesta de Firebase
      final data = response.data['data'];
      final user = data?['user'];
      if (user != null) {
        return UserEntity(
          id: user['id'] ?? '',
          email: user['email'] ?? '',
          name: user['displayName'] ?? user['name'] ?? '',
          role: user['role'] ?? '',
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
  }

  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  Future<String?> getUserRole() async {
    return await _storageService.getUserRole();
  }

  Future<UserEntity?> getUserFromStorage() async {
    try {
      final token = await _storageService.getToken();
      final userId = await _storageService.getUserId();
      final email = await _storageService.getUserEmail();
      final name = await _storageService.getUserName();
      final role = await _storageService.getUserRole();

      if (token != null &&
          userId != null &&
          email != null &&
          name != null &&
          role != null) {
        return UserEntity(
          id: userId,
          email: email,
          name: name,
          role: role,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
