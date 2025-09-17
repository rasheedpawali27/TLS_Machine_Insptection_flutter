// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://your-demo-api-url.com/api'; // Replace with your demo API URL

  // SharedPreferences instance
  static late SharedPreferences _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Generic GET request
  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_prefs.getString('token')}',
          ...?headers,
        },
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic POST request
  static Future<Map<String, dynamic>> post(String endpoint, dynamic data, {Map<String, String>? headers}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_prefs.getString('token')}',
          ...?headers,
        },
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic PUT request
  static Future<Map<String, dynamic>> put(String endpoint, dynamic data, {Map<String, String>? headers}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_prefs.getString('token')}',
          ...?headers,
        },
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_prefs.getString('token')}',
          ...?headers,
        },
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Handle API response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final responseBody = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      throw Exception(
          responseBody['message'] ??
              'Request failed with status: ${response.statusCode}'
      );
    }
  }

  // Login method
  static Future<bool> login(String username, String password) async {
    try {
      final response = await post('login', {
        'username': username,
        'password': password,
      });

      if (response['success'] == true) {
        // Save token and user data
        await _prefs.setString('token', response['data']['token']);
        await _prefs.setString('currentUser', json.encode(response['data']['user']));
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Logout method
  static Future<void> logout() async {
    try {
      // Call logout API if needed
      await post('logout', {});
    } catch (e) {
      // Even if API call fails, clear local data
    } finally {
      // Clear stored data
      await _prefs.remove('token');
      await _prefs.remove('currentUser');
    }
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _prefs.containsKey('token');
  }

  // Get current user data
  static Map<String, dynamic>? getCurrentUser() {
    final userString = _prefs.getString('currentUser');
    if (userString != null) {
      return json.decode(userString);
    }
    return null;
  }

  // Get auth token
  static String? getToken() {
    return _prefs.getString('token');
  }
}