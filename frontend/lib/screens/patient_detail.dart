import 'package:flutter/material.dart';

class PatientDetail extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetail({super.key, required this.patient});

  @override
  State<PatientDetail> createState() => _PatientDetailState();
}

class _PatientDetailState extends State<PatientDetail> {
  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    final name = patient["patientId"]["name"] as String? ?? 'Unknown';
    final age = patient["patientId"]["age"]?.toString() ?? 'N/A';
    final gender = patient["patientId"]["gender"] as String? ?? 'N/A';
    final email = patient["patientId"]["email"] as String? ?? 'N/A';
    final dob = patient["patientId"]["dob"] as String? ?? 'N/A';
    final status = patient["status"] as String? ?? 'Unknown';
    final systolicPressure = patient["systolicPressure"]?.toString() ?? 'N/A';
    final diastolicPressure = patient["diastolicPressure"]?.toString() ?? 'N/A';
    final respirationRate = patient["respirationRate"]?.toString() ?? 'N/A';
    final bloodOxygenation = patient["bloodOxygenation"]?.toString() ?? 'N/A';
    final heartRate = patient["heartRate"]?.toString() ?? 'N/A';
    final doctorNotes = patient["doctorNotes"] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Placeholder for update dialog
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Update Patient Data'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<String>(
                            value: status,
                            items:
                                ['Stable', 'Critical', 'Recovering'].map((
                                  status,
                                ) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                            onChanged: null, // Disabled for UI-only
                            decoration: const InputDecoration(
                              labelText: 'Status',
                            ),
                          ),
                          TextField(
                            controller: TextEditingController(
                              text: systolicPressure,
                            ),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Systolic Pressure (mmHg)',
                            ),
                            enabled: false, // Disabled for UI-only
                          ),
                          TextField(
                            controller: TextEditingController(
                              text: diastolicPressure,
                            ),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Diastolic Pressure (mmHg)',
                            ),
                            enabled: false,
                          ),
                          TextField(
                            controller: TextEditingController(
                              text: respirationRate,
                            ),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Respiration Rate (breaths/min)',
                            ),
                            enabled: false,
                          ),
                          TextField(
                            controller: TextEditingController(
                              text: bloodOxygenation,
                            ),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Blood Oxygenation (%)',
                            ),
                            enabled: false,
                          ),
                          TextField(
                            controller: TextEditingController(text: heartRate),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Heart Rate (bpm)',
                            ),
                            enabled: false,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                      ElevatedButton(
                        onPressed:
                            () => Navigator.pop(context), // Placeholder action
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Avatar
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.amber,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        Text(
                          "Status: $status",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(
                              status == "Stable"
                                  ? 0xFF006400
                                  : status == "Critical"
                                  ? 0xFFFF0000
                                  : 0xFFFFA500,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Patient Info Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle("Patient Information", Icons.person),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      onPressed: () {}, // Placeholder for editing patient info
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.teal.withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.cake, "Age", age),
                          _buildInfoRow(Icons.transgender, "Gender", gender),
                          _buildInfoRow(Icons.email, "Email", email),
                          _buildInfoRow(
                            Icons.calendar_today,
                            "Date of Birth",
                            dob,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Clinical Data Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle("Clinical Data", Icons.local_hospital),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      onPressed: () {}, // Placeholder for editing clinical data
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.teal.withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.favorite,
                            "Blood Pressure",
                            "$systolicPressure/$diastolicPressure mmHg",
                          ),
                          _buildInfoRow(
                            Icons.air,
                            "Respiration Rate",
                            "$respirationRate breaths/min",
                          ),
                          _buildInfoRow(
                            Icons.opacity,
                            "Blood Oxygenation",
                            "$bloodOxygenation%",
                          ),
                          _buildInfoRow(
                            Icons.monitor_heart,
                            "Heart Rate",
                            "$heartRate bpm",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Doctor Notes Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle("Doctor Notes", Icons.note),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      onPressed: () {}, // Placeholder for editing doctor notes
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                doctorNotes.isEmpty
                    ? Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.teal.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "No notes available.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: doctorNotes.length,
                      itemBuilder: (context, index) {
                        final note = doctorNotes[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.teal.withOpacity(0.2),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.note_alt,
                                      size: 20,
                                      color: Colors.teal,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        note["note"] as String? ??
                                            'No note text',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Added: ${note["createdAt"] as String? ?? 'N/A'}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                // Patient History Section
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle("Patient History", Icons.history),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      onPressed: () {}, // Placeholder for editing history
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.teal.withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildHistoryRow(
                            "2025-02-20",
                            "Stable",
                            "118/78 mmHg",
                            "95%",
                            "70 bpm",
                          ),
                          const Divider(color: Colors.teal),
                          _buildHistoryRow(
                            "2025-02-15",
                            "Critical",
                            "170/100 mmHg",
                            "85%",
                            "105 bpm",
                          ),
                          const Divider(color: Colors.teal),
                          _buildHistoryRow(
                            "2025-02-10",
                            "Recovering",
                            "130/85 mmHg",
                            "92%",
                            "82 bpm",
                          ),
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

  // Helper method for section titles
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  // Helper method for info rows
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for history rows (static UI)
  Widget _buildHistoryRow(
    String date,
    String status,
    String bp,
    String oxygen,
    String hr,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.history, color: Colors.teal, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Date: $date",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Status: $status",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(
                      status == "Stable"
                          ? 0xFF006400
                          : status == "Critical"
                          ? 0xFFFF0000
                          : 0xFFFFA500,
                    ),
                  ),
                ),
                Text(
                  "Blood Pressure: $bp",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                Text(
                  "Oxygen: $oxygen",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                Text(
                  "Heart Rate: $hr",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
