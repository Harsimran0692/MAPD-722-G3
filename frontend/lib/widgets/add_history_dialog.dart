import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input filtering
import 'package:intl/intl.dart'; // For date formatting

class AddHistoryDialog extends StatefulWidget {
  final void Function(Map<String, dynamic>) onAdd;

  const AddHistoryDialog({super.key, required this.onAdd});

  @override
  State<AddHistoryDialog> createState() => _AddHistoryDialogState();
}

class _AddHistoryDialogState extends State<AddHistoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();
  final respirationController = TextEditingController();
  final oxygenController = TextEditingController();
  final hrController = TextEditingController();
  final noteController = TextEditingController();
  DateTime? selectedDate;

  @override
  void dispose() {
    systolicController.dispose();
    diastolicController.dispose();
    respirationController.dispose();
    oxygenController.dispose();
    hrController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDate ?? DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder:
          (context, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF00C4B4),
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF00C4B4),
                ),
              ),
              dialogTheme: DialogThemeData(backgroundColor: Colors.white),
            ),
            child: child!,
          ),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      title: const Text(
        "Add Patient History",
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Color(0xFF0277BD),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Date & Time"),
              _buildDateField(context),
              const SizedBox(height: 16),
              _buildSectionTitle("Vital Signs"),
              _buildSystolicField(),
              _buildDiastolicField(),
              _buildRespirationField(),
              _buildOxygenField(),
              _buildHRField(),
              const SizedBox(height: 16),
              _buildSectionTitle("Doctor's Note"),
              _buildNoteField(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && selectedDate != null) {
              widget.onAdd({
                "date": DateFormat('yyyy-MM-dd').format(selectedDate!),
                "systolicPressure": systolicController.text,
                "diastolicPressure": diastolicController.text,
                "respirationRate": respirationController.text,
                "bloodOxygenation": oxygenController.text,
                "heartRate": hrController.text,
                "doctorNotes":
                    noteController.text.isNotEmpty
                        ? [
                          {
                            "note": noteController.text,
                            "createdAt": DateTime.now().toString(),
                          },
                        ]
                        : [],
              });
              Navigator.pop(context);
            } else if (selectedDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select a date")),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C4B4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 4,
          ),
          child: const Text(
            "Add",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0277BD),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText:
                  selectedDate == null
                      ? "Select Date"
                      : DateFormat('yyyy-MM-dd').format(selectedDate!),
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(
                Icons.calendar_today,
                color: Color(0xFF00C4B4),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF00C4B4),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSystolicField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: systolicController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDecoration("Systolic BP (mmHg)", Icons.favorite),
        validator: (value) {
          if (value == null || value.isEmpty) return "Systolic BP is required";
          final systolic = int.tryParse(value);
          if (systolic == null) return "Must be a number";
          if (systolic < 50 || systolic > 300) return "Must be between 50-300";
          return null;
        },
      ),
    );
  }

  Widget _buildDiastolicField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: diastolicController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDecoration(
          "Diastolic BP (mmHg)",
          Icons.favorite_border,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Diastolic BP is required";
          final diastolic = int.tryParse(value);
          if (diastolic == null) return "Must be a number";
          if (diastolic < 30 || diastolic > 200) {
            return "Must be between 30-200";
          }
          final systolic = int.tryParse(systolicController.text);
          if (systolic != null && systolic <= diastolic) {
            return "Systolic must be greater than Diastolic";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRespirationField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: respirationController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDecoration(
          "Respiration Rate (breaths/min)",
          Icons.air,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Respiration Rate is required";
          }
          final respiration = int.tryParse(value);
          if (respiration == null) return "Must be a number";
          if (respiration < 5 || respiration > 50) {
            return "Must be between 5-50";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildOxygenField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: oxygenController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDecoration("Blood Oxygenation (%)", Icons.opacity),
        validator: (value) {
          if (value == null || value.isEmpty) return "Oxygen level is required";
          final oxygen = int.tryParse(value);
          if (oxygen == null) return "Must be a number";
          if (oxygen < 0 || oxygen > 100) return "Must be between 0-100";
          return null;
        },
      ),
    );
  }

  Widget _buildHRField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: hrController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDecoration("Heart Rate (bpm)", Icons.monitor_heart),
        validator: (value) {
          if (value == null || value.isEmpty) return "Heart Rate is required";
          final hr = int.tryParse(value);
          if (hr == null) return "Must be a number";
          if (hr < 20 || hr > 250) return "Must be between 20-250";
          return null;
        },
      ),
    );
  }

  Widget _buildNoteField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: noteController,
        decoration: _inputDecoration("Doctor's Note (optional)", Icons.note),
        maxLines: 3,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
      prefixIcon: Icon(icon, color: const Color(0xFF00C4B4)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00C4B4), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }
}
