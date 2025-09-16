class MachineStatus {
  final String machineId;
  final String status; // "red", "yellow", "green"
  final DateTime lastUpdated;

  MachineStatus({
    required this.machineId,
    required this.status,
    required this.lastUpdated,
  });

  factory MachineStatus.fromJson(Map<String, dynamic> json) {
    return MachineStatus(
      machineId: json['machineId'],
      status: json['status'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}