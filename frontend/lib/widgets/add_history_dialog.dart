import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input filtering
import 'package:intl/intl.dart'; // For date formatting

class AddHistoryDialog extends StatefulWidget {
  final void Function(Map<String, String>) onAdd;

  const AddHistoryDialog({super.key, required this.onAdd});

  @override
  State<AddHistoryDialog> createState() => _AddHistoryDialogState();
}

class _AddHistoryDialogState extends State<AddHistoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();
  final oxygenController = TextEditingController();
  final hrController = TextEditingController();
  DateTime? selectedDate;

  @override
  void dispose() {
    systolicController.dispose();
    diastolicController.dispose();
    oxygenController.dispose();
    hrController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDate ??
          DateTime.now().subtract(
            const Duration(days: 1),
          ), // Default to yesterday if no date selected
      firstDate: DateTime(2000), // Arbitrary past limit
      lastDate: DateTime.now(), // Restrict to today or earlier
      builder:
          (context, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF00C4B4)),
              buttonTheme: const ButtonThemeData(
                textTheme: ButtonTextTheme.primary,
              ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Add Patient History",
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          color: Color(0xFF0277BD),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDateField(context),
              _buildSystolicField(),
              _buildDiastolicField(),
              _buildOxygenField(),
              _buildHRField(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && selectedDate != null) {
              widget.onAdd({
                "date": DateFormat('yyyy-MM-dd').format(selectedDate!),
                "systolic": systolicController.text,
                "diastolic": diastolicController.text,
                "oxygen": oxygenController.text,
                "hr": hrController.text,
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
          ),
          child: const Text("Add", style: TextStyle(color: Colors.white)),
        ),
      ],
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
              prefixIcon: const Icon(
                Icons.calendar_today,
                color: Color(0xFF00C4B4),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
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
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ], // Allow only integers
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
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ], // Allow only integers
        decoration: _inputDecoration(
          "Diastolic BP (mmHg)",
          Icons.favorite_border,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Diastolic BP is required";
          final diastolic = int.tryParse(value);
          if (diastolic == null) return "Must be a number";
          if (diastolic < 30 || diastolic > 200)
            return "Must be between 30-200";
          final systolic = int.tryParse(systolicController.text);
          if (systolic != null && diastolic != null && systolic <= diastolic) {
            return "Systolic must be greater than Diastolic";
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
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ], // Allow only integers
        decoration: _inputDecoration("Oxygen (%)", Icons.opacity),
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
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ], // Allow only integers
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF00C4B4)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }
}
