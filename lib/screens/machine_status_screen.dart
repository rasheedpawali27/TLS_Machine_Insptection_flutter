import 'package:flutter/material.dart';
import 'package:tls_inspection_machine/screens/dhu_summary_screen.dart';
import 'package:tls_inspection_machine/screens/endline_dashboard.dart';
import 'package:tls_inspection_machine/screens/opration_bulletin.dart';
import 'package:tls_inspection_machine/screens/round_wise_summary.dart';
import 'package:tls_inspection_machine/screens/setting.dart';
import 'package:tls_inspection_machine/services/auth_service.dart';
import '../widgets/traffic_light_widget.dart';
import 'inspection_form.dart';
import 'statistics_view.dart';
import 'inline_inspection_summary.dart';
import 'machine_status_controller.dart';
import 'machine_status_widgets.dart';

class MachineStatusScreen extends StatefulWidget {
  const MachineStatusScreen({Key? key}) : super(key: key);

  @override
  _MachineStatusScreenState createState() => _MachineStatusScreenState();
}

class _MachineStatusScreenState extends State<MachineStatusScreen> {
  final MachineStatusController _controller = MachineStatusController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _controller.initState();
    setState(() {
      _isInitializing = false;
    });
  }

  // Navigation functions
  void _navigateToInlineInspection() {
    Navigator.pop(context);
  }

  void _navigateToEndlineInspection() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EndlineDashboardScreen()),
    );
  }

  void _navigateToDHUSummary() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DHUSummaryScreen()),
    );
  }

  void _navigateToRoundWiseSummary() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoundWiseSummaryScreen()),
    );
  }

  void _navigateToOperationBulletin() {
    Navigator.pop(context);
   /* Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OperationBulletinScreen()),
    );*/
  }

  void _navigateToSettings() {
    Navigator.pop(context);
   /* Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.blue[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Loading Production Data...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Fetching lines and machines from database',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "INLINE INSPECTION DENIM - ${_controller.authService.fullName ?? 'Machine Status'}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          if (_controller.selectedLine != null && !_controller.showInspectionForm)
            IconButton(
              icon: Icon(
                _controller.currentView == 0 ? Icons.analytics : Icons.traffic,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _controller.switchView();
                });
              },
              tooltip: _controller.currentView == 0
                  ? 'Show Statistics'
                  : 'Show Traffic Light',
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _controller.authService.logout();
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
        child: _controller.showInspectionForm
            ? InspectionForm(
          machineId: _controller.selectedMachine!,
          inspectionType: _controller.inspectionType,
          roundCount: _controller.inspectionType == "Auto"
              ? _controller.inspectionPieces
              : _controller.roundCount,
          onClose: () {
            setState(() {
              _controller.closeInspectionForm();
            });
          },
          onSubmit: (List<String> selectedFaults) {
            setState(() {
              _controller.submitInspectionForm(selectedFaults);
            });
          },
          onSummary: (Map<String, dynamic> formData) {
            _controller.openInspectionSummary(context, formData);
          },
          currentFaults: _controller.machineFaults[_controller.selectedMachine!] ?? [],
          previousStatus:
          _controller.machineCurrentStatus[_controller.selectedMachine!] ?? "red",
          lineNumber: _controller.selectedLine ?? "Line 1",
          isMaintenanceInspection:
          _controller.machineCurrentStatus[_controller.selectedMachine!] == "blue",
        )
            : (_controller.selectedLine == null
            ? _buildLineSelectionView()
            : (_controller.currentView == 0
            ? MachineStatusWidgets.buildTrafficLightView(_controller, context, setState)
            : StatisticsView(
          machines: _controller.machines,
          machineCurrentStatus: _controller.machineCurrentStatus,
          machineLastUpdated: _controller.machineLastUpdated,
          machineFaults: _controller.machineFaults,
          totalRed: _controller.totalRed,
          totalYellow: _controller.totalYellow,
          totalGreen: _controller.totalGreen,
          totalBlue: _controller.totalBlue,
          totalUpdated: _controller.totalUpdated,
          totalNotUpdated: _controller.totalNotUpdated,
        ))),
      ),
      floatingActionButton:
      _controller.selectedLine != null && _controller.currentView == 0 && !_controller.showInspectionForm
          ? MachineStatusWidgets.buildStatusButtons(_controller, setState)
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
              decoration: BoxDecoration(color: Colors.blue[800]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/images/login.png", width: 170),
                  const SizedBox(height: 15),
                  Text(
                    '${_controller.authService.fullName ?? 'User'}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    'User ID: ${_controller.authService.userId ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Line: ${_controller.authService.assignedLine ?? 'All Lines'}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    'Available Lines: ${_controller.authService.userLines.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
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
              onTap: _navigateToDHUSummary,
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
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text('Settings'),
              onTap: _navigateToSettings,
            ),
            // Database Info Section
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Database Info',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Current Line: ${_controller.selectedLine ?? 'None'}'),
                  Text('Available Lines: ${_controller.availableLines.length}'),
                  Text('Available Machines: ${_controller.availableMachines.length}'),
                  Text('User Access: ${_controller.authService.hasAccessToAllLines ? 'All Lines' : 'Specific Lines'}'),
                ],
              ),
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
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Welcome, ${_controller.authService.fullName ?? 'User'}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "User ID: ${_controller.authService.userId ?? 'N/A'}",
              style: TextStyle(fontSize: 16, color: Colors.blue[700]),
            ),
            const SizedBox(height: 5),
            Text(
              "Assigned Line: ${_controller.authService.assignedLine ?? 'All Lines'}",
              style: TextStyle(fontSize: 18, color: Colors.blue[700]),
            ),
            const SizedBox(height: 5),
            Text(
              "Available Lines: ${_controller.authService.userLines.length}",
              style: TextStyle(fontSize: 14, color: Colors.blue[600]),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.factory, size: 60, color: Colors.blue),
            const SizedBox(height: 20),

            // Go to Assigned Line Button
            if (_controller.authService.assignedLine != null)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller.selectedLine = _controller.authService.assignedLine;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const Text('Go to My Assigned Line'),
              ),

            const SizedBox(height: 20),

            // Line Selection Dropdown
            DropdownButtonFormField<String>(
              value: _controller.selectedLine,
              decoration: InputDecoration(
                labelText: "Select Production Line",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _controller.lineNames.map((String line) {
                return DropdownMenuItem<String>(
                  value: line,
                  child: Text(line),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _controller.selectLine(newValue);
                });
              },
              isExpanded: true,
            ),

            const SizedBox(height: 20),

            // Database Connection Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Database Connection:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: _controller.availableLines.isNotEmpty ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _controller.availableLines.isNotEmpty ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          color: _controller.availableLines.isNotEmpty ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Lines: ${_controller.availableLines.length}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'Machines: ${_controller.availableMachines.length}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'Access: ${_controller.authService.hasAccessToAllLines ? 'All Lines' : 'Specific Lines'}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}