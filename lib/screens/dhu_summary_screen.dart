import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DHUSummaryScreen extends StatefulWidget {
  const DHUSummaryScreen({Key? key}) : super(key: key);

  @override
  _DHUSummaryScreenState createState() => _DHUSummaryScreenState();
}

class _DHUSummaryScreenState extends State<DHUSummaryScreen> {
  final List<String> _lines = [
    "Master 1st Floor Sewing Line 1",
    "Master 1st Floor Sewing Line 2",
    "Master 1st Floor Sewing Line 3",
    "Master 1st Floor Sewing Line 4",
    "Master 1st Floor Sewing Line 5",
    "Master 1st Floor Sewing Line 6",
    "Master 1st Floor Sewing Line 7",
  ];

  DateTime _selectedDate = DateTime.now();
  String? _selectedLine;
  bool _isLoading = false;

  // Mock Inline DHU Data (replace with API later)
  Map<String, dynamic> _inlineDHUData = {
    "dhu": 4.2,
    "totalPieces": 1250,
    "defectivePieces": 52,
    "topOperations": [
      {"operation": "Side Seam Overlock Left", "defects": 15},
      {"operation": "Side Seam Overlock Right", "defects": 12},
      {"operation": "Sleeve Attachment", "defects": 8},
      {"operation": "Collar Attachment", "defects": 7},
      {"operation": "Hemming", "defects": 6},
      {"operation": "Pocket Attachment", "defects": 4},
    ]
  };

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _fetchDHUData() async {
    if (_selectedLine == null) return;

    setState(() {
      _isLoading = true;
    });

    // Simulated API delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DHU Summary"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade200,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date + Line Selection
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          const Text("Select Date:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _selectDate(context),
                            child: Text(
                              DateFormat('yyyy-MM-dd').format(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.line_style, size: 20),
                          const SizedBox(width: 8),
                          const Text("Select Line:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedLine,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              items: _lines.map((String line) {
                                return DropdownMenuItem<String>(
                                  value: line,
                                  child: Text(line),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedLine = newValue;
                                });
                              },
                              isExpanded: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedLine == null ? null : _fetchDHUData,
                          child: const Text("Get DHU"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // DHU Summary
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_selectedLine != null)
                Expanded(
                  child: ListView(
                    children: [
                      // Inline DHU Card Only
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Inline DHU Summary",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildDHUStatCard("DHU", "${_inlineDHUData['dhu']}%", Colors.blue),
                                  _buildDHUStatCard("Total Pieces", _inlineDHUData['totalPieces'].toString(), Colors.green),
                                  _buildDHUStatCard("Defective Pieces", _inlineDHUData['defectivePieces'].toString(), Colors.red),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                "Top 6 Faulty Operations",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ..._inlineDHUData['topOperations'].map<Widget>((op) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(op['operation']),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          op['defects'].toString(),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Center(
                  child: Text(
                    "Please select a line and date to view DHU summary",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDHUStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
