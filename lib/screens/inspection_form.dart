import 'package:flutter/material.dart';

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
  final int initialRoundCount; // Add this parameter

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
    this.initialRoundCount = 1, // Default to 1
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
    "46-92-PO-SO-24-09344",
    "47-92-PO-SO-24-09345",
    "48-92-PO-SO-24-09346",
    "49-92-PO-SO-24-09347",
    "50-92-PO-SO-24-09348",
    "51-92-PO-SO-24-09349",
    "52-92-PO-SO-24-09350",
    "53-92-PO-SO-24-09351",
    "54-92-PO-SO-24-09352",
    "55-92-PO-SO-24-09353",
    "56-92-PO-SO-24-09354",
    "57-92-PO-SO-24-09355",
    "58-92-PO-SO-24-09356",
    "59-92-PO-SO-24-09357",
    "60-92-PO-SO-24-09358",
  ];
  final List<String> _operators = [
    "Ms. BUSHRA ANDLEEB",
    "Mr. AMIR KHAN",
    "Mr. ALI RAZA",
    "Ms. FATIMA KHAN",
    "Mr. AHMED ALI",
    "Mr. HABIB",
    "Mr. TAYYAB",
    "Mr. SAAD",
    "Mr. USMAN",
    "Mr. BILAL",
    "Mr. ZAIN",
    "Mr. FARHAN",
    "Mr. HARIS",
    "Mr. KASHIF",
    "Mr. NADEEM",
    "Mr. REHAN",
    "Mr. SALEEM",
    "Mr. TARIQ",
    "Mr. WAQAS",
    "Mr. YASIR",
    "Mr. ZEESHAN",
    "Mr. AHSAN",
    "Mr. FAISAL",
    "Mr. GHAFFAR",
    "Mr. IMRAN",
  ];
  final List<String> _shifts = ["Morning", "Evening", "Night"];

  final List<String> _operations = [
    "Patch pocket making",
    "Patch pocket attach",
    "Yoke attach",
    "Back rise join",
    "Front pocket making",
    "Coin pocket attach",
    "Pocket bag attach",
    "Pocket facing join",
    "Fly attach",
    "Zipper attach",
    "Front rise join",
    "Side seam join",
    "Inseam join",
    "Waistband making",
    "Waistband attach",
    "Belt loop making",
    "Belt loop attach",
    "Bottom hem",
    "Button attach",
    "Rivet attach",
    "Bartack",
    "Label attach",
    "Tag pinning",
    "Quality check",
    "Packing",
    "Ironing",
    "Folding",
    "Trimming",
    "Thread cutting",
    "Final inspection"
  ];

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
    "SR012 - Missing Warning Label - Safety & Regulatory - Critical",
    "SR013 - Small Parts Detached - Safety & Regulatory - Critical",
    "SR014 - Sharp Points or Edges - Safety & Regulatory - Critical",
    "SR015 - Lead Content Exceeded - Safety & Regulatory - Critical",
    "SR016 - Phthalates Content Exceeded - Safety & Regulatory - Critical",
    "SR017 - Flammability Standard Failed - Safety & Regulatory - Critical",
    "SR018 - Choking Hazard - Safety & Regulatory - Critical",
    "SR019 - Strangulation Hazard - Safety & Regulatory - Critical",
    "SR020 - Entrapment Hazard - Safety & Regulatory - Critical",
    "CW001 - Broken Stitch - Construction & Workmanship - Major",
    "CW002 - Skipped Stitch - Construction & Workmanship - Major",
    "CW003 - Uneven Stitch - Construction & Workmanship - Major",
    "CW004 - Raw Edge - Construction & Workmanship - Major",
    "CW005 - Fabric Puckering - Construction & Workmanship - Major",
    "CW006 - Misaligned Pattern - Construction & Workmanship - Major",
    "CW007 - Incorrect Thread Color - Construction & Workmanship - Minor",
    "CW008 - Loose Thread - Construction & Workmanship - Minor",
    "CW009 - Missing Stitch - Construction & Workmanship - Major",
    "CW010 - Exposed Seam - Construction & Workmanship - Major",
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
    "Needle Replacement",
    "Bobbin Case Cleaning",
    "Tension Adjustment",
    "Feed Dog Adjustment",
    "Presser Foot Replacement",
    "Thread Guide Cleaning",
    "Oil Leakage Check",
    "Belt Tension Adjustment",
    "Motor Check",
    "Buttonholer Adjustment",
    "Zipper Foot Alignment",
    "Thread Breakage Issue",
    "Fabric Feeding Problem",
    "Stitch Formation Issue",
    "Noise Reduction Needed",
    "Vibration Check",
    "Speed Adjustment",
  ];

  final List<String> _selectedFaults = [];
  String _faultSearchQuery = '';
  bool _showFaultsDropdown = false;
  String? _selectedBundle;
  String? _selectedOperator;
  String? _selectedShift;
  String? _selectedOperation;
  bool _showMaintenanceNotes = false;

  // New variables for Auto/Round toggle and round counter
  String _inspectionMode = "Auto"; // Auto or Round
  int _roundCounter = 1;
  final int _maxRounds = 4;

  // Pagination variables for dropdowns
  final Map<String, int> _dropdownPages = {
    'bundles': 0,
    'operators': 0,
    'operations': 0,
    'faults': 0,
    'maintenance': 0,
  };
  final int _itemsPerPage = 10;

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

    // Set initial round counter based on the passed value
    _roundCounter = widget.initialRoundCount;

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

  // Get paginated items for dropdown
  List<String> _getPaginatedItems(List<String> items, String dropdownType) {
    final page = _dropdownPages[dropdownType] ?? 0;
    final start = page * _itemsPerPage;
    final end = (page + 1) * _itemsPerPage;

    if (start >= items.length) return [];

    return items.sublist(
      start,
      end > items.length ? items.length : end,
    );
  }

  // Check if there's a next page
  bool _hasNextPage(List<String> items, String dropdownType) {
    final page = _dropdownPages[dropdownType] ?? 0;
    return (page + 1) * _itemsPerPage < items.length;
  }

  // Check if there's a previous page
  bool _hasPreviousPage(String dropdownType) {
    final page = _dropdownPages[dropdownType] ?? 0;
    return page > 0;
  }

  // Navigate to next page
  void _nextPage(List<String> items, String dropdownType) {
    if (_hasNextPage(items, dropdownType)) {
      setState(() {
        _dropdownPages[dropdownType] = (_dropdownPages[dropdownType] ?? 0) + 1;
      });
    }
  }

  // Navigate to previous page
  void _previousPage(String dropdownType) {
    if (_hasPreviousPage(dropdownType)) {
      setState(() {
        _dropdownPages[dropdownType] = (_dropdownPages[dropdownType] ?? 0) - 1;
      });
    }
  }

  // Reset pagination when dropdown is closed
  void _resetPagination(String dropdownType) {
    setState(() {
      _dropdownPages[dropdownType] = 0;
    });
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
          (item) =>
          item.toLowerCase().contains(_faultSearchQuery.toLowerCase()),
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

  // Get current status based on selected faults
  String get _currentStatus {
    if (_showMaintenanceNotes || widget.isMaintenanceInspection) {
      return "Maintenance";
    }

    if (_selectedFaults.isEmpty) {
      return "Green";
    } else if (_selectedFaults.length == 1) {
      return "Yellow";
    } else {
      return "Red";
    }
  }

  // Get color for current status
  /*Color get _statusColor {
    switch (_currentStatus) {
      case "Green":
        return Colors.green;
      case "Yellow":
        return Colors.orange;
      case "Red":
        return Colors.red;
      case "Maintenance":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }*/

  // Get icon for current status
  /*IconData get _statusIcon {
    switch (_currentStatus) {
      case "Green":
        return Icons.check_circle;
      case "Yellow":
        return Icons.warning;
      case "Red":
        return Icons.error;
      case "Maintenance":
        return Icons.build;
      default:
        return Icons.help;
    }
  }*/

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Prepare form data
    final formData = {
      'bundleNumber': _selectedBundle!,
      'operatorName': _selectedOperator!,
      'selectedFaults': _selectedFaults,
      'shift': _selectedShift!,
      'operation': _selectedOperation!,
      'isMaintenance': _showMaintenanceNotes || widget.isMaintenanceInspection,
      'status': _currentStatus,
      'inspectionMode': _inspectionMode,
      'roundNumber': _roundCounter,
      'machineId': widget.machineId, // Include machine ID to track rounds
    };

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Use the onSummary callback to navigate to summary screen
    widget.onSummary(formData);

    setState(() {
      _isSubmitting = false;
    });
  }

  /*void _toggleMaintenanceNotes() {
    setState(() {
      _showMaintenanceNotes = !_showMaintenanceNotes;
      if (_showMaintenanceNotes) {
        _selectedFaults.clear();
      }
    });
  }*/

  // Increment round counter (with max limit)
  void _incrementRound() {
    if (_roundCounter < _maxRounds) {
      setState(() {
        _roundCounter++;
      });
    }
  }

  // Decrement round counter (with min limit)
  void _decrementRound() {
    if (_roundCounter > 1) {
      setState(() {
        _roundCounter--;
      });
    }
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
                      // Adding a placeholder for balance
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Auto/Round Toggle and Round Counter
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Inspection Mode",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Mode Selection
                      Row(
                        children: [
                          Expanded(
                            child: _buildModeButton("Auto", Icons.autorenew),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildModeButton("Round", Icons.repeat),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Round Counter (only visible in Round mode)
                      if (_inspectionMode == "Round")
                        Row(
                          children: [
                            const Text(
                              "Round: ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 20),
                                    onPressed: _decrementRound,
                                  ),
                                  Container(
                                    width: 40,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      _roundCounter.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 20),
                                    onPressed: _incrementRound,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "/ $_maxRounds",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
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
                                  icon: Icons.access_time,
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
                                  icon: Icons.inventory,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a bundle';
                                    }
                                    return null;
                                  },
                                  dropdownType: 'bundles',
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
                                  icon: Icons.settings,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select an operation';
                                    }
                                    return null;
                                  },
                                  dropdownType: 'operations',
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
                                  icon: Icons.person,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select an operator';
                                    }
                                    return null;
                                  },
                                  dropdownType: 'operators',
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
                                secondary: const Icon(
                                    Icons.build, color: Colors.blue),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Faults or Maintenance Notes Section
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _showMaintenanceNotes ||
                                          widget.isMaintenanceInspection
                                          ? Icons.build
                                          : Icons.warning,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _showMaintenanceNotes ||
                                          widget.isMaintenanceInspection
                                          ? "Maintenance Notes"
                                          : "Faults",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
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
                                        if (!expanded) {
                                          _resetPagination(
                                              widget.isMaintenanceInspection
                                                  ? 'maintenance'
                                                  : 'faults');
                                        }
                                      });
                                    },
                                    leading: Icon(
                                      _showMaintenanceNotes ||
                                          widget.isMaintenanceInspection
                                          ? Icons.note_add
                                          : Icons.search,
                                      color: Colors.blue,
                                    ),
                                    title: Text(
                                      _showMaintenanceNotes ||
                                          widget.isMaintenanceInspection
                                          ? "Select Maintenance Notes"
                                          : "Select Faults",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 16,
                                      ),
                                    ),
                                    trailing: Icon(
                                      _showFaultsDropdown
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Colors.blue,
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: TextField(
                                          onChanged: (value) {
                                            setState(() {
                                              _faultSearchQuery = value;
                                              _resetPagination(
                                                  widget.isMaintenanceInspection
                                                      ? 'maintenance'
                                                      : 'faults');
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: _showMaintenanceNotes ||
                                                widget.isMaintenanceInspection
                                                ? "Search maintenance notes..."
                                                : "Search faults...",
                                            hintStyle: const TextStyle(
                                                color: Colors.grey),
                                            prefixIcon: const Icon(
                                                Icons.search, color: Colors.grey),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(
                                                  12),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                            contentPadding: const EdgeInsets
                                                .symmetric(
                                                vertical: 12, horizontal: 16),
                                          ),
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                      Container(
                                        constraints: const BoxConstraints(
                                            maxHeight: 200),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: _getPaginatedItems(
                                                    _filteredFaults,
                                                    widget.isMaintenanceInspection
                                                        ? 'maintenance'
                                                        : 'faults').length,
                                                itemBuilder: (context, index) {
                                                  final item = _getPaginatedItems(
                                                      _filteredFaults,
                                                      widget.isMaintenanceInspection
                                                          ? 'maintenance'
                                                          : 'faults')[index];
                                                  return ListTile(
                                                    leading: Icon(
                                                      _showMaintenanceNotes ||
                                                          widget
                                                              .isMaintenanceInspection
                                                          ? Icons.notes
                                                          : Icons.warning_amber,
                                                      color: Colors.blue,
                                                      size: 20,
                                                    ),
                                                    title: Text(
                                                      item,
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                    onTap: () {
                                                      _addFault(item);
                                                    },
                                                    trailing: _selectedFaults
                                                        .contains(item)
                                                        ? const Icon(Icons.check,
                                                        color: Colors.green)
                                                        : null,
                                                  );
                                                },
                                              ),
                                            ),
                                            if (_filteredFaults.length >
                                                _itemsPerPage)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  border: Border(top: BorderSide(
                                                      color: Colors.grey.shade300)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.arrow_back,
                                                          size: 16),
                                                      onPressed: _hasPreviousPage(
                                                          widget
                                                              .isMaintenanceInspection
                                                              ? 'maintenance'
                                                              : 'faults')
                                                          ? () =>
                                                          _previousPage(widget
                                                              .isMaintenanceInspection
                                                              ? 'maintenance'
                                                              : 'faults')
                                                          : null,
                                                    ),
                                                    Text(
                                                      'Page ${(_dropdownPages[widget
                                                          .isMaintenanceInspection
                                                          ? 'maintenance'
                                                          : 'faults']! +
                                                          1)} of ${(_filteredFaults
                                                          .length / _itemsPerPage)
                                                          .ceil()}',
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.arrow_forward,
                                                          size: 16),
                                                      onPressed: _hasNextPage(
                                                          _filteredFaults, widget
                                                          .isMaintenanceInspection
                                                          ? 'maintenance'
                                                          : 'faults')
                                                          ? () =>
                                                          _nextPage(_filteredFaults,
                                                              widget
                                                                  .isMaintenanceInspection
                                                                  ? 'maintenance'
                                                                  : 'faults')
                                                          : null,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
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
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: List.generate(
                                        _selectedFaults.length, (index) {
                                      return Chip(
                                        label: Text(
                                          _selectedFaults[index],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: (_showMaintenanceNotes ||
                                                widget.isMaintenanceInspection)
                                                ? Colors.blue[800]
                                                : Colors.red[800],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        deleteIcon: const Icon(
                                            Icons.close, size: 18,
                                            color: Colors.white),
                                        onDeleted: () => _removeFault(index),
                                        backgroundColor: (_showMaintenanceNotes ||
                                            widget.isMaintenanceInspection)
                                            ? Colors.blue[100]
                                            : Colors.red[100],
                                      );
                                    }),
                                  ),

                                  // Fault count badge
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _showMaintenanceNotes || widget.isMaintenanceInspection
                                              ? Icons.notes
                                              : Icons.warning,
                                          size: 16,
                                          color: Colors.blue,
                                        ),

                                        const SizedBox(width: 4),
                                        Text(
                                          "${_selectedFaults
                                              .length} ${_showMaintenanceNotes ||
                                              widget.isMaintenanceInspection
                                              ? 'notes'
                                              : 'faults'} selected",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                // Info message for maintenance
                                if (_showMaintenanceNotes ||
                                    widget.isMaintenanceInspection) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.blue.shade200),
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
                            child: ElevatedButton.icon(
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
                              icon: _isSubmitting
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                                  : const Icon(Icons.arrow_forward),
                              label: Text(
                                _showMaintenanceNotes || widget
                                    .isMaintenanceInspection
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

  Widget _buildModeButton(String mode, IconData icon) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _inspectionMode = mode;
          if (mode != "Round") {
            _roundCounter = 1; // Reset round counter when not in Round mode
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _inspectionMode == mode ? Colors.blue : Colors.grey.shade300,
        foregroundColor: _inspectionMode == mode ? Colors.white : Colors.grey.shade700,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(mode),
        ],
      ),
    );
  }

  // Custom dropdown implementation with pagination
  Widget _buildDropdownField(String label,
      String? value,
      List<String> items,
      Function(String?) onChanged, {
        required IconData icon,
        String? Function(String?)? validator,
        String? dropdownType,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.blue,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            ],
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
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 16),
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
            menuMaxHeight: 300,
          ),
        ],
      ),
    );
  }

  // Helper function to get icon for status
  /*IconData _getStatusIcon(String status) {
    switch (status) {
      case "Green":
        return Icons.check_circle;
      case "Yellow":
        return Icons.warning;
      case "Red":
        return Icons.error;
      case "Maintenance":
        return Icons.build;
      default:
        return Icons.help;
    }
  }*/
}