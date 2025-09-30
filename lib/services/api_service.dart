import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.12.10.28/ILDQMS';

  // Login Function
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/loginuser/Authenticate?UserName=$username&UserPassword=$password',
      );

      print('🔗 API URL: $uri');

      final response = await http.get(uri);
      print('📡 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();

        if (responseBody.isEmpty || responseBody == '[]' || responseBody == 'null') {
          return {
            'success': false,
            'error': 'Invalid username or password',
          };
        }

        final raw = json.decode(responseBody);
        print('🔍 Parsed Response: $raw');
        print('🔍 Response Type: ${raw.runtimeType}');

        if (raw is List) {
          if (raw.isEmpty) {
            return {
              'success': false,
              'error': 'Invalid username or password',
            };
          } else {
            final userData = raw[0];
            print('🔍 First Element Type: ${userData.runtimeType}');

            return _parseUserData(userData);
          }
        }
        else if (raw is Map<String, dynamic>) {
          return _parseUserData(raw);
        }
        else {
          return {
            'success': false,
            'error': 'Unexpected response format: ${raw.runtimeType}',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  //   Get ALL Production Lines (for Line 0 case)
  static Future<List<Map<String, dynamic>>> getProductionLines() async {
    try {
      final uri = Uri.parse('$baseUrl/api/productionline');

      final response = await http.get(uri);
      print('📡 Production Lines Response Status: ${response.statusCode}');
      print('📦 Production Lines Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();

        if (responseBody.isEmpty || responseBody == '[]' || responseBody == 'null') {
          return [];
        }

        final raw = json.decode(responseBody);
        print('🔍 Production Lines Parsed: $raw');

        // Handle List response
        if (raw is List) {
          return raw.map<Map<String, dynamic>>((line) {
            return {
              'Line_ID': _safeParseInt(line['Line_ID']),
              'Line_Code': line['Line_Code']?.toString() ?? '',
              'Line_Desc': line['Line_Desc']?.toString() ?? '',
              'Section': line['Section']?.toString() ?? '',
            };
          }).toList();
        }

        return [];
      } else {
        throw Exception('Failed to load production lines: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching production lines: $e');
      throw e;
    }
  }

  //  Get USER-SPECIFIC Production Lines
  static Future<List<Map<String, dynamic>>> getUserProductionLines(int userId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/loginuser/getproductionlines/$userId');

      print('🔗 User Lines API URL: $uri');

      final response = await http.get(uri);
      print('📡 User Lines Response Status: ${response.statusCode}');
      print('📦 User Lines Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();

        if (responseBody.isEmpty || responseBody == '[]' || responseBody == 'null') {
          return [];
        }

        final raw = json.decode(responseBody);
        print('🔍 User Lines Parsed: $raw');

        // Handle List response
        if (raw is List) {
          return raw.map<Map<String, dynamic>>((line) {
            return {
              'Line_ID': _safeParseInt(line['Line_ID']),
              'Line_Code': line['Line_Code']?.toString() ?? '',
              'Line_Desc': line['Line_Desc']?.toString() ?? '',
              'Section': line['Section']?.toString() ?? '',
            };
          }).toList();
        }

        return [];
      } else {
        throw Exception('Failed to load user production lines: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching user production lines: $e');
      throw e;
    }
  }

  //  Get Line-specific Stations/Machines
  // ✅ TEMPORARY FIX: Use the existing API route
  static Future<List<Map<String, dynamic>>> getLineStations(int lineId, String planDate, {String workstationId = "0"}) async {
    try {
      //  YEH GALAT THA: api/productionline/getproductionlinesplan
      //  YEH SAHI HAI: api/loginuser/getproductionlinesplan tempro
      final uri = Uri.parse('$baseUrl/api/loginuser/getproductionlinesplan?PlanDate=$planDate&LineID=$lineId&WorkstationID=$workstationId');

      print('🔗 Line Stations API URL: $uri');

      final response = await http.get(uri);
      print('📡 Line Stations Response Status: ${response.statusCode}');
      print('📦 Line Stations Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();

        if (responseBody.isEmpty || responseBody == '[]' || responseBody == 'null') {
          print('⚠️ No stations data found for line $lineId');
          return [];
        }

        final raw = json.decode(responseBody);
        print('🔍 Line Stations Parsed: $raw');

        // Handle List response
        if (raw is List) {
          final stations = raw.map<Map<String, dynamic>>((station) {
            return {
              'WorkStation_ID': _safeParseInt(station['WorkStation_ID']),
              'WorkStation_Code': station['WorkStation_Code']?.toString() ?? '',
              'WorkStation_Desc': station['WorkStation_Desc']?.toString() ?? '',
              'Machine_ID': _safeParseInt(station['Machine_ID']),
              'Machine_Code': station['Machine_Code']?.toString() ?? '',
              'Machine_Desc': station['Machine_Desc']?.toString() ?? '',
            };
          }).toList();

          print('✅ Successfully parsed ${stations.length} stations');
          return stations;
        }

        print('⚠️ Unexpected response format for stations');
        return [];
      } else {
        print('❌ Failed to load line stations: ${response.statusCode}');
        throw Exception('Failed to load line stations: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching line stations: $e');
      throw e;
    }
  }

  // Get current date in YYYY-MM-DD format
  static String getCurrentDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  static Map<String, dynamic> _parseUserData(dynamic userData) {
    try {
      print('🔍 UserData Type: ${userData.runtimeType}');
      print('🔍 User_ID Type: ${userData['User_ID']?.runtimeType}');
      print('🔍 User_ID Value: ${userData['User_ID']}');

      final data = {
        'User_ID': _safeParseInt(userData['User_ID']),
        'User_Login': userData['User_Login']?.toString() ?? '',
        'User_Password': userData['User_Password']?.toString() ?? '',
        'User_Status': userData['User_Status']?.toString() ?? '',
        'Created_By': userData['Created_By']?.toString() ?? '',
        'Created_Date': userData['Created_Date']?.toString() ?? '',
        'Audit_By': userData['Audit_By']?.toString() ?? '',
        'Audit_Date': userData['Audit_Date']?.toString() ?? '',
      };

      print(' Final Data: $data');

      final userStatus = data['User_Status']?.toString().toUpperCase() ?? '';

      if (data['User_ID'] != 0 && userStatus == 'A') {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Invalid user or user inactive',
        };
      }
    } catch (e) {
      print('❌ Error parsing user data: $e');
      return {
        'success': false,
        'error': 'Error parsing user data: $e',
      };
    }
  }

  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;

    try {
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    } catch (e) {
      print(' Error parsing int: $value, Error: $e');
      return 0;
    }
  }
}