import 'package:flutter/material.dart';

class DoctorNoteTile extends StatelessWidget {
  final dynamic note;
  final VoidCallback onUpdate;
  final VoidCallback onDelete; // Callback for deletion

  const DoctorNoteTile({
    super.key,
    required this.note,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Dismissible(
        key: Key(
          note["createdAt"] as String? ?? UniqueKey().toString(),
        ), // Unique key for each note
        direction: DismissDirection.endToStart, // Swipe from right to left
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          decoration: BoxDecoration(
            color: Colors.redAccent, // Background color for delete action
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white, size: 30),
        ),
        confirmDismiss: (direction) async {
          // Show confirmation dialog before deletion
          return await _showDeleteConfirmationDialog(context);
        },
        onDismissed: (direction) {
          onDelete(); // Call the delete callback when dismissed
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            leading: const Icon(Icons.note_alt, color: Color(0xFF00C4B4)),
            title: Text(
              note["note"] as String? ?? 'No note text',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            subtitle: Text(
              "Added: ${note["createdAt"] as String? ?? 'N/A'}",
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFFFFA726)),
              onPressed: onUpdate,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Delete Note",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Color(0xFF0277BD),
              ),
            ),
            content: const Text(
              "Are you sure you want to delete this note?",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.pop(context, false), // Cancel deletion
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.pop(context, true), // Confirm deletion
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
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
  }
}
