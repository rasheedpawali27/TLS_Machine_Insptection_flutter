// 📂 lib/screens/bundle_inspection_screen.dart

import 'package:flutter/material.dart';
import 'endline_inspection_screen.dart';

class BundleInspectionScreen extends StatefulWidget {
  final String line;
  final String bundle;

  const BundleInspectionScreen({
    super.key,
    required this.line,
    required this.bundle,
  });

  @override
  State<BundleInspectionScreen> createState() => _BundleInspectionScreenState();
}

class _BundleInspectionScreenState extends State<BundleInspectionScreen> {
  int _bundleQuantity = 68;

  final List<Map<String, dynamic>> _defects = [
    {
      'operation': 'Bottom Hem',
      'machine': 'M02-ABH010',
      'defects': 'C082 - Joint Out - Construction & Workmanship - Major - (Count: 2)'
    },
    {
      'operation': 'Cuff Hem Closed Left',
      'machine': 'M02-BH0007',
      'defects': 'C082 - Joint Out - Construction & Workmanship - Major - (Count: 2)'
    },
    {
      'operation': 'Neck Tape Twill Close With Labels',
      'machine': 'M02-SN0250',
      'defects': 'C185 - Uneven Edge - Construction & Workmanship - Major - (Count: 1)'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Endline Inspection'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBundleHeader(),
            const SizedBox(height: 20),

            _buildInfoTable(),
            const SizedBox(height: 20),

            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 20),

            _buildDefectsHeader(),
            const SizedBox(height: 10),

            ..._defects.map((defect) => _buildDefectItem(defect)).toList(),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EndlineInspectionScreen(
                        bundle: widget.bundle,
                        bundleQty: _bundleQuantity,
                        line: widget.line,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Action"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBundleHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bundle # ${widget.bundle}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 4),
        Text(
          'No of Pieces: $_bundleQuantity',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoTable() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _InfoRow(label: "Shift", value: "Morning"),
          _InfoRow(label: "Line Number", value: "Master 1st Floor Sewing Line 1"),
          _InfoRow(label: "Confirmation Order", value: "CO-24-00137"),
          _InfoRow(label: "Production Order", value: "PO-CP-24-000345"),
          _InfoRow(label: "Article", value: "S23f5KSNU3T3-ENEA"),
          _InfoRow(label: "Size", value: "128AD"),
          _InfoRow(label: "Lot", value: "1010YG2306095"),
          _InfoRow(label: "Color", value: "IB1670"),
        ],
      ),
    );
  }

  Widget _buildDefectsHeader() {
    return const Text(
      'Master 1st Floor Sewing Line 1 Defects Summary',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
    );
  }

  Widget _buildDefectItem(Map<String, dynamic> defect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Operation: ${defect['operation']}", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("Machine: ${defect['machine']}"),
          Text("Defects: ${defect['defects']}", style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
