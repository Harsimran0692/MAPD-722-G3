import 'package:flutter/material.dart';
import 'package:frontend/screens/patient_detail.dart';

class PatientCard extends StatelessWidget {
  final Map<String, dynamic>? patient; // Make patient nullable

  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    // Log the patient for debugging
    // If patient is null, return an error placeholder
    if (patient == null) {
      return const Center(
        child: Text(
          "Patient data is missing",
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    // Safely handle status
    final status = patient?["status"] as String? ?? 'Unknown';
    final statusColor =
        status == "Stable"
            ? Colors.green[700]
            : status == "Critical"
            ? Colors.red[700]
            : Colors.orange[700];

    // Safely access patientId, default to empty map if null
    final patientId = patient?["patientId"] as Map<String, dynamic>? ?? {};

    // Safely access nested fields with fallbacks
    final patientName = patientId["name"] as String? ?? 'Unknown';
    final patientGender = patientId["gender"] as String? ?? 'N/A';
    final patientDobStr = patientId["dob"] as String? ?? '';
    final patientDob = DateTime.tryParse(patientDobStr);
    final patientAge =
        patientDob != null ? DateTime.now().year - patientDob.year : 0;

    return GestureDetector(
      onTap: () {
        // Only navigate if patient data is valid
        if (patient != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetail(patient: patient!),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar with Status Indicator
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.teal,
                      child: Text(
                        patientName.isNotEmpty
                            ? patientName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Patient Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          patientGender.toLowerCase() == "male"
                              ? Icons.male
                              : patientGender.toLowerCase() == "female"
                              ? Icons.female
                              : Icons.person,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$patientGender, $patientAge yrs",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor?.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Trailing Action
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.teal,
                  size: 20,
                ),
                onPressed: () {
                  if (patient != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientDetail(patient: patient!),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
