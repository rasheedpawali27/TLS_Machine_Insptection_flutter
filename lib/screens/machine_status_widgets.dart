import 'package:flutter/material.dart';
import 'package:tls_inspection_machine/widgets/traffic_light_widget.dart';
import 'machine_status_controller.dart';

class MachineStatusWidgets {
  static Widget buildTrafficLightView(
    MachineStatusController controller,
    BuildContext context,
    void Function(void Function()) setState,
  ) {
    if (controller.selectedMachine == null) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      );
    }

    final currentStatus =
        controller.machineCurrentStatus[controller.selectedMachine] ?? "green";
    final lastUpdated =
        controller.machineLastUpdated[controller.selectedMachine] ??
        DateTime.now();
    final currentFaults =
        controller.machineFaults[controller.selectedMachine] ?? [];
    final isCTQ = controller.isMachineCTQ(controller.selectedMachine!);
    final statusCounts =
        controller.machineStatusCounts[controller.selectedMachine] ??
        {"red": 0, "yellow": 0, "green": 0, "blue": 0};

    // Get current round and round statuses
    final currentRound = controller.getCurrentRound(
      controller.selectedMachine!,
    );
    final roundStatuses =
        controller.machineRoundStatuses[controller.selectedMachine!] ??
        ["grey", "grey", "grey", "grey"];

    return Column(
      children: [
        // Line and Inspection Selection
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          color: Colors.white.withOpacity(0.15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.line_style, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: controller.selectedLine,
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
                    items: controller.lines.map((String line) {
                      return DropdownMenuItem<String>(
                        value: line,
                        child: Text(line),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        controller.selectLine(newValue);
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    "Inspection:",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Auto"),
                    selected: controller.inspectionType == "Auto",
                    onSelected: (_) {
                      setState(() {
                        controller.changeInspectionType("Auto");
                      });
                    },
                    selectedColor: Colors.blue[800],
                    labelStyle: TextStyle(
                      color: controller.inspectionType == "Auto"
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Round"),
                    selected: controller.inspectionType == "Round",
                    onSelected: (_) {
                      setState(() {
                        controller.changeInspectionType("Round");
                      });
                    },
                    selectedColor: Colors.blue[800],
                    labelStyle: TextStyle(
                      color: controller.inspectionType == "Round"
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  if (controller.inspectionType == "Auto") ...[
                    const SizedBox(width: 10),
                    Text(
                      'Pieces: ${controller.inspectionPieces}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    if (isCTQ)
                      const Icon(Icons.warning, color: Colors.red, size: 20),
                  ] else if (controller.inspectionType == "Round") ...[
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        setState(() {
                          controller.decrementRound();
                        });
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        controller.roundCount.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        setState(() {
                          controller.incrementRound();
                        });
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Round Status Display
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.white.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Current Round: ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$currentRound/4",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 20),
              ...List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _getStatusColor(roundStatuses[index]),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: roundStatuses[index] == "grey"
                            ? Colors.black
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Main content with traffic light and faults
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Traffic Light Section
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TrafficLightWidget(status: currentStatus),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            controller.showInspectionForm = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Start Inspection'),
                      ),
                    ],
                  ),
                ),
              ),

              // Faults and Details Section
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(top: 20, right: 20, bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Machine Details:",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Machine Details
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  controller.getMachineIcon(
                                    controller.selectedMachine!,
                                  ),
                                  color: controller.getMachineColor(
                                    controller.selectedMachine!,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Status: ${currentStatus.toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: controller.getMachineColor(
                                      controller.selectedMachine!,
                                    ),
                                  ),
                                ),
                                if (isCTQ) ...[
                                  const SizedBox(width: 15),
                                  const Icon(
                                    Icons.warning,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'CTQ',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Machine: ${controller.selectedMachine}",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('Line: ${controller.selectedLine}'),
                            const SizedBox(height: 10),
                            Text(
                              'Last Updated: ${controller.formatDate(lastUpdated)}',
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Operation Type: ${isCTQ ? "CTQ (10 pieces)" : "Non-CTQ (5 pieces)"}',
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Inspection: ${controller.inspectionType == 'Auto' ? 'Auto (${controller.inspectionPieces} pieces)' : 'Round (${controller.roundCount})'}",
                            ),

                            const SizedBox(height: 10),
                            Text(
                              "Current Round: $currentRound/4",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Current Faults:",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      currentFaults.isEmpty
                          ? Expanded(
                              child: Center(
                                child: Text(
                                  currentStatus == "blue"
                                      ? "Machine is in maintenance"
                                      : "No faults reported",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: currentFaults.length,
                                itemBuilder: (context, index) {
                                  final fault = currentFaults[index];
                                  return GestureDetector(
                                    onLongPress: () => showFixFaultDialog(
                                      context,
                                      controller,
                                      controller.selectedMachine!,
                                      fault,
                                      setState,
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.red,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    fault,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.touch_app,
                                                  size: 18,
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                      if (currentFaults.isNotEmpty && currentStatus != "blue")
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    controller.fixMachineFaults(
                                      controller.selectedMachine!,
                                    );
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 12,
                                  ),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                                child: const Text('Fix All Faults'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Machine list at the bottom
        Container(
          height: 350,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: controller.machines.isEmpty
                ? Center(
                    child: Text(
                      "No machines available for ${controller.selectedLine}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 6.0,
                          crossAxisSpacing: 6.0,
                          childAspectRatio: 0.9,
                        ),
                    padding: const EdgeInsets.all(10),
                    itemCount: controller.machines.length,
                    itemBuilder: (context, index) {
                      final machine = controller.machines[index];
                      final isCTQ = controller.isMachineCTQ(machine);

                      // Get round statuses for this machine
                      final roundStatuses =
                          controller.machineRoundStatuses[machine] ??
                          ["grey", "grey", "grey", "grey"];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            controller.selectMachine(machine);
                          });
                        },
                        onLongPress: () {
                          controller.showMachineDetails(context, machine);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: controller.getMachineColor(machine),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                            border: controller.selectedMachine == machine
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Machine image with fallback to icon - Made smaller
                                  Center(
                                    child: Container(
                                      height: 60, // Reduced from 80
                                      width: 60, // Reduced from 80
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.asset(
                                          "assets/images/machine.png",
                                          color: Colors.white,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  controller.getMachineIcon(
                                                    machine,
                                                  ),
                                                  color: Colors.white,
                                                  size: 24, // Reduced from 30
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Reduced from 6

                                  // Machine name - Smaller font
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: Text(
                                      machine,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10, // Reduced from 12
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  const SizedBox(height: 6),
                                  // Reduced from 8

                                  // ✅ Row of 4 round status cards - Made more compact
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(4, (index) {
                                        final status = roundStatuses[index];
                                        final roundNumber = index + 1;
                                        final isActive =
                                            roundNumber <= currentRound;

                                        return GestureDetector(
                                          onTap: () {
                                            if (isActive) {
                                              controller.showRoundDetails(
                                                context,
                                                machine,
                                                roundNumber,
                                              );
                                            }
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 2,
                                            ),
                                            // Reduced from 4
                                            width: 26,
                                            // Reduced from 30
                                            height: 36,
                                            // Reduced from 40
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(status),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              // Reduced from 8
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 1.5, // Reduced from 2
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius:
                                                      3, // Reduced from 4
                                                  offset: const Offset(
                                                    0,
                                                    1,
                                                  ), // Reduced from 2
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '$roundNumber',
                                                  style: TextStyle(
                                                    color: status == "grey"
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize:
                                                        12, // Reduced from 14
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                // Reduced from 4
                                                Icon(
                                                  _getStatusIcon(status),
                                                  size: 12, // Reduced from 16
                                                  color: status == "grey"
                                                      ? Colors.black54
                                                      : Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                              if (isCTQ)
                                Positioned(
                                  top: 2, // Reduced from 3
                                  right: 2, // Reduced from 3
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    // Reduced from 3
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(
                                        6,
                                      ), // Reduced from 8
                                    ),
                                    child: const Text(
                                      'CTQ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 7, // Reduced from 8
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  static IconData _getStatusIcon(String status) {
    switch (status) {
      case "red":
        return Icons.error;
      case "yellow":
        return Icons.warning;
      case "green":
        return Icons.check_circle;
      case "blue":
        return Icons.build;
      default:
        return Icons.circle;
    }
  }

  static Widget buildStatusButtons(
    MachineStatusController controller,
    void Function(void Function()) setState,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 12),
          buildStatusButton(
            "Blue",
            "blue",
            Colors.blue[600]!,
            controller,
            setState,
          ),
        ],
      ),
    );
  }

  static Widget buildStatusButton(
    String label,
    String status,
    Color color,
    MachineStatusController controller,
    void Function(void Function()) setState,
  ) {
    return FloatingActionButton(
      heroTag: label,
      backgroundColor: color,
      elevation: 6,
      onPressed: () {
        setState(() {
          controller.updateStatus(status);
        });
      },
      child: Text(
        label[0],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // FIX: Added `setState` so that UI refreshes after fault is removed
  static void showFixFaultDialog(
    BuildContext context,
    MachineStatusController controller,
    String machineId,
    String fault,
    void Function(void Function()) setState,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fix Fault'),
        content: Text('Do you want to mark "$fault" as fixed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                controller.fixSpecificFault(machineId, fault);
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Fix'),
          ),
        ],
      ),
    );
  }

  // Helper to map status → color
  static Color _getStatusColor(String status) {
    switch (status) {
      case "red":
        return Colors.red;
      case "yellow":
        return Colors.amber;
      case "green":
        return Colors.green;
      case "blue":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
