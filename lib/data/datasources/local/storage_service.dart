import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_keys.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Token
  Future<void> saveToken(String token) async {
    await _prefs.setString(StorageKeys.token, token);
  }

  Future<String?> getToken() async {
    return _prefs.getString(StorageKeys.token);
  }

  Future<void> deleteToken() async {
    await _prefs.remove(StorageKeys.token);
  }

  // User ID
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(StorageKeys.userId, userId);
  }

  Future<String?> getUserId() async {
    return _prefs.getString(StorageKeys.userId);
  }

  // User Email
  Future<void> saveUserEmail(String email) async {
    await _prefs.setString(StorageKeys.userEmail, email);
  }

  Future<String?> getUserEmail() async {
    return _prefs.getString(StorageKeys.userEmail);
  }

  // User Name
  Future<void> saveUserName(String name) async {
    await _prefs.setString(StorageKeys.userName, name);
  }

  Future<String?> getUserName() async {
    return _prefs.getString(StorageKeys.userName);
  }

  // User Role
  Future<void> saveUserRole(String role) async {
    await _prefs.setString(StorageKeys.userRole, role);
  }

  Future<String?> getUserRole() async {
    return _prefs.getString(StorageKeys.userRole);
  }

  // Login Status
  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(StorageKeys.isLoggedIn, value);
  }

  Future<bool> isLoggedIn() async {
    return _prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  // Clear All
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
