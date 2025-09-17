import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inspection Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: InspectionForm(
        machineId: "M-12345",
        inspectionType: "Inline",
        roundCount: 5,
        onClose: () {},
        onSubmit: (faults) {},
        onSummary: (data) {},
        currentFaults: const [],
        previousStatus: "Green",
        lineNumber: "Line 12",
      ),
    );
  }
}

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

class _InspectionFormState extends State<InspectionForm>
    with SingleTickerProviderStateMixin {
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
    "45-92-PO-SO-24-09343",
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
  bool _showMaintenanceNotes = false;

  // Form validation
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedFaults.addAll(widget.currentFaults);
    // Set default values
    _selectedShift = _shifts.first;
    _selectedOperation = _operations.first;
    _selectedOperator = widget.selectedOperator ?? _operators.first;

    // If it's a maintenance inspection, show maintenance notes by default
    if (widget.isMaintenanceInspection) {
      _showMaintenanceNotes = true;
    }

    // Initialize animations
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // Get filtered faults based on search query
  List<String> get _filteredFaults {
    if (_faultSearchQuery.isEmpty) {
      return widget.isMaintenanceInspection ? _maintenanceNotes : _allFaults;
    }
    final listToSearch =
    widget.isMaintenanceInspection ? _maintenanceNotes : _allFaults;
    return listToSearch
        .where(
          (item) => item.toLowerCase().contains(_faultSearchQuery.toLowerCase()),
    )
        .toList();
  }

  // Add a fault to the selected list
  void _addFault(String fault) {
    setState(() {
      if (!_selectedFaults.contains(fault)) {
        _selectedFaults.add(fault);
      }
    });
  }

  // Remove a fault from the selected list
  void _removeFault(int index) {
    setState(() {
      _selectedFaults.removeAt(index);
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // For maintenance inspections, require at least one note
    if ((_showMaintenanceNotes || widget.isMaintenanceInspection) &&
        _selectedFaults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please add at least one maintenance note"),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    // For regular inspections, require at least one fault if not maintenance mode
    if (!_showMaintenanceNotes &&
        !widget.isMaintenanceInspection &&
        _selectedFaults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              "Please add at least one fault or switch to maintenance mode"),
          backgroundColor: Colors.red[200],
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    // Prepare form data
    final formData = {
      'bundleNumber': _selectedBundle!,
      'operatorName': _selectedOperator!,
      'selectedFaults': _selectedFaults,
      'shift': _selectedShift!,
      'operation': _selectedOperation!,
      'isMaintenance': _showMaintenanceNotes || widget.isMaintenanceInspection,
    };

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Use the onSummary callback to navigate to summary screen
    widget.onSummary(formData);

    setState(() {
      _isSubmitting = false;
    });
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
              Colors.blue.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // App Bar
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.blue),
                        onPressed: () => widget.onClose(),
                      ),
                      Expanded(
                        child: Text(
                          widget.isMaintenanceInspection
                              ? "Maintenance Form"
                              : "Inline Inspection Form",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // For balance
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Machine Info Card
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Machine Information",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildInfoItem("Machine ID", widget.machineId),
                                    const SizedBox(width: 16),
                                    _buildInfoItem("Line", widget.lineNumber),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildInfoItem("Previous Status", widget.previousStatus),
                                    const SizedBox(width: 16),
                                    _buildInfoItem("Round", "${widget.roundCount}"),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Maintenance Toggle (only show for regular inspections)
                          if (!widget.isMaintenanceInspection) ...[
                            _buildCard(
                              child: SwitchListTile(
                                title: const Text(
                                  "Maintenance Inspection",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Switch to maintenance mode",
                                  style: TextStyle(color: Colors.grey),
                                ),
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
                                inactiveThumbColor: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Basic Information
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Basic Information",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildDropdownField(
                                  "Shift *",
                                  _selectedShift,
                                  _shifts,
                                      (value) {
                                    setState(() {
                                      _selectedShift = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a shift';
                                    }
                                    return null;
                                  },
                                ),
                                _buildDropdownField(
                                  "SO # *",
                                  _selectedBundle,
                                  _bundles,
                                      (value) {
                                    setState(() {
                                      _selectedBundle = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a bundle';
                                    }
                                    return null;
                                  },
                                ),
                                _buildDropdownField(
                                  "Operation *",
                                  _selectedOperation,
                                  _operations,
                                      (value) {
                                    setState(() {
                                      _selectedOperation = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select an operation';
                                    }
                                    return null;
                                  },
                                ),
                                _buildDropdownField(
                                  "Machine Operator *",
                                  _selectedOperator,
                                  _operators,
                                      (value) {
                                    setState(() {
                                      _selectedOperator = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select an operator';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Faults or Maintenance Notes Section
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _showMaintenanceNotes || widget.isMaintenanceInspection
                                      ? "Maintenance Notes"
                                      : "Faults",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Faults/Maintenance Dropdown with Search
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ExpansionTile(
                                    initiallyExpanded: _showFaultsDropdown,
                                    onExpansionChanged: (expanded) {
                                      setState(() {
                                        _showFaultsDropdown = expanded;
                                      });
                                    },
                                    title: Text(
                                      _showMaintenanceNotes || widget.isMaintenanceInspection
                                          ? "Select Maintenance Notes"
                                          : "Select Faults",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 16,
                                      ),
                                    ),
                                    trailing: Icon(
                                      _showFaultsDropdown ? Icons.expand_less : Icons.expand_more,
                                      color: Colors.blue,
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: TextField(
                                          onChanged: (value) {
                                            setState(() {
                                              _faultSearchQuery = value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: _showMaintenanceNotes || widget.isMaintenanceInspection
                                                ? "Search maintenance notes..."
                                                : "Search faults...",
                                            hintStyle: const TextStyle(color: Colors.grey),
                                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      Container(
                                        constraints: const BoxConstraints(maxHeight: 200),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _filteredFaults.length,
                                          itemBuilder: (context, index) {
                                            final item = _filteredFaults[index];
                                            return ListTile(
                                              title: Text(
                                                item,
                                                style: const TextStyle(color: Colors.black),
                                              ),
                                              onTap: () {
                                                _addFault(item);
                                              },
                                              trailing: _selectedFaults.contains(item)
                                                  ? const Icon(Icons.check, color: Colors.green)
                                                  : null,
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
                                    _showMaintenanceNotes || widget.isMaintenanceInspection
                                        ? "Selected Maintenance Notes:"
                                        : "Selected Faults:",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: List.generate(_selectedFaults.length, (index) {
                                      return Chip(
                                        label: Text(
                                          _selectedFaults[index],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: (_showMaintenanceNotes || widget.isMaintenanceInspection)
                                                ? Colors.blue[800]
                                                : Colors.red[800],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
                                        onDeleted: () => _removeFault(index),
                                        backgroundColor: (_showMaintenanceNotes || widget.isMaintenanceInspection)
                                            ? Colors.blue[100]
                                            : Colors.red[100],
                                      );
                                    }),
                                  ),

                                  // Fault count badge
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      "${_selectedFaults.length} ${_showMaintenanceNotes || widget.isMaintenanceInspection ? 'notes' : 'faults'} selected",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],

                                // Info message for maintenance
                                if (_showMaintenanceNotes || widget.isMaintenanceInspection) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.info,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Maintenance inspection will set machine status to BLUE",
                                            style: TextStyle(
                                              color: Colors.blue.shade800,
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
                          ),

                          const SizedBox(height: 20),

                          // Next Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                shadowColor: Colors.blue.withOpacity(0.3),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                                  : Text(
                                _showMaintenanceNotes || widget.isMaintenanceInspection
                                    ? "Review Maintenance"
                                    : "Review Inspection",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: child,
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
      String label,
      String? value,
      List<String> items,
      Function(String?) onChanged, {
        String? Function(String?)? validator,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            isExpanded: true,
            validator: validator,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
            borderRadius: BorderRadius.circular(12),
            dropdownColor: Colors.white,
          ),
        ],
      ),
    );
  }
}