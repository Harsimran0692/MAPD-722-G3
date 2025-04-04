import 'package:flutter/material.dart';

class AddNoteDialog extends StatelessWidget {
  final void Function(String) onAdd;

  const AddNoteDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final noteController = TextEditingController();

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Add Doctor Note",
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          color: Color(0xFF0277BD),
        ),
      ),
      content: TextField(
        controller: noteController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: "Note",
          prefixIcon: const Icon(Icons.note_alt, color: Color(0xFF00C4B4)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (noteController.text.isNotEmpty) {
              // Prevent empty notes
              onAdd(noteController.text);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Note cannot be empty")),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C4B4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Add", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
