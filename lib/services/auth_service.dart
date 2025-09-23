import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<bool> login(String username, String password) async {
    try {
      final response = await ApiService.loginUser(
        userNameOrEmailAddress: username,
        password: password,
        rememberMe: true,
        tenantId: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      );

      if (response['success'] == true) {
        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', username);

        return true;
      } else {
        print('Login failed: ${response['error']}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('username');
    }
  }

  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }
}