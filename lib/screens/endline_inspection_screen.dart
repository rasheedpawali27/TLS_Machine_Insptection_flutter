import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class EndlineInspectionScreen extends StatelessWidget {
  final String bundle;
  final int bundleQty;
  final String line;

  const EndlineInspectionScreen({
    Key? key,
    required this.bundle,
    required this.bundleQty,
    required this.line,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int defected = 0;
    int passed = bundleQty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Endline Inspection"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _summaryBox("Bundle Qty", "$bundleQty"),
                _summaryBox("Submitted Qty", "0"),
                _summaryBox("Pending Qty", "$bundleQty"),
              ],
            ),
            const SizedBox(height: 20),

            CircularPercentIndicator(
              radius: 100,
              lineWidth: 12,
              percent: passed / bundleQty,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Defected\n$defected/$bundleQty", style: const TextStyle(color: Colors.red, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text("Passed\n$passed/$bundleQty", style: const TextStyle(color: Colors.green, fontSize: 14)),
                ],
              ),
              progressColor: Colors.green,
              backgroundColor: Colors.red.shade100,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("Add Defect"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text("Fix Rework"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _summaryBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.blue)),
        ],
      ),
    );
  }
}
