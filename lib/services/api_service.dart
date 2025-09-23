import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://10.12.8.245:8080/api';

  // Test basic connectivity
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing connection to: $baseUrl');

      final response = await http.get(
        Uri.parse('$baseUrl/account/login'),
      ).timeout(Duration(seconds: 10));

      print('📡 Response received. Status: ${response.statusCode}');
      return true;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  // Login method with detailed error handling
  static Future<Map<String, dynamic>> login({
    required String userNameOrEmailAddress,
    required String password,
    required bool rememberMe,
    required String tenantId,
  }) async {
    try {
      print('🚀 Attempting login...');

      final response = await http.post(
        Uri.parse('$baseUrl/account/login'),
        headers: {
          'accept': 'text/plain',
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: json.encode({
          'userNameOrEmailAddress': userNameOrEmailAddress,
          'password': password,
          'rememberMe': rememberMe,
          'tenantId': tenantId,
        }),
      ).timeout(Duration(seconds: 30));

      print('📊 Login response status: ${response.statusCode}');
      print('📄 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 1) {
          return {'success': true, 'message': 'Login successful'};
        } else {
          return {'success': false, 'error': data['description'] ?? 'Login failed'};
        }
      } else {
        return {'success': false, 'error': 'HTTP ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      print('💥 Login error: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}