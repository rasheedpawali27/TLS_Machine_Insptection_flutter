import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  // ✅ CORRECTED GETTERS - Remove the incorrect ones
  String? get fullName => _currentUser?['User_Login']?.toString();
  String? get assignedLine => _currentUser?['assignedLine']?.toString();
  int? get userId => _currentUser?['User_ID'];
  List<Map<String, dynamic>> get userLines => _currentUser?['userLines'] ?? [];

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await ApiService.login(
        username: username,
        password: password,
      );

      if (response['success'] == true) {
        final data = response['data'];
        _currentUser = data;

        // ✅ USER-SPECIFIC LINES FETCH KARO DATABASE SE
        await _fetchUserProductionLines(data['User_ID']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userData', json.encode(_currentUser));
        await prefs.setString('username', username);

        return {
          'success': true,
          'message': 'Login successful',
        };
      } else {
        return {
          'success': false,
          'error': response['error'],
        };
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'error': 'Login failed: $e',
      };
    }
  }

  // ✅ NEW: Fetch user-specific production lines from database
  Future<void> _fetchUserProductionLines(int userId) async {
    try {
      print('🔍 Fetching production lines for user: $userId');

      // User-specific lines fetch karo
      final userLines = await ApiService.getUserProductionLines(userId);
      print('✅ User-specific lines fetched: ${userLines.length}');

      if (userLines.isNotEmpty) {
        // User ki specific lines hain
        _currentUser!['userLines'] = userLines;
        _currentUser!['assignedLine'] = userLines.first['Line_Code']?.toString();
        _currentUser!['hasSpecificLines'] = true;
        print('✅ User has specific lines: ${userLines.map((line) => line['Line_Code']).toList()}');
      } else {
        // ✅ LINE 0 CASE: Agar user ki koi specific line nahi hai to sab lines show karo
        print('⚠️ No specific lines found for user, fetching all lines...');
        final allLines = await ApiService.getProductionLines();
        _currentUser!['userLines'] = allLines;
        _currentUser!['assignedLine'] = allLines.isNotEmpty ? allLines.first['Line_Code']?.toString() : null;
        _currentUser!['hasSpecificLines'] = false;
        print('✅ All lines fetched for Line 0 case: ${allLines.length}');
      }
    } catch (e) {
      print('❌ Error fetching user production lines: $e');
      // Fallback: Agar error aaye to empty set karo
      _currentUser!['userLines'] = [];
      _currentUser!['hasSpecificLines'] = false;
    }
  }

  // ✅ NEW: Get available lines for dropdown (Line 0 logic implement)
  List<Map<String, dynamic>> getAvailableLines() {
    if (_currentUser == null) return [];

    // Agar user ki specific lines hain to wahi show karo
    if (_currentUser!['hasSpecificLines'] == true) {
      return _currentUser!['userLines'] ?? [];
    } else {
      // Line 0 case: Sab lines available hain
      return _currentUser!['userLines'] ?? [];
    }
  }

  // ✅ NEW: Check if user has access to all lines (Line 0)
  bool get hasAccessToAllLines {
    return _currentUser?['hasSpecificLines'] == false;
  }

  // ✅ NEW: Get user's first assigned line
  String? get firstAssignedLine {
    final lines = getAvailableLines();
    return lines.isNotEmpty ? lines.first['Line_Code']?.toString() : null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // ✅ Complete logout method
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all stored data
      _currentUser = null; // Clear current user data

      print('✅ Logout successful - All data cleared');
    } catch (e) {
      print('❌ Error during logout: $e');
      throw e;
    }
  }

  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // ✅ Load user data from shared preferences
  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('isLoggedIn') == true) {
        final userDataString = prefs.getString('userData');
        if (userDataString != null) {
          _currentUser = json.decode(userDataString);
          print('✅ User data loaded from storage');
          print('🔍 User has specific lines: ${_currentUser?['hasSpecificLines']}');
          print('🔍 Available lines: ${getAvailableLines().length}');
        }
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  // ✅ NEW: Refresh user lines data
  Future<void> refreshUserLines() async {
    if (_currentUser != null && _currentUser!['User_ID'] != null) {
      await _fetchUserProductionLines(_currentUser!['User_ID']);
    }
  }

  // ✅ NEW: Get line by code
  Map<String, dynamic>? getLineByCode(String lineCode) {
    final lines = getAvailableLines();
    try {
      return lines.firstWhere(
            (line) => line['Line_Code'] == lineCode,
      );
    } catch (e) {
      return null;
    }
  }

  // ✅ NEW: Get line by ID
  Map<String, dynamic>? getLineById(int lineId) {
    final lines = getAvailableLines();
    try {
      return lines.firstWhere(
            (line) => line['Line_ID'] == lineId,
      );
    } catch (e) {
      return null;
    }
  }
}