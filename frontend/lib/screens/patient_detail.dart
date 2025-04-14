import 'package:flutter/material.dart';
import '../widgets/patient_header.dart';
import '../widgets/patient_section.dart';
import '../widgets/patient_info_row.dart';
import '../widgets/doctor_note_tile.dart';
import '../widgets/edit_patient_dialog.dart';
import '../widgets/add_note_dialog.dart';
import '../widgets/update_note_dialog.dart';
import '../widgets/add_history_dialog.dart';
import '../models/patients.dart'; // Import the updated Patients class

class PatientDetail extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetail({super.key, required this.patient});

  @override
  State<PatientDetail> createState() => _PatientDetailState();
}

class _PatientDetailState extends State<PatientDetail> {
  late Map<String, dynamic> patientData;
  final Patients _patients = Patients(); // Instance of Patients class
  List<Map<String, dynamic>> patientHistory = []; // Dynamic history list
  bool isLoading = false; // Add loading state

  // Validation constants
  static const double minSystolic = 70; // Minimum reasonable systolic pressure
  static const double maxSystolic = 250; // Maximum reasonable systolic pressure
  static const double minDiastolic =
      40; // Minimum reasonable diastolic pressure
  static const double maxDiastolic =
      150; // Maximum reasonable diastolic pressure
  static const double minHeartRate = 30; // Minimum heart rate
  static const double maxHeartRate = 200; // Maximum heart rate
  static const double minRespiration = 5; // Minimum respiration rate
  static const double maxRespiration = 60; // Maximum respiration rate
  static const double minOxygen = 70; // Minimum blood oxygenation
  static const double maxOxygen = 100; // Maximum blood oxygenation

  @override
  void initState() {
    super.initState();
    patientData = Map.from(widget.patient);
    if (!patientData.containsKey("createdAt")) {
      patientData["createdAt"] = DateTime.now().toString();
    }
    if (!patientData.containsKey("updatedAt")) {
      patientData["updatedAt"] = patientData["createdAt"];
    }
    _fetchHistoryData(); // Fetch history on init
    // _fetchPatientData(); // Fetch initial patient data
  }

  @override
  void dispose() {
    _patients.dispose();
    super.dispose();
  }

  // Fetch patient history from API
  Future<void> _fetchHistoryData() async {
    setState(() {
      isLoading = true; // Show loader
    });
    try {
      final history = await _patients.fetchPatientHistory(
        patientData["patientId"]["_id"].toString(),
      );
      setState(() {
        patientHistory = history ?? []; // Update history list, handle null
        isLoading = false; // Hide loader
      });
    } catch (e) {
      if (e.toString().contains("404")) {
        setState(() {
          patientHistory = []; // Ensure empty list on 404
          isLoading = false; // Hide loader
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching history: $e")));
        setState(() {
          isLoading = false; // Hide loader on error
        });
      }
    }
  }

  // Fetch updated patient data (clinical data) using the API
  Future<void> _fetchPatientData() async {
    // ... (unchanged, keeping it commented as per your code)
  }

  // Refresh both patient data and history
  Future<void> _onRefresh() async {
    await Future.wait([_fetchPatientData(), _fetchHistoryData()]);
  }

  String _calculateStatus(Map<String, dynamic> data) {
    final systolic = data["systolicPressure"] as num? ?? 0; // in mmHg
    final diastolic = data["diastolicPressure"] as num? ?? 0; // in mmHg
    final oxygen = data["bloodOxygenation"] as num? ?? 0; // in percentage
    final heartRate = data["heartRate"] as num? ?? 0; // in bpm
    final respiratory =
        data["respirationRate"] as num? ?? 0; // in breaths per minute

    if (systolic < 90 ||
        systolic > 180 ||
        diastolic < 50 ||
        diastolic > 120 ||
        oxygen < 90 ||
        heartRate < 40 ||
        heartRate > 130 ||
        respiratory < 8 ||
        respiratory > 30) {
      return "Critical";
    } else if ((systolic >= 130 && systolic <= 180) ||
        (diastolic >= 80 && diastolic <= 120) ||
        (oxygen >= 90 && oxygen < 95) ||
        (respiratory >= 20 && respiratory <= 30) ||
        (respiratory >= 8 && respiratory < 12)) {
      return "Recovering";
    } else {
      return "Stable";
    }
  }

  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    final dateTime = DateTime.parse(dateTimeStr);
    return "${dateTime.month}/${dateTime.day}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}";
  }

  Future<void> _confirmDeletePatient(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Delete Patient",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Color(0xFF0277BD),
              ),
            ),
            content: const Text(
              "Are you sure you want to permanently delete this patient's clinical data? This action cannot be undone.",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _deleteClinicalData();
    }
  }

  Future<void> _deleteClinicalData() async {
    try {
      await _patients.deleteClinicalData(patientData["_id"].toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Patient and clinical data deleted successfully"),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting: $e")));
    }
  }

  void _showEditClinicalDataDialog(BuildContext context) {
    final systolicController = TextEditingController(
      text: patientData["systolicPressure"]?.toString() ?? "",
    );
    final diastolicController = TextEditingController(
      text: patientData["diastolicPressure"]?.toString() ?? "",
    );
    final respirationController = TextEditingController(
      text: patientData["respirationRate"]?.toString() ?? "",
    );
    final oxygenController = TextEditingController(
      text: patientData["bloodOxygenation"]?.toString() ?? "",
    );
    final heartController = TextEditingController(
      text: patientData["heartRate"]?.toString() ?? "",
    );

    final formKey = GlobalKey<FormState>(); // Form key for validation

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Edit Clinical Data",
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Systolic Pressure (mmHg)",
                        errorStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: systolicController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Systolic Pressure cannot be empty';
                        }
                        final numValue = num.tryParse(value);
                        if (numValue == null) {
                          return 'Systolic Pressure must be a number';
                        }
                        if (numValue < minSystolic || numValue > maxSystolic) {
                          return 'Must be between $minSystolic and $maxSystolic mmHg';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Diastolic Pressure (mmHg)",
                        errorStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: diastolicController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Diastolic Pressure cannot be empty';
                        }
                        final numValue = num.tryParse(value);
                        if (numValue == null) {
                          return 'Diastolic Pressure must be a number';
                        }
                        if (numValue < minDiastolic ||
                            numValue > maxDiastolic) {
                          return 'Diastolic Pressure must be between $minDiastolic and $maxDiastolic mmHg';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Respiration Rate (breaths/min)",
                        errorStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: respirationController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Respiration Rate cannot be empty';
                        }
                        final numValue = num.tryParse(value);
                        if (numValue == null) {
                          return 'Respiration Rate must be a number';
                        }
                        if (numValue < minRespiration ||
                            numValue > maxRespiration) {
                          return 'Respiration Rate must be between $minRespiration and $maxRespiration breaths/min';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Blood Oxygenation (%)",
                        errorStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: oxygenController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Blood Oxygenation cannot be empty';
                        }
                        final numValue = num.tryParse(value);
                        if (numValue == null) {
                          return 'Blood Oxygenation must be a number';
                        }
                        if (numValue < minOxygen || numValue > maxOxygen) {
                          return 'Blood Oxygenation must be between $minOxygen and $maxOxygen%';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Heart Rate (bpm)",
                        errorStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: heartController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Heart Rate cannot be empty';
                        }
                        final numValue = num.tryParse(value);
                        if (numValue == null) {
                          return 'Heart Rate must be a number';
                        }
                        if (numValue < minHeartRate ||
                            numValue > maxHeartRate) {
                          return 'Heart Rate must be between $minHeartRate and $maxHeartRate bpm';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    _updateClinicalData(
                      context,
                      systolicController,
                      diastolicController,
                      respirationController,
                      oxygenController,
                      heartController,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fix the errors in the form."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  Future<void> _updateClinicalData(
    BuildContext context,
    TextEditingController systolicController,
    TextEditingController diastolicController,
    TextEditingController respirationController,
    TextEditingController oxygenController,
    TextEditingController heartController,
  ) async {
    final updatedData = {
      "systolicPressure":
          num.tryParse(systolicController.text) ??
          patientData["systolicPressure"],
      "diastolicPressure":
          num.tryParse(diastolicController.text) ??
          patientData["diastolicPressure"],
      "respirationRate":
          num.tryParse(respirationController.text) ??
          patientData["respirationRate"],
      "bloodOxygenation":
          num.tryParse(oxygenController.text) ??
          patientData["bloodOxygenation"],
      "heartRate":
          num.tryParse(heartController.text) ?? patientData["heartRate"],
      "status": _calculateStatus({
        "systolicPressure": num.tryParse(systolicController.text),
        "diastolicPressure": num.tryParse(diastolicController.text),
        "bloodOxygenation": num.tryParse(oxygenController.text),
        "heartRate": num.tryParse(heartController.text),
        "respirationRate": num.tryParse(
          respirationController.text,
        ), // Fixed potential error
      }),
      "updatedAt": DateTime.now().toString(),
    };

    try {
      await _patients.updateClinicalData(
        patientData["_id"].toString(),
        updatedData,
      );
      setState(() {
        patientData = {...patientData, ...updatedData};
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Clinical data updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating clinical data: $e")),
      );
    }
  }

  void _showUpdateNoteDialog(BuildContext context, dynamic note) {
    final noteController = TextEditingController(text: note["note"]);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Edit Doctor's Note",
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            content: TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: "Note"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updatedNote = {
                    "note": noteController.text,
                    "createdAt": DateTime.now().toString(),
                  };
                  await _updateNote(note, updatedNote["note"] ?? "");
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _showEditHistoryDialog(
    BuildContext context,
    Map<String, dynamic> history,
  ) {
    final systolicController = TextEditingController(
      text: history["systolicPressure"]?.toString() ?? "",
    );
    final diastolicController = TextEditingController(
      text: history["diastolicPressure"]?.toString() ?? "",
    );
    final respirationController = TextEditingController(
      text: history["respirationRate"]?.toString() ?? "",
    );
    final oxygenController = TextEditingController(
      text: history["bloodOxygenation"]?.toString() ?? "",
    );
    final heartController = TextEditingController(
      text: history["heartRate"]?.toString() ?? "",
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Edit History",
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Systolic Pressure",
                    ),
                    keyboardType: TextInputType.number,
                    controller: systolicController,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Diastolic Pressure",
                    ),
                    keyboardType: TextInputType.number,
                    controller: diastolicController,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Respiration Rate",
                    ),
                    keyboardType: TextInputType.number,
                    controller: respirationController,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Blood Oxygenation",
                    ),
                    keyboardType: TextInputType.number,
                    controller: oxygenController,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "Heart Rate"),
                    keyboardType: TextInputType.number,
                    controller: heartController,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updatedHistory = {
                    "systolicPressure":
                        num.tryParse(systolicController.text) ??
                        history["systolicPressure"],
                    "diastolicPressure":
                        num.tryParse(diastolicController.text) ??
                        history["diastolicPressure"],
                    "respirationRate":
                        num.tryParse(respirationController.text) ??
                        history["respirationRate"],
                    "bloodOxygenation":
                        num.tryParse(oxygenController.text) ??
                        history["bloodOxygenation"],
                    "heartRate":
                        num.tryParse(heartController.text) ??
                        history["heartRate"],
                  };
                  await _updateHistory(
                    history["_id"].toString(),
                    updatedHistory,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _updatePatientData(Map<String, dynamic> updatedData) {
    setState(() => patientData = updatedData);
  }

  void _addNote(String note) {
    setState(() {
      patientData["doctorNotes"].add({
        "note": note,
        "createdAt": DateTime.now().toString(),
      });
      _syncNotesWithServer();
    });
  }

  Future<void> _addHistory(Map<String, dynamic> history) async {
    final historyData = {
      "systolicPressure": num.tryParse(history["systolicPressure"] ?? "") ?? 0,
      "diastolicPressure":
          num.tryParse(history["diastolicPressure"] ?? "") ?? 0,
      "respirationRate": num.tryParse(history["respirationRate"] ?? "") ?? 0,
      "bloodOxygenation": num.tryParse(history["bloodOxygenation"] ?? "") ?? 0,
      "heartRate": num.tryParse(history["heartRate"] ?? "") ?? 0,
      "doctorNotes": history["doctorNotes"] ?? [],
      "createdAt": history["date"],
    };

    try {
      await _patients.addPatientHistory(
        patientId: patientData["patientId"]["_id"].toString(),
        historyData: historyData,
      );
      await _fetchHistoryData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("History added successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error adding history: $e")));
    }
  }

  Future<void> _updateNote(dynamic note, String updatedText) async {
    setState(() {
      final noteIndex = patientData["doctorNotes"].indexOf(note);
      if (noteIndex != -1) {
        patientData["doctorNotes"][noteIndex] = {
          "note": updatedText,
          "createdAt": DateTime.now().toString(),
        };
      }
    });

    try {
      final updatedData = {"doctorNotes": patientData["doctorNotes"]};
      await _patients.updateClinicalData(
        patientData["_id"].toString(),
        updatedData,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating note: $e")));
      setState(() {
        final noteIndex = patientData["doctorNotes"].indexOf({
          "note": updatedText,
          "createdAt": DateTime.now().toString(),
        });
        if (noteIndex != -1) {
          patientData["doctorNotes"][noteIndex] = note;
        }
      });
    }
  }

  Future<void> _updateHistory(
    String historyId,
    Map<String, dynamic> updatedHistory,
  ) async {
    try {
      await _patients.updatePatientHistory(
        historyId: historyId,
        historyData: updatedHistory,
      );
      await _fetchHistoryData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("History updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating history: $e")));
    }
  }

  Future<void> _syncNotesWithServer() async {
    try {
      final updatedData = {"doctorNotes": patientData["doctorNotes"]};
      await _patients.updateClinicalData(
        patientData["_id"].toString(),
        updatedData,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error syncing notes: $e")));
    }
  }

  void _deleteNote(dynamic note) {
    setState(() {
      patientData["doctorNotes"].remove(note);
      _syncNotesWithServer();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Note deleted"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorNotes = patientData["doctorNotes"] as List<dynamic>? ?? [];

    String formatDob(String? dob) {
      if (dob == null || dob.isEmpty) return 'N/A';
      final date = DateTime.parse(dob);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          patientData["patientId"]["name"] + " Clinical" as String? ??
              'Unknown',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00C4B4), Color(0xFF0288D1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white, size: 28),
            onPressed: () => _confirmDeletePatient(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0F7FA), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: const Color(0xFF00C4B4),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PatientHeader(patientData: patientData),
                        const SizedBox(height: 30),
                        PatientSection(
                          title: "Patient Information",
                          icon: Icons.person,
                          content: [
                            PatientInfoRow(
                              icon: Icons.cake,
                              label: "Age",
                              value:
                                  patientData["patientId"]["dob"] != null
                                      ? "${DateTime.now().year - DateTime.parse(patientData["patientId"]["dob"]).year}"
                                      : 'N/A',
                            ),
                            PatientInfoRow(
                              icon: Icons.transgender,
                              label: "Gender",
                              value:
                                  patientData["patientId"]["gender"]
                                      as String? ??
                                  'N/A',
                            ),
                            PatientInfoRow(
                              icon: Icons.email,
                              label: "Email",
                              value:
                                  patientData["patientId"]["email"]
                                      as String? ??
                                  'N/A',
                            ),
                            PatientInfoRow(
                              icon: Icons.calendar_today,
                              label: "Date of Birth",
                              value: formatDob(
                                patientData["patientId"]["dob"] as String?,
                              ),
                            ),
                          ],
                        ),
                        PatientSection(
                          title: "Clinical Data",
                          icon: Icons.local_hospital,
                          action: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFF00C4B4),
                            ),
                            onPressed:
                                () => _showEditClinicalDataDialog(context),
                          ),
                          content: [
                            PatientInfoRow(
                              icon: Icons.favorite,
                              label: "Blood Pressure",
                              value:
                                  "${patientData["systolicPressure"]?.toString() ?? 'N/A'}/${patientData["diastolicPressure"]?.toString() ?? 'N/A'} mmHg",
                            ),
                            PatientInfoRow(
                              icon: Icons.air,
                              label: "Respiration Rate",
                              value:
                                  "${patientData["respirationRate"]?.toString() ?? 'N/A'} breaths/min",
                            ),
                            PatientInfoRow(
                              icon: Icons.opacity,
                              label: "Blood Oxygenation",
                              value:
                                  "${patientData["bloodOxygenation"]?.toString() ?? 'N/A'}%",
                            ),
                            PatientInfoRow(
                              icon: Icons.monitor_heart,
                              label: "Heart Rate",
                              value:
                                  "${patientData["heartRate"]?.toString() ?? 'N/A'} bpm",
                            ),
                            PatientInfoRow(
                              icon: Icons.assessment,
                              label: "Status",
                              value: patientData["status"] ?? "N/A",
                            ),
                            PatientInfoRow(
                              icon: Icons.calendar_today,
                              label: "Created At",
                              value: formatDateTime(
                                patientData["createdAt"] as String?,
                              ),
                            ),
                            PatientInfoRow(
                              icon: Icons.update,
                              label: "Updated At",
                              value: formatDateTime(
                                patientData["updatedAt"] as String?,
                              ),
                            ),
                          ],
                        ),
                        PatientSection(
                          title: "Doctor Notes",
                          icon: Icons.note,
                          content: [
                            if (doctorNotes.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  "No notes available.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            else
                              ...doctorNotes.map(
                                (note) => DoctorNoteTile(
                                  note: note,
                                  onUpdate:
                                      () =>
                                          _showUpdateNoteDialog(context, note),
                                  onDelete: () => _deleteNote(note),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text("Add Note"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C4B4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed:
                                    () => showDialog(
                                      context: context,
                                      builder:
                                          (_) => AddNoteDialog(onAdd: _addNote),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        PatientSection(
                          title: "Patient History",
                          icon: Icons.history,
                          content: [
                            if (patientHistory.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  "No history available.",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            else
                              ...patientHistory.map(
                                (history) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Date: ${formatDateTime(history["createdAt"] as String?)}",
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Color(0xFF0277BD),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                _buildHistoryDetail(
                                                  "Status",
                                                  _calculateStatus(history),
                                                  Colors.blueGrey,
                                                ),
                                                _buildHistoryDetail(
                                                  "Blood Pressure",
                                                  "${history["systolicPressure"]?.toString() ?? 'N/A'}/${history["diastolicPressure"]?.toString() ?? 'N/A'} mmHg",
                                                  Colors.red,
                                                ),
                                                _buildHistoryDetail(
                                                  "Respiration Rate",
                                                  "${history["respirationRate"]?.toString() ?? 'N/A'} breaths/min",
                                                  Colors.green,
                                                ),
                                                _buildHistoryDetail(
                                                  "Blood Oxygenation",
                                                  "${history["bloodOxygenation"]?.toString() ?? 'N/A'}%",
                                                  Colors.purple,
                                                ),
                                                _buildHistoryDetail(
                                                  "Heart Rate",
                                                  "${history["heartRate"]?.toString() ?? 'N/A'} bpm",
                                                  Colors.orange,
                                                ),
                                                if (history["doctorNotes"] !=
                                                        null &&
                                                    (history["doctorNotes"]
                                                            as List)
                                                        .isNotEmpty)
                                                  _buildDoctorNotes(
                                                    history["doctorNotes"]
                                                        as List,
                                                  ),
                                                _buildHistoryDetail(
                                                  "Updated At",
                                                  formatDateTime(
                                                        history["updatedAt"]
                                                            as String?,
                                                      ) ??
                                                      'N/A',
                                                  Colors.orange,
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Color(0xFF00C4B4),
                                            ),
                                            onPressed:
                                                () => _showEditHistoryDialog(
                                                  context,
                                                  history,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Add History",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C4B4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed:
                                    () => showDialog(
                                      context: context,
                                      builder:
                                          (_) => AddHistoryDialog(
                                            onAdd: _addHistory,
                                          ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF00C4B4)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryDetail(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(_getIconForLabel(label), size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorNotes(List notes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Doctor's Notes:",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          ...notes.map(
            (note) => Padding(
              padding: const EdgeInsets.only(left: 28.0, bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${note["note"]} (${formatDateTime(note["createdAt"] as String?)})",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case "Status":
        return Icons.assessment;
      case "Blood Pressure":
        return Icons.favorite;
      case "Respiration Rate":
        return Icons.air;
      case "Blood Oxygenation":
        return Icons.opacity;
      case "Heart Rate":
        return Icons.monitor_heart;
      case "Updated At":
        return Icons.date_range;
      default:
        return Icons.info;
    }
  }
}
