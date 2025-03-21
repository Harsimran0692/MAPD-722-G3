import 'package:flutter/material.dart';

class PatientHistoryRow extends StatelessWidget {
  final Map<String, String> history;

  const PatientHistoryRow({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final status = history["status"]!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00C4B4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.history,
              color: Color(0xFF00C4B4),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Date: ${history["date"]!}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
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
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Text(
                  "Blood Pressure: ${history["bp"]!}",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Oxygen: ${history["oxygen"]!}",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Heart Rate: ${history["hr"]!}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
