// screens/round_wise_summary.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RoundWiseSummaryScreen extends StatefulWidget {
  const RoundWiseSummaryScreen({Key? key}) : super(key: key);

  @override
  _RoundWiseSummaryScreenState createState() => _RoundWiseSummaryScreenState();
}

class _RoundWiseSummaryScreenState extends State<RoundWiseSummaryScreen> {
  DateTime? _selectedDate;
  String? _selectedLine;
  List<dynamic> _roundsData = [];
  bool _isLoading = false;

  // ✅ Lines
  final List<Map<String, String>> _availableLines = List.generate(
    10,
        (index) => {
      "lineNumber": (index + 1).toString(),
      "lineName": "Master Sewing Line ${index + 1}",
    },
  );

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // ✅ Dummy data instead of API
  void _fetchRoundWiseSummary() {
    if (_selectedDate == null || _selectedLine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and line')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _roundsData = [
          {
            "roundNumber": 1,
            "inspections": [
              {
                "machine": "M02-EC0024",
                "operator": "Miss Maria Gulzar",
                "operation": "Neck Rib Making",
                "bundle": "7-J140AD",
                "co": "23-01316",
                "inspection": "5 Pcs",
                "faults": []
              },
              {
                "machine": "M02-DL0030",
                "operator": "Mr. Irfan Aslam",
                "operation": "Shoulder Attach",
                "bundle": "7-J140AD",
                "co": "23-01316",
                "inspection": "5 Pcs",
                "faults": []
              },
            ]
          },
          {
            "roundNumber": 2,
            "inspections": [
              {
                "machine": "M02-NP0010",
                "operator": "Ms. Ruqiya Babar",
                "operation": "Neck Rib Attach With Roller",
                "bundle": "7-J140AD",
                "co": "23-01316",
                "inspection": "10 Pcs",
                "faults": [
                  {"name": "Skip Stitch"},
                ]
              }
            ]
          },
        ];
        _isLoading = false;
      });
    });
  }

  Widget _buildInspectionCard(Map<String, dynamic> inspection) {
    return Card(
      color: Colors.green[100],
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Machine: ${inspection['machine']}"),
            Text("Operator: ${inspection['operator']}"),
            Text("Operation: ${inspection['operation']}"),
            Text("Bundle #: ${inspection['bundle']}"),
            Text("CO: ${inspection['co']}"),
            Text("Inspection: ${inspection['inspection']}"),
            if ((inspection['faults'] as List).isEmpty)
              const Text("No faults", style: TextStyle(color: Colors.black54))
            else ...[
              const Text("Faults:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...(inspection['faults'] as List)
                  .map<Widget>((f) => Text("• ${f['name']}"))
                  .toList()
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Round Wise Summary'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date + Line
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : DateFormat('dd-MMM-yyyy').format(_selectedDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedLine,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    hint: const Text('Select Line #'),
                    items: _availableLines.map((line) {
                      return DropdownMenuItem<String>(
                        value: line["lineNumber"],
                        child: Text(line["lineName"]!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLine = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Get Summary Button
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchRoundWiseSummary,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text('Get Summary', style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 24),

            // Results
            if (_roundsData.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _roundsData.length,
                  itemBuilder: (context, index) {
                    final round = _roundsData[index];
                    return Card(

                      child: ExpansionTile(
                        title: Text("Round ${round['roundNumber']}",),
                        children: [
                          ...(round['inspections'] as List)
                              .map<Widget>((insp) => _buildInspectionCard(insp))
                              .toList()
                        ],
                      ),
                    );
                  },
                ),
              )
            else if (!_isLoading)
              const Expanded(
                child: Center(
                  child: Text(
                    'No data available. Select date and line, then tap "Get Summary"',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
