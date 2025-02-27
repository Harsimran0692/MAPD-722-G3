import 'package:flutter/material.dart';
import 'package:frontend/screens/patient_detail.dart';

class PatientCard extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    var statusColor =
        patient["status"] == "Stable"
            ? 0xFF006400
            : patient["status"] == "Critical"
            ? 0xFFFF0000
            : 0xFFFFA500;

    // Safely access patient name with null handling
    final patientName = patient["patientId"]["name"] as String? ?? 'Unknown';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal, // Changed to teal for consistency
          child: Text(
            patientName.isNotEmpty ? patientName[0] : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          patientName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${patient["status"] ?? 'Unknown'}",
          style: TextStyle(
            color: Color(statusColor),
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetail(patient: patient),
            ),
          );
        },
      ),
    );
  }
}
