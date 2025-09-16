import 'package:flutter/material.dart';
import 'inline_inspection_summary.dart';

class InspectionForm extends StatefulWidget {
  final String machineId;
  final String inspectionType;
  final int roundCount;
  final Function onClose;
  final Function(List<String>) onSubmit;
  final Function(Map<String, dynamic>) onSummary;
  final List<String> currentFaults;
  final String previousStatus;
  final String lineNumber;
  final String? selectedOperator;
  final bool isMaintenanceInspection;

  const InspectionForm({
    Key? key,
    required this.machineId,
    required this.inspectionType,
    required this.roundCount,
    required this.onClose,
    required this.onSubmit,
    required this.onSummary,
    required this.currentFaults,
    required this.previousStatus,
    required this.lineNumber,
    this.selectedOperator,
    this.isMaintenanceInspection = false,
  }) : super(key: key);

  @override
  _InspectionFormState createState() => _InspectionFormState();
}

class _InspectionFormState extends State<InspectionForm> {
  final List<String> _bundles = [
    "1-92-PO-SO-24-093432",
    "2-92-PO-SO-24-093432",
    "3-92-PO-SO-24-093431",
    "4-92-PO-SO-24-093434",
    "5-92-PO-SO-24-093436",
    "6-92-PO-SO-24-093437",
    "7-92-PO-SO-24-093433",
    "8-92-PO-SO-24-093564",
    "9-92-PO-SO-24-093432",
    "45-92-PO-SO-24-093432",
    "46-92-PO-SO-24-093432",
    "451-92-PO-SO-24-093432",
    "167-92-PO-SO-24-093432",
    "41-92-PO-SO-24-093432",
    "81-92-PO-SO-24-093432",
  ];
  final List<String> _operators = [
    "Ms. BUSHRA ANDLEEB",
    "Mr. AMIR KHAN",
    "Mr. ALI RAZA",
    "Ms. FATIMA KHAN",
    "Mr. AHMED ALI",
    "Mr. HABIB",
    "Mr. TAYYAB",
  ];
  final List<String> _sizes = ["7/2", "9/2", "11/2", "13/2"];
  final List<String> _styles = ["13231409", "13231410", "13231411"];
  final List<String> _colors = ["DRKSPHBAOP", "LTSPHBAOP", "MDSPHBAOP"];
  final List<String> _shifts = ["Morning", "Evening", "Night"];
  final List<String> _operations = ["Sewing"];

  // Fault management variables
  final List<String> _allFaults = [
    "COAS - High & Low - Construction & Workmanship - Major",
    "SR004 - Content Mining - Safety & Regulatory - Critical",
    "SR002 - Broken Needle - Safety & Regulatory - Critical",
    "SR003 - Cleuzers with Sharp Edges (Children) - Safety & Regulatory - Critical",
    "SR001 - Blood Stain - Safety & Regulatory - Critical",
    "SR006 - CPSIA-Tracking Label Missing - Safety & Regulatory - Critical",
    "SR008 - Filament Yarn as Sewing Thread - Safety & Regulatory - Critical",
    "SR011 - Improper Country of Origin Label - Safety & Regulatory - Critical",
  ];

  final List<String> _maintenanceNotes = [
    "Routine Maintenance",
    "Machine Calibration",
    "Part Replacement",
    "Lubrication Required",
    "Electrical Check",
    "Mechanical Adjustment",
    "Software Update",
    "Preventive Maintenance",
  ];

  final List<String> _selectedFaults = [];
  String _faultSearchQuery = '';
  bool _showFaultsDropdown = false;
  String? _selectedBundle;
  String? _selectedOperator;
  String? _selectedShift;
  String? _selectedOperation;
  String? _selectedMaintenanceNote;
  bool _showMaintenanceNotes = false;

  @override
  void initState() {
    super.initState();
    _selectedFaults.addAll(widget.currentFaults);
    // Set default values
    _selectedShift = _shifts.first;
    _selectedOperation = _operations.first;

    // If it's a maintenance inspection, show maintenance notes by default
    if (widget.isMaintenanceInspection) {
      _showMaintenanceNotes = true;
      _selectedMaintenanceNote = _maintenanceNotes.first;
    }
  }

  // Get filtered faults based on search query
  List<String> get _filteredFaults {
    if (_faultSearchQuery.isEmpty) {
      return widget.isMaintenanceInspection ? _maintenanceNotes : _allFaults;
    }
    final listToSearch = widget.isMaintenanceInspection
        ? _maintenanceNotes
        : _allFaults;
    return listToSearch
        .where(
          (item) =>
              item.toLowerCase().contains(_faultSearchQuery.toLowerCase()),
        )
        .toList();
  }

  // Add a fault to the selected list
  void _addFault(String fault) {
    setState(() {
      _selectedFaults.add(fault);
    });
  }

  // Remove a fault from the selected list
  void _removeFault(int index) {
    setState(() {
      _selectedFaults.removeAt(index);
    });
  }

  void _submitForm() {
    if (_selectedBundle == null || _selectedOperator == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select bundle and operator"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // For maintenance inspections, require at least one note
    if (widget.isMaintenanceInspection && _selectedFaults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add maintenance notes"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare form data
    final formData = {
      'bundleNumber': _selectedBundle!,
      'operatorName': _selectedOperator!,
      'selectedFaults': _selectedFaults,
      'shift': _selectedShift!,
      'operation': _selectedOperation!,
      'isMaintenance': widget.isMaintenanceInspection,
    };

    // Use the onSummary callback to navigate to summary screen
    widget.onSummary(formData);
  }

  void _toggleMaintenanceNotes() {
    setState(() {
      _showMaintenanceNotes = !_showMaintenanceNotes;
      if (_showMaintenanceNotes) {
        _selectedFaults.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text(
          widget.isMaintenanceInspection
              ? "Maintenance Form"
              : "Inline Inspection Form",
        ),
        backgroundColor: widget.isMaintenanceInspection
            ? Colors.blue[800]
            : Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => widget.onClose(),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Maintenance Toggle (only show for regular inspections)
                      if (!widget.isMaintenanceInspection) ...[
                        _buildFormSection("Inspection Type", [
                          SwitchListTile(
                            title: const Text("Maintenance Inspection"),
                            subtitle: const Text("Switch to maintenance mode"),
                            value: _showMaintenanceNotes,
                            onChanged: (value) {
                              setState(() {
                                _showMaintenanceNotes = value;
                                if (_showMaintenanceNotes) {
                                  _selectedFaults.clear();
                                }
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                        ]),
                      ],

                      // Basic Information
                      _buildFormSection("Basic Information", [
                        _buildDropdownField("Shift", _selectedShift, _shifts, (
                          value,
                        ) {
                          setState(() {
                            _selectedShift = value;
                          });
                        }),
                        _buildDropdownField(
                          "SO #",
                          _selectedBundle,
                          _bundles,
                          (value) {
                            setState(() {
                              _selectedBundle = value;
                            });
                          },
                        ),
                        _buildDropdownField(
                          "Operation",
                          _selectedOperation,
                          _operations,
                          (value) {
                            setState(() {
                              _selectedOperation = value;
                            });
                          },
                        ),
                        _buildDropdownField(
                          "Machine Operator",
                          _selectedOperator,
                          _operators,
                          (value) {
                            setState(() {
                              _selectedOperator = value;
                            });
                          },
                        ),
                      ]),

                      // Faults or Maintenance Notes Section
                      _buildFormSection(
                        _showMaintenanceNotes || widget.isMaintenanceInspection
                            ? "Maintenance Notes"
                            : "Faults",
                        [
                          // Faults/Maintenance Dropdown with Search
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ExpansionTile(
                              initiallyExpanded: _showFaultsDropdown,
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  _showFaultsDropdown = expanded;
                                });
                              },
                              title: Text(
                                _showMaintenanceNotes ||
                                        widget.isMaintenanceInspection
                                    ? "Select Maintenance Notes"
                                    : "Select Faults",
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText:
                                          _showMaintenanceNotes ||
                                              widget.isMaintenanceInspection
                                          ? "Search maintenance notes..."
                                          : "Search faults...",
                                      prefixIcon: const Icon(Icons.search),
                                      border: const OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _faultSearchQuery = value;
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 200,
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _filteredFaults.length,
                                    itemBuilder: (context, index) {
                                      final item = _filteredFaults[index];
                                      return ListTile(
                                        title: Text(item),
                                        onTap: () {
                                          _addFault(item);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Selected Faults/Maintenance Notes List
                          if (_selectedFaults.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              _showMaintenanceNotes ||
                                      widget.isMaintenanceInspection
                                  ? "Selected Maintenance Notes:"
                                  : "Selected Faults:",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _selectedFaults.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        (_showMaintenanceNotes ||
                                            widget.isMaintenanceInspection)
                                        ? Colors.blue[100]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color:
                                          (_showMaintenanceNotes ||
                                              widget.isMaintenanceInspection)
                                          ? Colors.blue[300]!
                                          : Colors.grey[400]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(_selectedFaults[index]),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 20),
                                        onPressed: () => _removeFault(index),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],

                          // Info message for maintenance
                          if (_showMaintenanceNotes ||
                              widget.isMaintenanceInspection) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Maintenance inspection will set machine status to BLUE",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        (_showMaintenanceNotes ||
                            widget.isMaintenanceInspection)
                        ? Colors.blue[800]
                        : Colors.blue[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _showMaintenanceNotes || widget.isMaintenanceInspection
                        ? "Review Maintenance"
                        : "Review Inspection",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }
}
