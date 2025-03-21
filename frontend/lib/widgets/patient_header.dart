import 'package:flutter/material.dart';

class PatientHeader extends StatelessWidget {
  final Map<String, dynamic> patientData;

  const PatientHeader({super.key, required this.patientData});

  @override
  Widget build(BuildContext context) {
    final name = patientData["patientId"]["name"] as String? ?? 'Unknown';
    final status = patientData["status"] as String? ?? 'Unknown';

    return Row(
      children: [
        Hero(
          tag: 'patientAvatar_$name',
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD54F), Color(0xFFFFA726)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.transparent,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0277BD),
                fontFamily: 'Poppins',
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color:
                      status == "Stable"
                          ? Colors.green
                          : status == "Critical"
                          ? Colors.red
                          : Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  "Status: $status",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
