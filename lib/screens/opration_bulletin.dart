/*

import 'package:flutter/material.dart';
import 'package:tls_inspection_machine/services/auth_service.dart';

class OperationBulletinScreen extends StatefulWidget {
  const OperationBulletinScreen({Key? key}) : super(key: key);

  @override
  _OperationBulletinScreenState createState() => _OperationBulletinScreenState();
}

class _OperationBulletinScreenState extends State<OperationBulletinScreen> {
  final AuthService _authService = AuthService();
  final List<String> _lines = [
    "Line 1", "Line 2", "Line 3", "Line 4", "Line 5",
    "Line 6", "Line 7", "Line 8", "Line 9", "Line 10",
    "Line 11", "Line 12", "Line 13","Line 14" , "Line 15"
  ];

  String? _selectedLine;
  String? _selectedStyle;
  final Map<String, List<Operation>> _lineOperations = {};

  @override
  void initState() {
    super.initState();

    // Set the selected line based on the authenticated user's assigned line
    if (_authService.currentUser != null) {
      _selectedLine = _authService.currentUser!.assignedLine;
    }

    // Initialize sample data
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Sample operations data for each line
    for (var line in _lines) {
      List<Operation> operations = [];
      int operationCount = 10 + (_lines.indexOf(line) % 5); // Vary operation count

      for (int i = 1; i <= operationCount; i++) {
        bool isCTQ = i % 3 == 0; // Every third operation is CTQ

        operations.add(Operation(
          id: "OP-${_lines.indexOf(line) + 1}${i.toString().padLeft(2, '0')}",
          name: "Operation $i",
          machine: "M-${_lines.indexOf(line) + 1}${i.toString().padLeft(2, '0')}",
          smv: (1.5 + (i * 0.2)).toStringAsFixed(2),
          isCTQ: isCTQ,
          pieces: isCTQ ? 10 : 5, // CTQ operations require 10 pieces inspection
          operatorName: "Operator ${_lines.indexOf(line) + 1}$i",
        ));
      }

      _lineOperations[line] = operations;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "OPERATION BULLETIN - ${_authService.currentUser?.fullName ?? 'Operation Details'}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
        child: Column(
          children: [
            // Line selection section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              color: Colors.white.withOpacity(0.15),
              child: Row(
                children: [
                  const Icon(Icons.line_style, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  const Text(
                    "Select Line:",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedLine,
                    dropdownColor: Colors.blue[700],
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 28,
                    ),
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
                      setState(() {
                        _selectedLine = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Operation bulletin content
            Expanded(
              child: _selectedLine == null
                  ? _buildNoLineSelected()
                  : _buildOperationBulletin(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLineSelected() {
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
            const Icon(Icons.info_outline, size: 60, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "No Line Selected",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please select a production line to view its operation bulletin",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedLine = _authService.currentUser?.assignedLine;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Select My Assigned Line'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationBulletin() {
    final operations = _lineOperations[_selectedLine] ?? [];

    return Column(
      children: [
        // Header information
        Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Line: $_selectedLine",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Operations: ${operations.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        // Operations list
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: operations.isEmpty
                ? Center(
              child: Text(
                "No operations defined for $_selectedLine",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: operations.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withOpacity(0.2),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final operation = operations[index];
                return _buildOperationItem(operation, index + 1);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOperationItem(Operation operation, int sequence) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: operation.isCTQ
            ? Colors.red.withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: operation.isCTQ
            ? Border.all(color: Colors.red.withOpacity(0.5), width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sequence number
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: operation.isCTQ ? Colors.red : Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Text(
              sequence.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Operation details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        operation.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (operation.isCTQ)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "CTQ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  "Machine: ${operation.machine}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Operator: ${operation.operatorName}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SMV: ${operation.smv}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "Inspection: ${operation.pieces} pieces",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Operation {
  final String id;
  final String name;
  final String machine;
  final String smv;
  final bool isCTQ;
  final int pieces;
  final String operatorName;

  Operation({
    required this.id,
    required this.name,
    required this.machine,
    required this.smv,
    required this.isCTQ,
    required this.pieces,
    required this.operatorName,
  });
}
*/
