import 'package:flutter/material.dart';
import 'package:tls_inspection_machine/widgets/traffic_light_widget.dart';

class StatisticsView extends StatelessWidget {
  final List<String> machines;
  final Map<String, String> machineCurrentStatus;
  final Map<String, DateTime> machineLastUpdated;
  final Map<String, List<String>> machineFaults;
  final int totalRed;
  final int totalYellow;
  final int totalGreen;
  final int totalBlue;
  final int totalUpdated;
  final int totalNotUpdated;

  const StatisticsView({
    Key? key,
    required this.machines,
    required this.machineCurrentStatus,
    required this.machineLastUpdated,
    required this.machineFaults,
    required this.totalRed,
    required this.totalYellow,
    required this.totalGreen,
    required this.totalBlue,
    required this.totalUpdated,
    required this.totalNotUpdated,
  }) : super(key: key);

  // Helper function to format date
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Machine Status Statistics",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // Current Status Distribution
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Text(
                  "Current Status Distribution:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusCounter("DANGER! MANY ERRORS", totalRed, Colors.red),
                    _buildStatusCounter("WARNING! ", totalYellow, Colors.amber),
                    _buildStatusCounter("ALL OK!", totalGreen, Colors.green),
                    _buildStatusCounter("MAINTENANCE", totalBlue, Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Update Status
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Text(
                  "Update Status:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard("UPDATED", totalUpdated, Colors.green),
                    _buildStatCard("NOT UPDATED", totalNotUpdated, Colors.grey),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Machine Status Details
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Text(
                  "Machine Status Details:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    dataRowHeight: 60,
                    columns: const [
                      DataColumn(
                        label: Text(
                          "Machine",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Status",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Last Updated",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Faults",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    rows: machines.map((machine) {
                      final status = machineCurrentStatus[machine] ?? "green";
                      final lastUpdated = machineLastUpdated[machine];
                      final faults = machineFaults[machine] ?? [];

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              machine,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: _buildStatusIndicator(status),
                            ),
                          ),
                          DataCell(
                            Text(
                              lastUpdated != null
                                  ? _formatDate(lastUpdated)
                                  : "N/A",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: Text(
                                faults.isEmpty ? "No faults" : "${faults.length} faults",
                                style: TextStyle(
                                  color: faults.isEmpty ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCounter(String label, int count, Color color) {
    return Column(
      children: [
        // Status indicator
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              )
            ],
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case "red":
        color = Colors.red;
        icon = Icons.error;
        break;
      case "yellow":
        color = Colors.amber;
        icon = Icons.warning;
        break;
      case "blue":
        color = Colors.blue;
        icon = Icons.build;
        break;
      case "green":
      default:
        color = Colors.green;
        icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}