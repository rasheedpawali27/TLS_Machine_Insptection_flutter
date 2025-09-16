/*
import 'package:flutter/material.dart';
import 'package:tls_inspection_machine/screens/dhu_summary_screen.dart';
import 'package:tls_inspection_machine/screens/endline_dashboard.dart';
import 'package:tls_inspection_machine/screens/round_wise_summary.dart';
import 'package:tls_inspection_machine/services/auth_service.dart';
import '../widgets/traffic_light_widget.dart';
import 'inspection_form.dart';
import 'statistics_view.dart';
import 'inline_inspection_summary.dart';

class MachineStatusScreen extends StatefulWidget {
  const MachineStatusScreen({Key? key}) : super(key: key);

  @override
  _MachineStatusScreenState createState() => _MachineStatusScreenState();
}

class _MachineStatusScreenState extends State<MachineStatusScreen> {
  final List<String> _lines = [
    "Line 1", "Line 2", "Line 3", "Line 4", "Line 5",
    "Line 6", "Line 7", "Line 8", "Line 9", "Line 10",
    "Line 11", "Line 12", "Line 13"
  ];

  String? _selectedLine;
  String _inspectionType = "Auto";
  int _roundCount = 0;
  int _inspectionPieces = 5; // Default to 5 pieces for non-CTQ
  final AuthService _authService = AuthService();

  // Each line has its own set of machines with CTQ status
  final Map<String, List<String>> _lineMachines = {
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

  // CTQ status for each machine (true = CTQ, false = Non-CTQ)
  final Map<String, bool> _machineCTQStatus = {
    "M-101": true,
    "M-102": false,
    "M-103": true,
    "M-104": false,
    "M-105": true,
    "M-106": false,
    "M-107": true,
    "M-108": false,
    "M-109": true,
    "M-110": false,
    "M-201": false,
    "M-202": true,
    "M-203": false,
    "M-204": true,
    "M-205": false,
    "M-206": true,
    "M-207": false,
    "M-208": true,
    "M-209": false,
    "M-210": true,
    // Add CTQ status for all other machines...
  };

  List<String> get _machines =>
      _selectedLine != null
          ? _lineMachines[_selectedLine!] ?? []
          : [];

  String? _selectedMachine;
  int _currentView = 0; // 0 = Traffic Light View, 1 = Statistics View

  // Track status counts for each machine
  final Map<String, Map<String, int>> _machineStatusCounts = {};
  final Map<String, String> _machineCurrentStatus = {};
  final Map<String, DateTime> _machineLastUpdated = {};
  final Map<String, List<String>> _machineFaults = {};

  // Statistics counters
  int _totalRed = 0;
  int _totalYellow = 0;
  int _totalGreen = 0;
  int _totalBlue = 0;
  int _totalUpdated = 0;
  int _totalNotUpdated = 0;

  // For Inline Inspection Form
  bool _showInspectionForm = false;

  // Drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // Set the selected line based on the authenticated user's assigned line
    if (_authService.currentUser != null) {
      _selectedLine = _authService.currentUser!.assignedLine;
      if (_selectedLine != null && _machines.isNotEmpty) {
        _selectedMachine = _machines.first;
        _updateInspectionPieces(); // Set initial inspection pieces
      }
    }

    // Initialize data for all machines in all lines
    for (var line in _lines) {
      final machines = _lineMachines[line];
      if (machines != null) {
        for (var machine in machines) {
          _machineStatusCounts[machine] = {
            "red": 0,
            "yellow": 0,
            "green": 0,
            "blue": 0,
          };
          _machineCurrentStatus[machine] = "green";
          _machineLastUpdated[machine] = DateTime.now();
          _machineFaults[machine] = [];
        }
      }
    }
    _calculateTotals();
  }

  void _calculateTotals() {
    int red = 0,
        yellow = 0,
        green = 0,
        blue = 0,
        updated = 0,
        notUpdated = 0;
    final now = DateTime.now();

    _machineCurrentStatus.forEach((machine, status) {
      if (status == "red") red++;
      if (status == "yellow") yellow++;
      if (status == "green") green++;
      if (status == "blue") blue++;

      final lastUpdated = _machineLastUpdated[machine];
      if (lastUpdated != null && now
          .difference(lastUpdated)
          .inHours < 1) {
        updated++;
      } else {
        notUpdated++;
      }
    });

    setState(() {
      _totalRed = red;
      _totalYellow = yellow;
      _totalGreen = green;
      _totalBlue = blue;
      _totalUpdated = updated;
      _totalNotUpdated = notUpdated;
    });
  }

  // Update inspection pieces based on CTQ status
  void _updateInspectionPieces() {
    if (_selectedMachine != null) {
      final isCTQ = _machineCTQStatus[_selectedMachine!] ?? false;
      setState(() {
        _inspectionPieces = isCTQ ? 10 : 5;
      });
    }
  }

  void _updateStatus(String newStatus) {
    if (_selectedMachine == null) return;

    setState(() {
      _machineCurrentStatus[_selectedMachine!] = newStatus;
      _machineLastUpdated[_selectedMachine!] = DateTime.now();
      _machineStatusCounts[_selectedMachine!]![newStatus] =
          (_machineStatusCounts[_selectedMachine!]![newStatus] ?? 0) + 1;

      // If setting to blue (maintenance), clear all faults
      if (newStatus == "blue") {
        _machineFaults[_selectedMachine!] = [];
        // Automatically open inspection form for maintenance
        _showInspectionForm = true;
        // You might want to set a flag to indicate this is a maintenance inspection
      }

      _calculateTotals();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${_selectedMachine} status updated to $newStatus"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _selectMachine(String machineId) {
    setState(() {
      _selectedMachine = machineId;
      _updateInspectionPieces(); // Update pieces when machine changes
      _showInspectionForm = true;
    });
  }

  void _selectLine(String? line) {
    setState(() {
      _selectedLine = line;
      if (_selectedLine != null && _machines.isNotEmpty) {
        _selectedMachine = _machines.first;
        _updateInspectionPieces(); // Update pieces when line changes
      } else {
        _selectedMachine = null;
      }
    });
  }

  void _changeInspectionType(String type) {
    setState(() {
      _inspectionType = type;
      if (_inspectionType == "Auto") {
        // Auto mode: Set pieces based on CTQ status
        _updateInspectionPieces();
      } else {
        // Round mode: Reset to default 1 piece for manual round counting
        _roundCount = 1;
      }
    });
  }

  void _incrementRound() {
    if (_roundCount < 10) { // Reasonable upper limit
      setState(() {
        _roundCount++;
      });
    }
  }

  void _decrementRound() {
    if (_roundCount > 1) { // Minimum 1 piece
      setState(() {
        _roundCount--;
      });
    }
  }

  // Updated method to determine machine color based on number of faults
  Color _getMachineColor(String machineId) {
    final status = _machineCurrentStatus[machineId] ?? "green";

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

  // Updated method to determine machine icon based on number of faults
  IconData _getMachineIcon(String machineId) {
    final status = _machineCurrentStatus[machineId] ?? "green";

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

  // Check if machine is CTQ
  bool _isMachineCTQ(String machineId) {
    return _machineCTQStatus[machineId] ?? false;
  }

  void _switchView() {
    setState(() {
      _currentView = _currentView == 0 ? 1 : 0;
    });
  }

  void _closeInspectionForm() {
    setState(() {
      _showInspectionForm = false;
    });
  }

  void _submitInspectionForm(List<String> selectedFaults) {
    if (_selectedMachine != null) {
      setState(() {
        _machineFaults[_selectedMachine!] = selectedFaults;
        // Update status based on number of faults
        if (selectedFaults.isEmpty) {
          _machineCurrentStatus[_selectedMachine!] = "green";
        } else if (selectedFaults.length == 1) {
          _machineCurrentStatus[_selectedMachine!] = "yellow";
        } else {
          _machineCurrentStatus[_selectedMachine!] = "red";
        }
        _machineLastUpdated[_selectedMachine!] = DateTime.now();
        _calculateTotals();
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Inspection submitted for ${_selectedMachine}"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    _closeInspectionForm();
  }

  // Open inspection summary
  void _openInspectionSummary(Map<String, dynamic> formData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            InlineInspectionSummary(
              machineId: _selectedMachine!,
              bundleNumber: formData['bundleNumber'] ?? '',
              operatorName: formData['operatorName'] ?? '',
              inspectionType: _inspectionType,
              roundCount: _inspectionType == "Auto"
                  ? _inspectionPieces
                  : _roundCount,
              faults: formData['selectedFaults'] ?? [],
              previousStatus: _machineCurrentStatus[_selectedMachine!] ?? "red",
              shift: formData['shift'] ?? '',
              lineNumber: _selectedLine ?? "Line 1",
              operation: formData['operation'] ?? '',
              isMaintenance: formData['isMaintenance'] ?? false,
            ),
      ),
    ).then((result) {
      // Handle the result when returning from inspection summary
      if (result != null && result is Map<String, dynamic>) {
        _handleInspectionResult(result);
      }
    });
  }

  // Handle inspection result from summary screen
  void _handleInspectionResult(Map<String, dynamic> result) {
    final List<String> faults = result['faults'];
    final String machineId = result['machineId'];
    final String status = _getMachineStatusBasedOnFaults(faults);

    setState(() {
      _machineFaults[machineId] = faults;
      _machineCurrentStatus[machineId] = status;
      _machineLastUpdated[machineId] = DateTime.now();
      _calculateTotals();
    });

    // Show defects summary after a small delay to ensure the UI is updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDefectsSummary(faults, status);
    });
  }

  // Helper method to determine status based on number of faults
  String _getMachineStatusBasedOnFaults(List<String> faults) {
    if (faults.isEmpty) {
      return "green";
    } else if (faults.length == 1) {
      return "yellow";
    } else {
      return "red";
    }
  }

  // Show defects summary dialog
  void _showDefectsSummary(List<String> faults, String status) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Inspection Result: ${status.toUpperCase()}'),
            content: faults.isEmpty
                ? const Text('No defects found')
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Defects found:'),
                const SizedBox(height: 10),
                ...faults.map((fault) => Text('• $fault')).toList(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // Fix all faults for a machine
  void _fixMachineFaults(String machineId) {
    setState(() {
      _machineFaults[machineId] = [];
      _machineCurrentStatus[machineId] = "green";
      _machineLastUpdated[machineId] = DateTime.now();
      _calculateTotals();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("All faults fixed for $machineId"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Fix a specific fault for a machine
  void _fixSpecificFault(String machineId, String fault) {
    setState(() {
      _machineFaults[machineId]?.remove(fault);
      // Update status based on number of remaining faults
      final remainingFaults = _machineFaults[machineId]?.length ?? 0;
      if (remainingFaults == 0) {
        _machineCurrentStatus[machineId] = "green";
      } else if (remainingFaults == 1) {
        _machineCurrentStatus[machineId] = "yellow";
      } else {
        _machineCurrentStatus[machineId] = "red";
      }
      _machineLastUpdated[machineId] = DateTime.now();
      _calculateTotals();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Fault '$fault' fixed for $machineId"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Show fix fault dialog on long press
  void _showFixFaultDialog(String machineId, String fault) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Fix Fault'),
            content: Text('Do you want to mark "$fault" as fixed?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _fixSpecificFault(machineId, fault);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Fix'),
              ),
            ],
          ),
    );
  }

  // Show machine details on long press with fix option
  void _showMachineDetails(String machineId) {
    final status = _machineCurrentStatus[machineId] ?? "green";
    final lastUpdated = _machineLastUpdated[machineId] ?? DateTime.now();
    final faults = _machineFaults[machineId] ?? [];
    final statusCounts = _machineStatusCounts[machineId] ??
        {"red": 0, "yellow": 0, "green": 0, "blue": 0};
    final isCTQ = _isMachineCTQ(machineId);

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Machine Details: $machineId'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(_getMachineIcon(machineId),
                          color: _getMachineColor(machineId)),
                      const SizedBox(width: 8),
                      Text(
                        'Status: ${status.toUpperCase()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getMachineColor(machineId),
                        ),
                      ),
                      if (isCTQ) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.warning, color: Colors.red, size: 16),
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
                  Text('Line: $_selectedLine'),
                  const SizedBox(height: 10),
                  Text('Last Updated: ${_formatDate(lastUpdated)}'),
                  const SizedBox(height: 10),
                  Text('Operation Type: ${isCTQ
                      ? "CTQ (10 pieces)"
                      : "Non-CTQ (5 pieces)"}'),
                  const SizedBox(height: 10),
                  Text('Faults: ${faults.length}'),
                  if (faults.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text('Fault List:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...faults.map((fault) =>
                        GestureDetector(
                          onLongPress: () =>
                              _showFixFaultDialog(machineId, fault),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text('• $fault')),
                                const Icon(Icons.touch_app, size: 16,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        )),
                  ],
                  const SizedBox(height: 10),
                  const Text('Status History:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Red: ${statusCounts["red"]} times'),
                  Text('Yellow: ${statusCounts["yellow"]} times'),
                  Text('Green: ${statusCounts["green"]} times'),
                  Text('Blue: ${statusCounts["blue"]} times'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              if (faults.isNotEmpty && status != "blue")
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _fixMachineFaults(machineId);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                  child: const Text('Fix All'),
                ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _showInspectionForm = true;
                  });
                },
                child: const Text('Inspect'),
              ),
            ],
          ),
    );
  }

  // Helper function to format date without intl package
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day
        .toString().padLeft(2, '0')} ${date.hour.toString().padLeft(
        2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  // Navigation functions
  void _navigateToInlineInspection() {
    Navigator.pop(context); // Close drawer
    // Already on inline inspection screen
  }

  void _navigateToEndlineInspection() {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EndlineDashboardScreen()),
    );
  }

  void _navigateToGnuSummary() {
    Navigator.pop(context); // Close drawer
    // Add your GNU Summary navigation logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("GNU Summary Selected"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToRoundWiseSummary() {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoundWiseSummaryScreen()),
    );
  }

  void _navigateToOperationBulletin() {
    Navigator.pop(context); // Close drawer
    // Add your Operation Bulletin navigation logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Operation Bulletin Selected"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Interloop Denim - ${_authService.currentUser?.fullName ??
              'Machine Status'}",
          style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          if (_selectedLine != null && !_showInspectionForm)
            IconButton(
              icon: Icon(
                _currentView == 0 ? Icons.analytics : Icons.traffic,
                size: 30,
                color: Colors.white,
              ),
              onPressed: _switchView,
              tooltip: _currentView == 0
                  ? 'Show Statistics'
                  : 'Show Traffic Light',
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade600,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: _showInspectionForm
            ? InspectionForm(
          machineId: _selectedMachine!,
          inspectionType: _inspectionType,
          roundCount: _inspectionType == "Auto"
              ? _inspectionPieces
              : _roundCount,
          onClose: _closeInspectionForm,
          onSubmit: _submitInspectionForm,
          onSummary: _openInspectionSummary,
          currentFaults: _machineFaults[_selectedMachine!] ?? [],
          previousStatus: _machineCurrentStatus[_selectedMachine!] ?? "red",
          lineNumber: _selectedLine ?? "Line 1",
          isMaintenanceInspection: _machineCurrentStatus[_selectedMachine!] == "blue",
        )
            : (_selectedLine == null
            ? _buildLineSelectionView()
            : (_currentView == 0
            ? _buildTrafficLightView()
            : StatisticsView(
          machines: _machines,
          machineCurrentStatus: _machineCurrentStatus,
          machineLastUpdated: _machineLastUpdated,
          machineFaults: _machineFaults,
          totalRed: _totalRed,
          totalYellow: _totalYellow,
          totalGreen: _totalGreen,
          totalBlue: _totalBlue,
          totalUpdated: _totalUpdated,
          totalNotUpdated: _totalNotUpdated,
        ))),
      ),
      floatingActionButton: _selectedLine != null && _currentView == 0 &&
          !_showInspectionForm
          ? _buildStatusButtons()
          : null,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.blue[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[800],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/images/login.png", width: 170),
                  const SizedBox(height: 15),
                  Text(
                    '${_authService.currentUser?.fullName ?? 'User'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Line: ${_authService.currentUser?.assignedLine ??
                        'Not assigned'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.blue),
              title: const Text('Inline Inspection'),
              onTap: _navigateToInlineInspection,
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: Colors.blue),
              title: const Text('Endline Inspection'),
              onTap: _navigateToEndlineInspection,
            ),
            ListTile(
              leading: const Icon(Icons.summarize, color: Colors.blue),
              title: const Text('DHU Summary'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DHUSummaryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.blue),
              title: const Text('Round Wise Summary'),
              onTap: _navigateToRoundWiseSummary,
            ),
            ListTile(
              leading: const Icon(Icons.article, color: Colors.blue),
              title: const Text('Operation Bulletin'),
              onTap: _navigateToOperationBulletin,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Add settings navigation
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineSelectionView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(20),
        width: MediaQuery
            .of(context)
            .size
            .width * 0.8,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 3,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Welcome, ${_authService.currentUser?.fullName ?? 'User'}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Assigned Line: ${_authService.currentUser?.assignedLine ??
                  'Not assigned'}",
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.factory,
              size: 60,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            if (_authService.currentUser != null)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedLine = _authService.currentUser!.assignedLine;
                    if (_selectedLine != null && _machines.isNotEmpty) {
                      _selectedMachine = _machines.first;
                      _updateInspectionPieces();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Go to My Assigned Line'),
              ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedLine,
              decoration: InputDecoration(
                labelText: "Or Select Different Line",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _lines.map((String line) {
                return DropdownMenuItem<String>(
                  value: line,
                  child: Text(line),
                );
              }).toList(),
              onChanged: (String? newValue) {
                _selectLine(newValue);
              },
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficLightView() {
    if (_selectedMachine == null) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      );
    }

    final currentStatus = _machineCurrentStatus[_selectedMachine] ?? "green";
    final lastUpdated = _machineLastUpdated[_selectedMachine] ?? DateTime.now();
    final currentFaults = _machineFaults[_selectedMachine] ?? [];
    final isCTQ = _isMachineCTQ(_selectedMachine!);
    final statusCounts = _machineStatusCounts[_selectedMachine] ??
        {"red": 0, "yellow": 0, "green": 0, "blue": 0};

    return Column(
        children: [
    // Line and Inspection Selection
    Container(
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    color: Colors.white.withOpacity(0.15),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Row(
    children: [
    const Icon(Icons.line_style, color: Colors.white, size: 28),
    const SizedBox(width: 10),
    DropdownButton<String>(
    value: _selectedLine,
    dropdownColor: Colors.blue[700],
    icon: const Icon(
    Icons.arrow_drop_down, color: Colors.white, size: 28),
    style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    ),
    underline: Container(),
    items: _lines.map((String line) {
    return DropdownMenuItem<String>(
    value: line,
    child: Text(line),
    );
    }).toList(),
    onChanged: (String? newValue) {
    _selectLine(newValue);
    },
    ),
    ],
    ),
    Row(
    children: [
    const Text(
    "Inspection:",
    style: TextStyle(color: Colors.white, fontSize: 16),
    ),
    const SizedBox(width: 10),
    ChoiceChip(
    label: const Text("Auto"),
    selected: _inspectionType == "Auto",
    onSelected: (_) => _changeInspectionType("Auto"),
    selectedColor: Colors.blue[800],
    labelStyle: TextStyle(
    color: _inspectionType == "Auto" ? Colors.white : Colors
        .black,
    ),
    ),
    const SizedBox(width: 10),
    ChoiceChip(
    label: const Text("Round"),
    selected: _inspectionType == "Round",
    onSelected: (_) => _changeInspectionType("Round"),
    selectedColor: Colors.blue[800],
    labelStyle: TextStyle(
    color: _inspectionType == "Round" ? Colors.white : Colors
        .black,
    ),
    ),
    if (_inspectionType == "Auto") ...[
    const SizedBox(width: 10),
    Text(
    'Pieces: $_inspectionPieces',
    style: const TextStyle(color: Colors.white, fontSize: 16),
    ),
    if (isCTQ)
    const Icon(Icons.warning, color: Colors.red, size: 20),
    ] else
    if (_inspectionType == "Round") ...[
    const SizedBox(width: 10),
    IconButton(
    icon: const Icon(Icons.remove, color: Colors.white, size: 24),
    onPressed: _decrementRound,
    ),
    Container(
    padding: const EdgeInsets.symmetric(
    horizontal: 15, vertical: 8),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
    _roundCount.toString(),
    style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    IconButton(
    icon: const Icon(Icons.add, color: Colors.white, size: 24),
    onPressed: _incrementRound,
    ),
    ],
    ],
    ),
    ],
    ),
    ),

    // Main content with traffic light and faults
    Expanded(
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    // Traffic Light Section
    Expanded(
    flex: 2,
    child: Container(
    padding: const EdgeInsets.symmetric(
    vertical: 20, horizontal: 10),
    margin: const EdgeInsets.all(10),
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.15),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 15,
    spreadRadius: 3,
    )
    ],
    ),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    TrafficLightWidget(status: currentStatus),

    const SizedBox(height: 15),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    "Status: ${currentStatus.toUpperCase()}",
    style: const TextStyle(
    fontSize: 22,
    color: Colors.white,
    ),
    ),
    if (isCTQ) ...[
    const SizedBox(width: 10),
    const Icon(Icons.warning, color: Colors.red, size: 24),
    const SizedBox(width: 5),
    Text(
    'CTQ',
    style: TextStyle(
    color: Colors.red,
    fontWeight: FontWeight.bold,
    fontSize: 18,
    ),
    ),
    ],
    ],
    ),
    const SizedBox(height: 15),
    ElevatedButton(
    onPressed: () {
    setState(() {
    _showInspectionForm = true;
    });
    },
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue[800],
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    child: const Text('Start Inspection'),
    ),



    ],
    ),
    ),
    ),

    // Faults and Details Section
    Expanded(
    flex: 3,
    child: Container(
    margin: const EdgeInsets.only(top: 20, right: 20, bottom: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.15),
    borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    "Machine Details:",
    style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    ),
    ),
    const SizedBox(height: 20),

    // Machine Details
    Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    children: [
    Icon(_getMachineIcon(_selectedMachine!), color: _getMachineColor(_selectedMachine!)),
    const SizedBox(width: 10),
    Text(
    'Status: ${currentStatus.toUpperCase()}',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: _getMachineColor(_selectedMachine!),
    ),
    ),
    if (isCTQ) ...[
    const SizedBox(width: 15),
    const Icon(Icons.warning, color: Colors.red, size: 20),
    const SizedBox(width: 5),
    const Text(
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
    Text(
    "Machine: $_selectedMachine",
    style: const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    ),
    ),
    const SizedBox(height: 10),
    Text('Line: $_selectedLine'),
    const SizedBox(height: 10),
    Text('Last Updated: ${_formatDate(lastUpdated)}'),
    const SizedBox(height: 10),
    Text('Operation Type: ${isCTQ ? "CTQ (10 pieces)" : "Non-CTQ (5 pieces)"}'),
    const SizedBox(height: 10),
    Text(
    "Inspection: ${_inspectionType == "Auto"
    ? "Auto ($_inspectionPieces pieces)"
        : "Round ($_roundCount)"}",

    ),

    const SizedBox(height: 15),

    */
/* const Text('Status History:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Red: ${statusCounts["red"]} times'),
                            Text('Yellow: ${statusCounts["yellow"]} times'),
                            Text('Green: ${statusCounts["green"]} times'),
                            Text('Blue: ${statusCounts["blue"]} times'),*//*

    ],
    ),
    ),

    const SizedBox(height: 20),

    const Text(
    "Current Faults:",
    style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    ),
    ),
    const SizedBox(height: 20),

    currentFaults.isEmpty
    ? Expanded(
    child: Center(
    child: Text(
    currentStatus == "blue"
    ? "Machine is in maintenance"
        : "No faults reported",
    style: TextStyle(
    fontSize: 18,
    color: Colors.white.withOpacity(0.8),
    ),
    ),
    ),
    )
        : Expanded(
    child: ListView.builder(
    itemCount: currentFaults.length,
    itemBuilder: (context, index) {
    final fault = currentFaults[index];
    return GestureDetector(
    onLongPress: () =>
    _showFixFaultDialog(_selectedMachine!, fault),
    child: Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
    color: Colors.red.withOpacity(0.3),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Colors.red, width: 1.5),
    ),
    child: Row(
    children: [
    Expanded(
    child: Row(
    children: [
    Expanded(
    child: Text(
    fault,
    style: const TextStyle(
    color: Colors.white,
    fontSize: 16,
    ),
    ),
    ),
    Icon(
    Icons.touch_app,
    size: 18,
    color: Colors.white.withOpacity(0.8),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    );
    },
    ),
    ),
    if (currentFaults.isNotEmpty && currentStatus != "blue")
    Align(
    alignment: Alignment.bottomRight,
    child: Column(
    children: [
    ElevatedButton(
    onPressed: () =>
    _fixMachineFaults(_selectedMachine!),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
    textStyle: const TextStyle(fontSize: 16)),
    child: const Text('Fix All Faults'),
    ),

    ],
    ),

    ),
    ],
    ),
    ),
    )
    ],
    ),
    ),

  // Machine list at the bottom
  Container(
  height: 350,
  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  decoration: BoxDecoration(
  color: Colors.white.withOpacity(0.15),
  borderRadius: BorderRadius.circular(20),
  ),
  child: ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: _machines.isEmpty
  ? Center(
  child: Text(
  "No machines available for $_selectedLine",
  style: const TextStyle(
  color: Colors.white,
  fontSize: 16,
  ),
  ),
  )
      : GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 5,
  mainAxisSpacing: 6.0,
  crossAxisSpacing: 6.0,
  childAspectRatio: 0.9,
  ),
  padding: const EdgeInsets.all(10),
  itemCount: _machines.length,
  itemBuilder: (context, index) {
  final machine = _machines[index];
  final isCTQ = _isMachineCTQ(machine);
  return GestureDetector(
  onTap: () => _selectMachine(machine), // Click for details only
  onLongPress: () {
  _selectMachine(machine);
  setState(() {
  _showInspectionForm = true; // Long press for inspection
  });
  },
  child: Container(
  margin: const EdgeInsets.all(3),
  decoration: BoxDecoration(
  color: _getMachineColor(machine),
  borderRadius: BorderRadius.circular(10),
  boxShadow: [
  BoxShadow(
  color: Colors.black.withOpacity(0.4),
  blurRadius: 4,
  spreadRadius: 1,
  )
  ],
  border: _selectedMachine == machine
  ? Border.all(color: Colors.white, width: 2)
      : null,
  ),
  child: Stack(
  children: [
  Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
  // Machine image with fallback to icon
  Container(
  height: 50,
  width: 50,
  decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(6),
  color: Colors.white.withOpacity(0.2),
  ),
  child: ClipRRect(
  borderRadius: BorderRadius.circular(6),
  child: Image.asset(
  "assets/images/machine.png",
  color: Colors.white,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
  return Icon(
  _getMachineIcon(machine),
  color: Colors.white,
  size: 30,
  );
  },
  ),
  ),
  ),
  const SizedBox(height: 6),
  Text(
  machine,
  style: const TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontSize: 12,
  ),
  textAlign: TextAlign.center,
  ),
  ],
  ),
  if (isCTQ)
  Positioned(
  top: 3,
  right: 3,
  child: Container(
  padding: const EdgeInsets.all(3),
  decoration: BoxDecoration(
  color: Colors.red,
  borderRadius: BorderRadius.circular(8),
  ),
  child: const Text(
  'CTQ',
  style: TextStyle(
  color: Colors.white,
  fontSize: 8,
  fontWeight: FontWeight.bold,
  ),
  ),
  ),
  ),
  Positioned(
  bottom: 3,
  left: 3,
  child: Text(
  "Tap: Select\nLong Press: Inspect",
  style: TextStyle(
  color: Colors.white.withOpacity(0.7),
  fontSize: 7,
  ),
  ),
  ),
  ],
  ),
  ),
  );
  },
  ),
  ),
  ),

// ... (rest of the code remains the same)
}*/
