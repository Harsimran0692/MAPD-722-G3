import 'package:flutter/material.dart';

class UpdateNoteDialog extends StatelessWidget {
  final dynamic note;
  final void Function(dynamic, String) onUpdate;

  const UpdateNoteDialog({
    super.key,
    required this.note,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final noteController = TextEditingController(text: note["note"]);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Update Doctor Note",
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
            onUpdate(note, noteController.text);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C4B4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Update", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
