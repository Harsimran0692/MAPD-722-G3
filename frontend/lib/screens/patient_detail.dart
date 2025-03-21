import 'package:flutter/material.dart';
import '../widgets/patient_header.dart';
import '../widgets/patient_section.dart';
import '../widgets/patient_info_row.dart';
import '../widgets/doctor_note_tile.dart';
import '../widgets/patient_history_row.dart';
import '../widgets/edit_patient_dialog.dart';
import '../widgets/add_note_dialog.dart';
import '../widgets/update_note_dialog.dart';
import '../widgets/add_history_dialog.dart';

class PatientDetail extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetail({super.key, required this.patient});

  @override
  State<PatientDetail> createState() => _PatientDetailState();
}

class _PatientDetailState extends State<PatientDetail> {
  late Map<String, dynamic> patientData;

  @override
  void initState() {
    super.initState();
    patientData = Map.from(widget.patient); // Initialize with passed data
  }

  // Simulate an API call to fetch updated patient data
  Future<void> _fetchPatientData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    final updatedData = Map<String, dynamic>.from(widget.patient);
    updatedData["doctorNotes"] = updatedData["doctorNotes"] ?? [];
    updatedData["status"] = "Stable"; // Example change from API

    setState(() {
      patientData = updatedData;
    });
  }

  // Show confirmation dialog for deletion
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
              "Are you sure you want to permanently delete this patient? This action cannot be undone.",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Cancel
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true), // Confirm
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
      _deletePatient();
    }
  }

  // Simulate patient deletion (replace with actual API call)
  void _deletePatient() {
    // In a real app, call an API here to delete the patient, e.g.:
    // await patientService.deletePatient(patientData["patientId"]["id"]);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Patient deleted successfully")),
    );
    Navigator.pop(context); // Return to HomeScreen after deletion
  }

  @override
  Widget build(BuildContext context) {
    final doctorNotes = patientData["doctorNotes"] as List<dynamic>? ?? [];
    final patientHistory = [
      {
        "date": "2025-02-20",
        "status": "Stable",
        "bp": "118/78 mmHg",
        "oxygen": "95%",
        "hr": "70 bpm",
      },
      {
        "date": "2025-02-15",
        "status": "Critical",
        "bp": "170/100 mmHg",
        "oxygen": "85%",
        "hr": "105 bpm",
      },
      {
        "date": "2025-02-10",
        "status": "Recovering",
        "bp": "130/85 mmHg",
        "oxygen": "92%",
        "hr": "82 bpm",
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          patientData["patientId"]["name"] as String? ?? 'Unknown',
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
            icon: const Icon(Icons.edit, color: Colors.white, size: 28),
            onPressed:
                () => showDialog(
                  context: context,
                  builder:
                      (_) => EditPatientDialog(
                        patientData: patientData,
                        onSave: _updatePatientData,
                      ),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white, size: 28),
            onPressed: () => _confirmDeletePatient(context),
          ),
        ],
      ),
      body: Container(
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
              onRefresh: _fetchPatientData,
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
                              patientData["patientId"]["gender"] as String? ??
                              'N/A',
                        ),
                        PatientInfoRow(
                          icon: Icons.email,
                          label: "Email",
                          value:
                              patientData["patientId"]["email"] as String? ??
                              'N/A',
                        ),
                        PatientInfoRow(
                          icon: Icons.calendar_today,
                          label: "Date of Birth",
                          value:
                              patientData["patientId"]["dob"] as String? ??
                              'N/A',
                        ),
                      ],
                    ),
                    PatientSection(
                      title: "Clinical Data",
                      icon: Icons.local_hospital,
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
                                  () => _showUpdateNoteDialog(context, note),
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
                        ...patientHistory.map(
                          (history) => PatientHistoryRow(history: history),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text("Add History"),
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
                                      (_) =>
                                          AddHistoryDialog(onAdd: _addHistory),
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
    });
  }

  void _addHistory(Map<String, String> history) {
    // For demo, history is static; implement dynamic storage as needed
  }

  void _showUpdateNoteDialog(BuildContext context, dynamic note) {
    showDialog(
      context: context,
      builder: (_) => UpdateNoteDialog(note: note, onUpdate: _updateNote),
    );
  }

  void _updateNote(dynamic note, String updatedText) {
    setState(() {
      note["note"] = updatedText;
      note["createdAt"] = DateTime.now().toString();
    });
  }

  void _deleteNote(dynamic note) {
    setState(() {
      patientData["doctorNotes"].remove(note);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Note deleted"),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}
