import 'package:flutter/material.dart';

class InlineInspectionSummary extends StatelessWidget {
  final String machineId;
  final String bundleNumber;
  final String operatorName;
  final String inspectionType;
  final int roundCount;
  final List<String> faults;
  final String previousStatus;
  final String shift;
  final String lineNumber;
  final String operation;
  final bool isMaintenance; // New parameter for maintenance status

  const InlineInspectionSummary({
    Key? key,
    required this.machineId,
    required this.bundleNumber,
    required this.operatorName,
    required this.inspectionType,
    required this.roundCount,
    required this.faults,
    required this.previousStatus,
    required this.shift,
    required this.lineNumber,
    required this.operation,
    this.isMaintenance = false, // Default to false
  }) : super(key: key);

  // Determine status based on faults count, severity, previous status, or maintenance
  String _determineStatus() {
    // If it's a maintenance inspection, return blue status
    if (isMaintenance) {
      return "blue";
    }

    if (faults.isEmpty) {
      return "green";
    }

    // Count critical faults
    int criticalFaults = faults.where((fault) => fault.contains("Critical")).length;

    // Determine status based on rules
    if (criticalFaults > 0) {
      return "red";
    } else if (faults.length >= 3) {
      return "red";
    } else if (faults.length >= 2) {
      return "yellow";
    } else if (previousStatus == "red" && faults.length > 0) {
      return "red";
    } else if (previousStatus == "yellow" && faults.length > 0) {
      return "yellow";
    } else {
      return "green";
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "red": return Colors.red;
      case "yellow": return Colors.amber;
      case "green": return Colors.green;
      case "blue": return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "red": return Icons.error;
      case "yellow": return Icons.warning;
      case "green": return Icons.check_circle;
      case "blue": return Icons.build;
      default: return Icons.help;
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case "red": return "Machine needs immediate attention";
      case "yellow": return "Machine needs monitoring";
      case "green": return "Machine is operating normally";
      case "blue": return "Machine is under maintenance";
      default: return "Status unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _determineStatus();
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusMessage = _getStatusMessage(status);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMaintenance ? "Maintenance Summary" : "Inspection Summary",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: statusColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              statusColor.withOpacity(0.8),
              statusColor.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Indicator with Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      statusMessage,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Inspection Details
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMaintenance ? "Maintenance Details" : "Inspection Details",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow("Machine Number", machineId),
                        _buildDetailRow("Bundle #", bundleNumber),
                        _buildDetailRow("Shift", shift),
                        _buildDetailRow("Line Number", lineNumber),
                        _buildDetailRow("Machine Operator", operatorName),
                        _buildDetailRow("Operation", operation),
                        _buildDetailRow(
                            isMaintenance ? "Maintenance Type" : "Inspection Type",
                            inspectionType == "Auto" ? "Auto" : "Round $roundCount"
                        ),
                        const SizedBox(height: 16),

                        // Faults or Maintenance Notes Section
                        if (isMaintenance) ...[
                          const Text(
                            "Maintenance Notes:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          faults.isEmpty
                              ? const Text("No maintenance notes added")
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: faults.map((note) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  "• $note",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ] else ...[
                          const Text(
                            "Faults:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          faults.isEmpty
                              ? const Text("No faults reported")
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: faults.map((fault) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  "• $fault",
                                  style: TextStyle(
                                    color: fault.contains("Critical")
                                        ? Colors.red
                                        : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Previous Status
                        _buildDetailRow("Previous Status",
                            "${previousStatus.toUpperCase()} - ${_getStatusMessage(previousStatus)}"),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog(context, status);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isMaintenance ? "Complete Maintenance" : "Submit Inspection",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isMaintenance ? "Complete Maintenance" : "Confirm Submission"),
          content: Text(isMaintenance
              ? "Are you sure you want to complete this maintenance and set status to BLUE?"
              : "Are you sure you want to submit this inspection with ${status.toUpperCase()} status?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitInspection(context, status);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getStatusColor(status),
              ),
              child: Text(
                isMaintenance ? "Complete" : "Confirm",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _submitInspection(BuildContext context, String status) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isMaintenance
            ? "Maintenance completed successfully!"
            : "Inspection submitted successfully!"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Return the result to the previous screen (MachineStatusScreen)
    Navigator.of(context).pop({
      'status': status,
      'faults': faults,
      'machineId': machineId,
      'isMaintenance': isMaintenance,
    });
  }
}