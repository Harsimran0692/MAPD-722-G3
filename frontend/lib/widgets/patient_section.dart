import 'package:flutter/material.dart';

class PatientSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> content;
  final Widget? action; // Add optional action parameter

  const PatientSection({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.action, // Make it optional
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Space between title and action
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF0277BD), size: 30),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0277BD),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            if (action != null) action!, // Display action if provided
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: content),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
