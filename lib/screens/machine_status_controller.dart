import 'package:flutter/material.dart';
import 'package:tls_inspection_machine/services/auth_service.dart';
import 'package:tls_inspection_machine/services/api_service.dart';
import 'package:tls_inspection_machine/screens/inline_inspection_summary.dart';

class MachineStatusController extends ChangeNotifier {
  // ✅ DATABASE-BASED LINES & MACHINES
  List<Map<String, dynamic>> _availableLines = [];
  List<Map<String, dynamic>> _availableStations = [];
  List<Map<String, dynamic>> _availableMachines = [];

  String? selectedLine;
  String inspectionType = "Auto";
  int roundCount = 1;
  int inspectionPieces = 5;
  final AuthService authService = AuthService();

  // ✅ GETTERS FOR DATABASE DATA
  List<Map<String, dynamic>> get availableLines => _availableLines;
  List<String> get lineNames => _availableLines.map((line) => line['Line_Code']?.toString() ?? '').toList();

  List<Map<String, dynamic>> get availableStations => _availableStations;
  List<Map<String, dynamic>> get availableMachines => _availableMachines;

  // ✅ GET MACHINES FOR SELECTED LINE - FIXED VERSION
  List<String> get machines {
    if (selectedLine == null) return [];

    print('🔍 Getting machines for selected line: $selectedLine');
    print('🔍 Available machines count: ${_availableMachines.length}');

    // ✅ RETURN ALL MACHINE CODES
    final machineCodes = _availableMachines
        .map((machine) => machine['Machine_Code']?.toString() ?? '')
        .where((code) => code.isNotEmpty)
        .toList();

    print('✅ Found ${machineCodes.length} machines for line $selectedLine');
    print('✅ Machines: $machineCodes');

    return machineCodes;
  }

  String? selectedMachine;
  int currentView = 0;

  // Machine status tracking
  final Map<String, Map<String, int>> machineStatusCounts = {};
  final Map<String, String> machineCurrentStatus = {};
  final Map<String, DateTime> machineLastUpdated = {};
  final Map<String, List<String>> machineFaults = {};

  // Round-wise statuses for each machine
  final Map<String, List<String>> machineRoundStatuses = {};
  final Map<String, int> machineCurrentRound = {};

  // Store round details for each machine
  final Map<String, List<Map<String, dynamic>>> machineRoundDetails = {};

  int totalRed = 0;
  int totalYellow = 0;
  int totalGreen = 0;
  int totalBlue = 0;
  int totalUpdated = 0;
  int totalNotUpdated = 0;

  bool showInspectionForm = false;
  bool _isLoading = false;

  // ✅ INITIALIZE WITH DATABASE DATA
  Future<void> initState() async {
    _isLoading = true;
    notifyListeners();

    try {
      // ✅ LOAD USER LINES FROM DATABASE
      await _loadUserLines();

      // ✅ LOAD STATIONS/MACHINES FOR SELECTED LINE
      if (selectedLine != null) {
        await _loadLineStations();
      }

      // ✅ INITIALIZE MACHINES WITH DEFAULT VALUES
      _initializeAllMachines();

      calculateTotals();

    } catch (e) {
      print('❌ Error initializing controller: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ LOAD USER-SPECIFIC OR ALL LINES FROM DATABASE
  Future<void> _loadUserLines() async {
    try {
      if (authService.currentUser != null) {
        // Use lines from auth service (already fetched during login)
        _availableLines = authService.getAvailableLines();

        // Set selected line based on user's assigned line or first available
        if (_availableLines.isNotEmpty) {
          selectedLine = authService.firstAssignedLine ?? _availableLines.first['Line_Code']?.toString();
          print('✅ Loaded ${_availableLines.length} lines for user');
          print('✅ Selected line: $selectedLine');
          print('✅ Available lines: $_availableLines');
        } else {
          print('⚠️ No lines available for user, using fallback');
          _useTemporaryLines();
        }
      } else {
        print('⚠️ No user logged in, using temporary data');
        _useTemporaryLines();
      }
    } catch (e) {
      print('❌ Error loading user lines: $e');
      _useTemporaryLines();
    }
  }

  // ✅ LOAD LINE-SPECIFIC STATIONS/MACHINES FROM DATABASE - UPDATED FOR ACTUAL API RESPONSE
  Future<void> _loadLineStations() async {
    if (selectedLine == null) {
      print('❌ No line selected, cannot load stations');
      return;
    }

    try {
      print('🔍 Loading stations for line: $selectedLine');

      // Find selected line ID
      final selectedLineData = _availableLines.firstWhere(
            (line) => line['Line_Code'] == selectedLine,
        orElse: () => {},
      );

      if (selectedLineData.isNotEmpty && selectedLineData['Line_ID'] != null) {
        final lineId = selectedLineData['Line_ID'];
        final currentDate = ApiService.getCurrentDate();

        print('🔗 Fetching stations for Line_ID: $lineId, Date: $currentDate');

        try {
          // ✅ CONVERT lineId TO INT
          int lineIdInt;
          if (lineId is int) {
            lineIdInt = lineId;
          } else if (lineId is String) {
            lineIdInt = int.tryParse(lineId) ?? 0;
          } else {
            lineIdInt = 0;
          }

          if (lineIdInt > 0) {
            // ✅ CALL API TO GET STATIONS/MACHINES
            _availableStations = await ApiService.getLineStations(lineIdInt, currentDate);
            print('✅ Stations fetched from API: ${_availableStations.length}');

            if (_availableStations.isNotEmpty) {
              print('🔍 First station data: ${_availableStations.first}');

              // ✅ EXTRACT MACHINES FROM STATIONS - UPDATED FOR ACTUAL API FORMAT
              _availableMachines = _extractMachinesFromStations(_availableStations);
              print('✅ Machines extracted: ${_availableMachines.length}');

              if (_availableMachines.isEmpty) {
                print('⚠️ No machines extracted, creating from WorkStation data');
                _createMachinesFromWorkStations();
              }
            } else {
              print('⚠️ No stations returned from API, using temporary data');
              _useTemporaryStations();
            }
          } else {
            print('❌ Invalid Line_ID, using temporary data');
            _useTemporaryStations();
          }
        } catch (e) {
          print('❌ API Error: $e');
          print('🔄 Using temporary data as fallback');
          _useTemporaryStations();
        }
      } else {
        print('❌ Could not find Line_ID for selected line: $selectedLine');
        _useTemporaryStations();
      }
    } catch (e) {
      print('❌ Error loading line stations: $e');
      _useTemporaryStations();
    }

    // Set first machine as selected
    if (_availableMachines.isNotEmpty) {
      selectedMachine = _availableMachines.first['Machine_Code']?.toString();
      updateInspectionPieces();
      print('✅ Selected machine: $selectedMachine');
    } else {
      print('⚠️ No machines available for selected line');
      selectedMachine = null;
    }
  }

  // ✅ EXTRACT MACHINES FROM STATIONS DATA - UPDATED FOR ACTUAL API FORMAT
  List<Map<String, dynamic>> _extractMachinesFromStations(List<Map<String, dynamic>> stations) {
    final machines = <Map<String, dynamic>>[];

    for (var station in stations) {
      // ✅ CHECK BOTH Machine_Code AND WorkStation_Code
      String? machineCode;
      String? machineDesc;

      // First try to get Machine_Code
      if (station['Machine_Code'] != null && station['Machine_Code'].toString().isNotEmpty) {
        machineCode = station['Machine_Code'].toString();
        machineDesc = station['Machine_Desc']?.toString() ?? machineCode;
      }
      // If no Machine_Code, try WorkStation_Code (from your API response)
      else if (station['WorkStation_Code'] != null && station['WorkStation_Code'].toString().isNotEmpty) {
        machineCode = station['WorkStation_Code'].toString();
        machineDesc = station['WorkStation_Desc']?.toString() ?? machineCode;
      }

      if (machineCode != null && machineCode.isNotEmpty) {
        machines.add({
          'Machine_ID': station['Machine_ID'] ?? station['WorkStation_ID'] ?? 0,
          'Machine_Code': machineCode,
          'Machine_Desc': machineDesc ?? machineCode,
          'WorkStation_ID': station['WorkStation_ID'],
          'WorkStation_Code': station['WorkStation_Code'],
          'Line_Code': selectedLine,
        });
        print('✅ Added machine: $machineCode');
      }
    }

    return machines;
  }

  // ✅ CREATE MACHINES FROM WORKSTATION DATA (when no separate machine data)
  void _createMachinesFromWorkStations() {
    print('🔄 Creating machines from WorkStation data...');

    for (var station in _availableStations) {
      if (station['WorkStation_Code'] != null && station['WorkStation_Code'].toString().isNotEmpty) {
        final workstationCode = station['WorkStation_Code'].toString();
        final workstationDesc = station['WorkStation_Desc']?.toString() ?? workstationCode;

        _availableMachines.add({
          'Machine_ID': station['WorkStation_ID'] ?? 0,
          'Machine_Code': workstationCode,
          'Machine_Desc': workstationDesc,
          'WorkStation_ID': station['WorkStation_ID'],
          'WorkStation_Code': workstationCode,
          'Line_Code': selectedLine,
        });
        print('✅ Created machine from workstation: $workstationCode');
      }
    }

    print('✅ Created ${_availableMachines.length} machines from workstations');
  }

  // ✅ TEMPORARY LINES DATA
  void _useTemporaryLines() {
    print('🔄 Using temporary lines data...');

    _availableLines = [
      {
        'Line_ID': 1,
        'Line_Code': 'Line 1',
        'Line_Desc': 'Production Line 1',
      },
      {
        'Line_ID': 2,
        'Line_Code': 'Line 2',
        'Line_Desc': 'Production Line 2',
      },
      {
        'Line_ID': 3,
        'Line_Code': 'Line 3',
        'Line_Desc': 'Production Line 3',
      },
    ];

    selectedLine = _availableLines.first['Line_Code']?.toString();
    print('✅ Temporary lines loaded: ${_availableLines.length}');
  }

  // ✅ TEMPORARY STATIONS/MACHINES DATA
  void _useTemporaryStations() {
    print('🔄 Using temporary stations data...');

    _availableStations = [
      {
        'WorkStation_ID': 1,
        'WorkStation_Code': 'M-101',
        'WorkStation_Desc': 'Machine 101',
      },
      {
        'WorkStation_ID': 2,
        'WorkStation_Code': 'M-102',
        'WorkStation_Desc': 'Machine 102',
      },
      {
        'WorkStation_ID': 3,
        'WorkStation_Code': 'M-103',
        'WorkStation_Desc': 'Machine 103',
      },
      {
        'WorkStation_ID': 4,
        'WorkStation_Code': 'M-104',
        'WorkStation_Desc': 'Machine 104',
      },
      {
        'WorkStation_ID': 5,
        'WorkStation_Code': 'M-105',
        'WorkStation_Desc': 'Machine 105',
      },
      {
        'WorkStation_ID': 6,
        'WorkStation_Code': 'M-106',
        'WorkStation_Desc': 'Machine 106',
      },
    ];

    _createMachinesFromWorkStations();
    print('✅ Temporary stations loaded: ${_availableStations.length}');
    print('✅ Temporary machines loaded: ${_availableMachines.length}');
  }

  // ✅ INITIALIZE MACHINES WITH DATABASE DATA
  void _initializeAllMachines() {
    print('🔄 Initializing machines...');
    print('🔍 Available machines count: ${_availableMachines.length}');

    for (var machine in _availableMachines) {
      final machineCode = machine['Machine_Code']?.toString();
      if (machineCode != null && machineCode.isNotEmpty) {
        _initializeMachine(machineCode);
        print('✅ Initialized machine: $machineCode');
      }
    }
    print('✅ Total initialized machines: ${machineCurrentStatus.length}');
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
    machineCurrentRound[machineId] = 0;

    // initialize round details
    machineRoundDetails[machineId] = [];
  }

  // ✅ GET MACHINE CTQ STATUS
  bool isMachineCTQ(String machineId) {
    // Simple logic based on machine code - adjust as needed
    return machineId.contains('101') ||
        machineId.contains('103') ||
        machineId.contains('105') ||
        machineId.contains('107') ||
        machineId.contains('109');
  }

  // ✅ UPDATE INSPECTION PIECES BASED ON CTQ STATUS
  void updateInspectionPieces() {
    if (selectedMachine != null) {
      final isCTQ = isMachineCTQ(selectedMachine!);
      inspectionPieces = isCTQ ? 10 : 5;
      print('🔍 Updated inspection pieces: $inspectionPieces (CTQ: $isCTQ)');
      notifyListeners();
    }
  }

  // ✅ SELECT LINE AND LOAD ITS STATIONS
  void selectLine(String? line) async {
    if (line == null) return;

    selectedLine = line;
    selectedMachine = null;
    _availableStations = [];
    _availableMachines = [];

    print('🔄 Selecting line: $selectedLine');

    // Load stations for the selected line
    await _loadLineStations();

    // Set first machine as selected
    if (_availableMachines.isNotEmpty) {
      selectedMachine = _availableMachines.first['Machine_Code']?.toString();
      updateInspectionPieces();
      print('✅ Selected machine: $selectedMachine');
    } else {
      print('⚠️ No machines available for selected line');
    }

    notifyListeners();
  }

  // ✅ SELECT MACHINE
  void selectMachine(String machineId) {
    selectedMachine = machineId;
    updateInspectionPieces();
    print('✅ Machine selected: $machineId');
    notifyListeners();
  }

  // ✅ GET MACHINE DATA BY CODE
  Map<String, dynamic>? getMachineData(String machineCode) {
    return _availableMachines.firstWhere(
          (machine) => machine['Machine_Code'] == machineCode,
      orElse: () => {},
    );
  }

  // ✅ GET CURRENT ROUND FOR A MACHINE
  int getCurrentRound(String machineId) {
    return machineCurrentRound[machineId] ?? 0;
  }

  // ✅ GET NEXT ROUND FOR A MACHINE
  int getNextRound(String machineId) {
    int currentRound = getCurrentRound(machineId);
    return currentRound < 4 ? currentRound + 1 : 4;
  }

  // ✅ UPDATE ROUND STATUS AFTER INSPECTION
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
        Future.delayed(const Duration(seconds: 2), () {
          resetMachineRounds(machineId);
          notifyListeners();
        });
      }
    }
    calculateTotals();
    notifyListeners();
  }

  // ✅ RESET ALL ROUNDS FOR A MACHINE
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

    String inspectorName = authService.fullName ?? "Unknown Inspector";
    updateRoundStatus(selectedMachine!, newStatus, [], inspectorName);

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

      String inspectorName = authService.fullName ?? "Unknown Inspector";
      updateRoundStatus(selectedMachine!, status, selectedFaults, inspectorName);
    }
    closeInspectionForm();
  }

  void openInspectionSummary(BuildContext context, Map<String, dynamic> formData) {
    if (selectedMachine == null) return;

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

    String inspectorName = authService.fullName ?? "Unknown Inspector";
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

    String inspectorName = authService.fullName ?? "Unknown Inspector";
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

    String inspectorName = authService.fullName ?? "Unknown Inspector";
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
                        Navigator.pop(context);
                        showRoundDetails(context, machineId, i + 1);
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.black),
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

  // ✅ LOADING STATE
  bool get isLoading => _isLoading;
}