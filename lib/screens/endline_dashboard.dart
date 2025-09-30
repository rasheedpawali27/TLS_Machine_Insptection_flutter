import 'package:flutter/material.dart';
import 'package:tls_inspection_machine/screens/endline_inspection_screen.dart';

class EndlineDashboardScreen extends StatefulWidget {
  const EndlineDashboardScreen({super.key});

  @override
  State<EndlineDashboardScreen> createState() => _EndlineDashboardScreenState();
}

class _EndlineDashboardScreenState extends State<EndlineDashboardScreen> {
  String? selectedLine;
  String? selectedBundle;

  final List<String> lines = [
    'Master 1st Floor Sewing Line 1',
    'Master 1st Floor Sewing Line 2',
    'Master 1st Floor Sewing Line 3',
    'Master 1st Floor Sewing Line 4',
    'Master 1st Floor Sewing Line 5',
    'Master 1st Floor Sewing Line 6',
    'Master 1st Floor Sewing Line 7',
  ];

  final List<String> bundles = [
    '1-SMALL -- #9f5fd06d-f8b6-4f3b2-ac97-abt3c66ec98a',
    '1-XXL -- 90838B21-22b4-45b1-a0f7-2ac99pbc02e6',
    '2-MEDIUM -- #a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    '2-LARGE -- #b2c3d4e5-f6g7-8901-bcde-f23456789012',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Endline Inspection'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line Selection
            const Text(
              'Line',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedLine,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('Select Line'),
                  ),
                  items: lines.map((String line) {
                    return DropdownMenuItem<String>(
                      value: line,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(line),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLine = newValue;
                      selectedBundle = null; // Reset bundle when line changes
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bundle QR Code Scanning Dropdown
            const Text(
              'Bundle QR Code Scanning',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedBundle,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('N/A'),
                  ),
                  items: selectedLine != null
                      ? bundles.map((String bundle) {
                    return DropdownMenuItem<String>(
                      value: bundle,
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(bundle),
                      ),
                    );
                  }).toList()
                      : null,
                  onChanged: selectedLine != null
                      ? (String? newValue) {
                    setState(() {
                      selectedBundle = newValue;
                    });
                  }
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // QR Code Scanner Button
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _scanQRCode,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan Bundle QR Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                    onPressed: _scanQRCode,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Test Button to Navigate to Next Screen
            if (selectedBundle != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EndlineInspectionScreen(
                          bundle: "Bundle #7",
                          bundleQty: 50,
                          line: "Line 10",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: const Text('Proceed to Inspection'),
                ),
              ),
            const SizedBox(height: 20),

            // Search Section
            const Text(
              'Search',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search bundles...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: Colors.blue.shade700),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 14.0),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            // Bundles List
            Expanded(
              child: ListView(
                children: bundles.map((b) => _buildBundleItem(b)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundleItem(String bundleInfo) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: const Icon(Icons.inventory_2_outlined, color: Colors.blue),
        title: Text(
          bundleInfo,
          style: const TextStyle(fontSize: 14),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.grey),
        onTap: () {
          setState(() {
            selectedBundle = bundleInfo;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EndlineInspectionScreen(
                bundle: "Bundle #7",
                bundleQty: 50,
                line: "Line 10",
              ),
            ),
          );

        },
      ),
    );
  }

  void _scanQRCode() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Code Scanning'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code_scanner, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              const Text('Point your camera at a bundle QR code to scan it.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleQRScanSuccess();
                },
                child: const Text('Simulate Scan'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _handleQRScanSuccess() {
    // Simulate a successful QR scan by auto-selecting the first bundle
    if (bundles.isNotEmpty) {
      setState(() {
        selectedBundle = bundles.first;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bundle scanned successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
