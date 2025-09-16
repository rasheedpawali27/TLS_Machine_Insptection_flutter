import 'package:flutter/material.dart';

class AddDefectScreen extends StatefulWidget {
  const AddDefectScreen({super.key});

  @override
  State<AddDefectScreen> createState() => _AddDefectScreenState();
}

class _AddDefectScreenState extends State<AddDefectScreen> {
  String? selectedOperation;
  String? selectedOperator;
  String? selectedFault;
  final List<String> selectedFaults = [];

  final List<String> operations = [
    'Operation 1: Sewing',
    'Operation 2: Cutting',
    'Operation 3: Finishing',
    'Operation 4: Quality Check',
  ];

  final List<String> operators = [
    'Operator 1 (ID: 001)',
    'Operator 2 (ID: 002)',
    'Operator 3 (ID: 003)',
    'Operator 4 (ID: 004)',
  ];

  final List<String> faults = [
    'Untrimmed thread',
    'Misaligned component',
    'Fabric crease',
    'Incorrect placement',
    'Broken stitch',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Defect'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Operation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: selectedOperation,
              hint: const Text('Select Operation'),
              isExpanded: true,
              items: operations.map((String operation) {
                return DropdownMenuItem<String>(
                  value: operation,
                  child: Text(operation),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOperation = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Machine Operator',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: selectedOperator,
              hint: const Text('Select Machine Operator'),
              isExpanded: true,
              items: operators.map((String operator) {
                return DropdownMenuItem<String>(
                  value: operator,
                  child: Text(operator),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOperator = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Faults',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: selectedFault,
              hint: const Text('Select Fault'),
              isExpanded: true,
              items: faults.map((String fault) {
                return DropdownMenuItem<String>(
                  value: fault,
                  child: Text(fault),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedFault = newValue;
                  if (newValue != null && !selectedFaults.contains(newValue)) {
                    selectedFaults.add(newValue);
                  }
                  selectedFault = null; // Reset dropdown
                });
              },
            ),
            const SizedBox(height: 16),
            if (selectedFaults.isNotEmpty) ...[
              const Text(
                'Selected Faults:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: selectedFaults.map((fault) {
                  return Chip(
                    label: Text(fault),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        selectedFaults.remove(fault);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Remarks:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _submitDefect('Rework'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                    child: const Text('Rework'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _submitDefect('Recovery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                    child: const Text('Recovery'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitDefect(String remark) {
    if (selectedOperation == null || selectedOperator == null || selectedFaults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select operation, operator, and at least one fault'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to add these defects?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Defects added as $remark'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}