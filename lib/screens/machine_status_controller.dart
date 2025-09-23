import 'package:flutter/material.dart';
import 'package:tls_inspection_machine/services/auth_service.dart';
import 'package:tls_inspection_machine/screens/inline_inspection_summary.dart';

class MachineStatusController extends ChangeNotifier {
  final List<String> lines = [
    "Line 1", "Line 2", "Line 3", "Line 4", "Line 5", "Line 6", "Line 7",
    "Line 8", "Line 9", "Line 10", "Line 11", "Line 12", "Line 13",
  ];

  String? selectedLine;
  String inspectionType = "Auto";
  int roundCount = 0;
  int inspectionPieces = 5;
  final AuthService authService = AuthService();

  final Map<String, List<String>> lineMachines = {
    "Line 1": List.generate(10, (index) => "M-${101 + index}"),
    "Line 2": List.generate(10, (index) => "M-${201 + index}"),
    "Line 3": List.generate(10, (index) => "M-${301 + index}"),
    "Line 4": List.generate(10, (index) => "M-${401 + index}"),
    "Line 5": List.generate(10, (index) => "M-${501 + index}"),
    "Line 6": List.generate(10, (index) => "M-${601 + index}"),
    "Line 7": List.generate(10, (index) => "M-${701 + index}"),
    "Line 8": List.generate(10, (index) => "M-${801 + index}"),
    "Line 9": List.generate(10, (index) => "M-${901 + index}"),
    "Line 10": List.generate(10, (index) => "M-${1001 + index}"),
    "Line 11": List.generate(10, (index) => "M-${1101 + index}"),
    "Line 12": List.generate(10, (index) => "M-${1201 + index}"),
    "Line 13": List.generate(10, (index) => "M-${1301 + index}"),
  };

  final Map<String, bool> machineCTQStatus = {
    "M-101": true, "M-102": false, "M-103": true, "M-104": false, "M-105": true,
    "M-106": false, "M-107": true, "M-108": false, "M-109": true, "M-110": false,
    "M-201": false, "M-202": true, "M-203": false, "M-204": true, "M-205": false,
    "M-206": true, "M-207": false, "M-208": true, "M-209": false, "M-210": true,
  };

  List<String> get machines => selectedLine != null ? lineMachines[selectedLine!] ?? [] : [];

  String? selectedMachine;
  int currentView = 0;

  final Map<String, Map<String, int>> machineStatusCounts = {};
  final Map<String, String> machineCurrentStatus = {};
  final Map<String, DateTime> machineLastUpdated = {};
  final Map<String, List<String>> machineFaults = {};

  /// ✅ Round-wise statuses for each machine
  final Map<String, List<String>> machineRoundStatuses = {};
  final Map<String, int> machineCurrentRound = {};

  /// ✅ Store round details for each machine
  final Map<String, List<Map<String, dynamic>>> machineRoundDetails = {};

  int totalRed = 0;
  int totalYellow = 0;
  int totalGreen = 0;
  int totalBlue = 0;
  int totalUpdated = 0;
  int totalNotUpdated = 0;

  bool showInspectionForm = false;

  void initState() {
    // Check if user is logged in and set the assigned line
    if (authService.currentUser != null) {
      selectedLine = authService.currentUser!.assignedLine;
      if (selectedLine != null && machines.isNotEmpty) {
        selectedMachine = machines.first;
        updateInspectionPieces();
      }
    } else {
      // Default to first line if no user is logged in
      selectedLine = lines.first;
      selectedMachine = machines.isNotEmpty ? machines.first : null;
      updateInspectionPieces();
    }

    // Initialize all machines with default values
    for (var line in lines) {
      final machines = lineMachines[line];
      if (machines != null) {
        for (var machine in machines) {
          _initializeMachine(machine);
        }
      }
    }
    calculateTotals();
    notifyListeners();
  }

  void _initializeMachine(String machineId) {
    machineStatusCounts[machineId] = {
      "red": 0,
      "yellow": 0,
      "green": 0,
      "blue": 0,
    };
    machineCurrentStatus[machineId] = "green";
    machineLastUpdated[machineId] = DateTime.now();
    machineFaults[machineId] = [];

    // initialize round statuses (default grey for all 4 rounds)
    machineRoundStatuses[machineId] = ["grey", "grey", "grey", "grey"];
    machineCurrentRound[machineId] = 0; // 0 means no round has been inspected yet

    // initialize round details
    machineRoundDetails[machineId] = [];
  }

  /// ✅ Get the current round for a machine
  int getCurrentRound(String machineId) {
    return machineCurrentRound[machineId] ?? 0;
  }

  /// ✅ Get the next round for a machine
  int getNextRound(String machineId) {
    int currentRound = getCurrentRound(machineId);
    return currentRound < 4 ? currentRound + 1 : 4;
  }

  /// ✅ Update round status after inspection
  void updateRoundStatus(String machineId, String status, List<String> faults, String inspectorName) {
    int nextRound = getNextRound(machineId);
    if (nextRound <= 4) {
      machineRoundStatuses[machineId]![nextRound - 1] = status;
      machineCurrentRound[machineId] = nextRound;

      // Store round details
      machineRoundDetails[machineId]!.add({
        'round': nextRound,
        'status': status,
        'faults': List.from(faults),
        'timestamp': DateTime.now(),
        'inspector': inspectorName,
      });

      // Update the machine's current status based on the latest inspection
      machineCurrentStatus[machineId] = status;
      machineFaults[machineId] = faults;
      machineLastUpdated[machineId] = DateTime.now();

      // Update status counts
      machineStatusCounts[machineId]![status] = (machineStatusCounts[machineId]![status] ?? 0) + 1;

      // If all 4 rounds are completed, reset for a new cycle
      if (nextRound == 4) {
        // Reset rounds but keep the current status
        Future.delayed(const Duration(seconds: 2), () {
          resetMachineRounds(machineId);
          notifyListeners();
        });
      }
    }
    calculateTotals();
    notifyListeners();
  }

  /// ✅ Reset all rounds for a machine
  void resetMachineRounds(String machineId) {
    machineRoundStatuses[machineId] = ["grey", "grey", "grey", "grey"];
    machineCurrentRound[machineId] = 0;
    machineRoundDetails[machineId] = [];
    notifyListeners();
  }

  void calculateTotals() {
    int red = 0, yellow = 0, green = 0, blue = 0, updated = 0, notUpdated = 0;
    final now = DateTime.now();

    machineCurrentStatus.forEach((machine, status) {
      if (status == "red") red++;
      if (status == "yellow") yellow++;
      if (status == "green") green++;
      if (status == "blue") blue++;

      final lastUpdated = machineLastUpdated[machine];
      if (lastUpdated != null && now.difference(lastUpdated).inHours < 1) {
        updated++;
      } else {
        notUpdated++;
      }
    });

    totalRed = red;
    totalYellow = yellow;
    totalGreen = green;
    totalBlue = blue;
    totalUpdated = updated;
    totalNotUpdated = notUpdated;

    notifyListeners();
  }

  void updateInspectionPieces() {
    if (selectedMachine != null) {
      final isCTQ = machineCTQStatus[selectedMachine!] ?? false;
      inspectionPieces = isCTQ ? 10 : 5;
      notifyListeners();
    }
  }

  void updateStatus(String newStatus) {
    if (selectedMachine == null) return;

    machineCurrentStatus[selectedMachine!] = newStatus;
    machineLastUpdated[selectedMachine!] = DateTime.now();
    machineStatusCounts[selectedMachine!]![newStatus] =
        (machineStatusCounts[selectedMachine!]![newStatus] ?? 0) + 1;

    if (newStatus == "blue") {
      machineFaults[selectedMachine!] = [];
      showInspectionForm = true;
    }

    // Get inspector name from auth service or use default
    String inspectorName = authService.currentUser?.fullName ?? "Unknown Inspector";

    // Update the round status with empty faults for button clicks
    updateRoundStatus(selectedMachine!, newStatus, [], inspectorName);

    notifyListeners();
  }

  void selectMachine(String machineId) {
    selectedMachine = machineId;
    updateInspectionPieces();
    notifyListeners();
  }

  void selectLine(String? line) {
    selectedLine = line;
    if (selectedLine != null && machines.isNotEmpty) {
      selectedMachine = machines.first;
      updateInspectionPieces();
    } else {
      selectedMachine = null;
    }
    notifyListeners();
  }

  void changeInspectionType(String type) {
    inspectionType = type;
    if (inspectionType == "Auto") {
      updateInspectionPieces();
    } else {
      roundCount = 1;
    }
    notifyListeners();
  }

  void incrementRound() {
    if (roundCount < 4) {
      roundCount++;
      notifyListeners();
    }
  }

  void decrementRound() {
    if (roundCount > 1) {
      roundCount--;
      notifyListeners();
    }
  }

  Color getMachineColor(String machineId) {
    final status = machineCurrentStatus[machineId] ?? "green";

    switch (status) {
      case "red":
        return Colors.red[400]!;
      case "yellow":
        return Colors.amber[300]!;
      case "blue":
        return Colors.blue[400]!;
      case "green":
      default:
        return Colors.green[400]!;
    }
  }

  IconData getMachineIcon(String machineId) {
    final status = machineCurrentStatus[machineId] ?? "green";

    switch (status) {
      case "red":
        return Icons.error;
      case "yellow":
        return Icons.warning;
      case "blue":
        return Icons.build;
      case "green":
      default:
        return Icons.check_circle;
    }
  }

  bool isMachineCTQ(String machineId) {
    return machineCTQStatus[machineId] ?? false;
  }

  void switchView() {
    currentView = currentView == 0 ? 1 : 0;
    notifyListeners();
  }

  void closeInspectionForm() {
    showInspectionForm = false;
    notifyListeners();
  }

  void submitInspectionForm(List<String> selectedFaults) {
    if (selectedMachine != null) {
      machineFaults[selectedMachine!] = selectedFaults;
      String status;
      if (selectedFaults.isEmpty) {
        status = "green";
      } else if (selectedFaults.length == 1) {
        status = "yellow";
      } else {
        status = "red";
      }

      // Get inspector name from auth service
      String inspectorName = authService.currentUser?.fullName ?? "Unknown Inspector";

      // Update the round status with actual faults
      updateRoundStatus(selectedMachine!, status, selectedFaults, inspectorName);
    }
    closeInspectionForm();
  }

  void openInspectionSummary(BuildContext context, Map<String, dynamic> formData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InlineInspectionSummary(
          machineId: selectedMachine!,
          bundleNumber: formData['bundleNumber'] ?? '',
          operatorName: formData['operatorName'] ?? '',
          inspectionType: inspectionType,
          roundCount: inspectionType == "Auto" ? inspectionPieces : roundCount,
          faults: formData['selectedFaults'] ?? [],
          previousStatus: machineCurrentStatus[selectedMachine!] ?? "red",
          shift: formData['shift'] ?? '',
          lineNumber: selectedLine ?? "Line 1",
          operation: formData['operation'] ?? '',
          isMaintenance: formData['isMaintenance'] ?? false,
        ),
      ),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        handleInspectionResult(result);
      }
    });
  }

  void handleInspectionResult(Map<String, dynamic> result) {
    final List<String> faults = result['faults'];
    final String machineId = result['machineId'];
    final String status = getMachineStatusBasedOnFaults(faults);

    machineFaults[machineId] = faults;
    machineCurrentStatus[machineId] = status;
    machineLastUpdated[machineId] = DateTime.now();

    // Get inspector name from auth service
    String inspectorName = authService.currentUser?.fullName ?? "Unknown Inspector";

    // Update the round status
    updateRoundStatus(machineId, status, faults, inspectorName);

    notifyListeners();
  }

  String getMachineStatusBasedOnFaults(List<String> faults) {
    if (faults.isEmpty) {
      return "green";
    } else if (faults.length == 1) {
      return "yellow";
    } else {
      return "red";
    }
  }

  void fixMachineFaults(String machineId) {
    machineFaults[machineId] = [];
    machineCurrentStatus[machineId] = "green";
    machineLastUpdated[machineId] = DateTime.now();

    // Get inspector name from auth service
    String inspectorName = authService.currentUser?.fullName ?? "Unknown Inspector";

    // Update the round status to green when faults are fixed
    updateRoundStatus(machineId, "green", [], inspectorName);

    notifyListeners();
  }

  void fixSpecificFault(String machineId, String fault) {
    machineFaults[machineId]?.remove(fault);
    final remainingFaults = machineFaults[machineId]?.length ?? 0;

    String status;
    if (remainingFaults == 0) {
      status = "green";
    } else if (remainingFaults == 1) {
      status = "yellow";
    } else {
      status = "red";
    }

    machineCurrentStatus[machineId] = status;
    machineLastUpdated[machineId] = DateTime.now();

    // Get inspector name from auth service
    String inspectorName = authService.currentUser?.fullName ?? "Unknown Inspector";

    // Update the round status
    updateRoundStatus(machineId, status, machineFaults[machineId] ?? [], inspectorName);

    notifyListeners();
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  void showMachineDetails(BuildContext context, String machineId) {
    final status = machineCurrentStatus[machineId] ?? "green";
    final lastUpdated = machineLastUpdated[machineId] ?? DateTime.now();
    final faults = machineFaults[machineId] ?? [];
    final statusCounts = machineStatusCounts[machineId] ?? {"red": 0, "yellow": 0, "green": 0, "blue": 0};
    final isCTQ = isMachineCTQ(machineId);
    final currentRound = getCurrentRound(machineId);
    final roundStatuses = machineRoundStatuses[machineId] ?? ["grey", "grey", "grey", "grey"];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Machine Details: $machineId'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    getMachineIcon(machineId),
                    color: getMachineColor(machineId),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${status.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: getMachineColor(machineId),
                    ),
                  ),
                  if (isCTQ) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.warning, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'CTQ',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text('Line: $selectedLine'),
              const SizedBox(height: 10),
              Text('Last Updated: ${formatDate(lastUpdated)}'),
              const SizedBox(height: 10),
              Text(
                'Operation Type: ${isCTQ ? "CTQ (10 pieces)" : "Non-CTQ (5 pieces)"}',
              ),
              const SizedBox(height: 10),
              Text('Current Round: $currentRound/4'),
              const SizedBox(height: 10),
              const Text(
                'Round Status:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < 4; i++)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close current dialog
                        showRoundDetails(context, machineId, i + 1);
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.black),
                        ),
                        color: _getStatusColor(roundStatuses[i]),
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: roundStatuses[i] == "grey" ? Colors.black : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),
              Text('Faults: ${faults.length}'),
              if (faults.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  'Fault List:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...faults.map(
                      (fault) => GestureDetector(
                    onLongPress: () => showFixFaultDialog(context, machineId, fault),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(fault),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              fixMachineFaults(machineId);
              Navigator.pop(context);
            },
            child: const Text('Fix All'),
          ),
          ElevatedButton(
            onPressed: () {
              resetMachineRounds(machineId);
              Navigator.pop(context);
            },
            child: const Text('Reset Rounds'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openInspectionFormDirectly(machineId);
            },
            child: const Text('Inspect'),
          ),
        ],
      ),
    );
  }

  /// ✅ Show round details in a popup
  void showRoundDetails(BuildContext context, String machineId, int roundNumber) {
    final roundDetails = machineRoundDetails[machineId];
    final roundDetail = roundDetails != null && roundDetails.length >= roundNumber
        ? roundDetails[roundNumber - 1]
        : null;

    final roundStatus = machineRoundStatuses[machineId]?[roundNumber - 1] ?? "grey";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Round $roundNumber Details - $machineId'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _getStatusColor(roundStatus),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Status: ${roundStatus.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(roundStatus),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              if (roundDetail != null) ...[
                Text('Inspector: ${roundDetail['inspector']}'),
                const SizedBox(height: 10),
                Text('Date: ${formatDate(roundDetail['timestamp'])}'),
                const SizedBox(height: 10),
                Text('Faults Found: ${roundDetail['faults'].length}'),
                const SizedBox(height: 10),

                if (roundDetail['faults'].isNotEmpty) ...[
                  const Text(
                    'Fault List:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...roundDetail['faults'].map(
                        (fault) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(fault),
                    ),
                  ),
                ] else ...[
                  const Text('No faults found in this round'),
                ],
              ] else ...[
                const Text('No inspection data available for this round'),
              ],
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void showFixFaultDialog(BuildContext context, String machineId, String fault) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fix Fault'),
        content: Text('Are you sure you want to fix the fault: $fault?'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              fixSpecificFault(machineId, fault);
              Navigator.pop(context);
            },
            child: const Text('Fix'),
          ),
        ],
      ),
    );
  }

  /// ✅ Add this method to open inspection form directly
  void openInspectionFormDirectly(String machineId) {
    selectedMachine = machineId;
    updateInspectionPieces();
    showInspectionForm = true;
    notifyListeners();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "red":
        return Colors.red;
      case "yellow":
        return Colors.amber;
      case "green":
        return Colors.green;
      case "blue":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}