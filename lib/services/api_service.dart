import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/machine_status_model.dart';

class ApiService {
  static const String _baseUrl = "https://your-api.interloop-denim.com/tls";

  Future<MachineStatus> fetchMachineStatus(String machineId) async {
    final response = await http.get(Uri.parse("$_baseUrl/status/$machineId"));

    if (response.statusCode == 200) {
      return MachineStatus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch machine status');
    }
  }

  Future<void> updateMachineStatus(String machineId, String newStatus) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/update-status"),
      body: json.encode({
        'machineId': machineId,
        'status': newStatus,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }
}