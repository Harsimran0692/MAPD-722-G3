import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input filtering
import 'package:intl/intl.dart'; // For date formatting

class EditPatientDialog extends StatefulWidget {
  final Map<String, dynamic> patientData;
  final void Function(Map<String, dynamic>) onSave;

  const EditPatientDialog({
    super.key,
    required this.patientData,
    required this.onSave,
  });

  @override
  State<EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<EditPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController genderController;
  late TextEditingController emailController;
  late DateTime? selectedDob;
  late String? status;
  late TextEditingController systolicController;
  late TextEditingController diastolicController;
  late TextEditingController respirationController;
  late TextEditingController oxygenController;
  late TextEditingController heartRateController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.patientData["patientId"]["name"],
    );
    genderController = TextEditingController(
      text: widget.patientData["patientId"]["gender"],
    );
    emailController = TextEditingController(
      text: widget.patientData["patientId"]["email"],
    );
    selectedDob =
        widget.patientData["patientId"]["dob"] != null
            ? DateTime.tryParse(widget.patientData["patientId"]["dob"])
            : null;
    status = widget.patientData["status"];
    systolicController = TextEditingController(
      text: widget.patientData["systolicPressure"]?.toString(),
    );
    diastolicController = TextEditingController(
      text: widget.patientData["diastolicPressure"]?.toString(),
    );
    respirationController = TextEditingController(
      text: widget.patientData["respirationRate"]?.toString(),
    );
    oxygenController = TextEditingController(
      text: widget.patientData["bloodOxygenation"]?.toString(),
    );
    heartRateController = TextEditingController(
      text: widget.patientData["heartRate"]?.toString(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    genderController.dispose();
    emailController.dispose();
    systolicController.dispose();
    diastolicController.dispose();
    respirationController.dispose();
    oxygenController.dispose();
    heartRateController.dispose();
    super.dispose();
  }

  Future<void> _selectDob(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDob ??
          DateTime.now().subtract(
            const Duration(days: 365 * 18),
          ), // Default to 18 years ago
      firstDate: DateTime(1900), // Arbitrary past limit
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
    if (picked != null && picked != selectedDob) {
      setState(() {
        selectedDob = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Edit Patient Data",
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
              _buildTextField(
                nameController,
                "Name",
                Icons.person,
                validator:
                    (value) => value!.isEmpty ? "Name is required" : null,
              ),
              _buildDobField(context),
              _buildTextField(
                genderController,
                "Gender",
                Icons.transgender,
                validator:
                    (value) => value!.isEmpty ? "Gender is required" : null,
              ),
              _buildTextField(
                emailController,
                "Email",
                Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) =>
                        value!.isEmpty
                            ? "Email is required"
                            : !value.contains('@')
                            ? "Invalid email"
                            : null,
              ),
              _buildTextField(
                systolicController,
                "Systolic Pressure (mmHg)",
                Icons.favorite,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Systolic BP is required";
                  }
                  final systolic = int.tryParse(value);
                  if (systolic == null) return "Must be a number";
                  if (systolic < 50 || systolic > 300) {
                    return "Must be between 50-300";
                  }
                  return null;
                },
              ),
              _buildTextField(
                diastolicController,
                "Diastolic Pressure (mmHg)",
                Icons.favorite_border,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Diastolic BP is required";
                  }
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
              _buildTextField(
                respirationController,
                "Respiration Rate (breaths/min)",
                Icons.air,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Respiration Rate is required";
                  }
                  final respiration = int.tryParse(value);
                  if (respiration == null) return "Must be a number";
                  if (respiration < 5 || respiration > 60) {
                    return "Must be between 5-60";
                  }
                  return null;
                },
              ),
              _buildTextField(
                oxygenController,
                "Blood Oxygenation (%)",
                Icons.opacity,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Oxygen level is required";
                  }
                  final oxygen = int.tryParse(value);
                  if (oxygen == null) return "Must be a number";
                  if (oxygen < 0 || oxygen > 100) {
                    return "Must be between 0-100";
                  }
                  return null;
                },
              ),
              _buildTextField(
                heartRateController,
                "Heart Rate (bpm)",
                Icons.monitor_heart,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Heart Rate is required";
                  }
                  final hr = int.tryParse(value);
                  if (hr == null) return "Must be a number";
                  if (hr < 20 || hr > 250) return "Must be between 20-250";
                  return null;
                },
              ),
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
            if (_formKey.currentState!.validate() && selectedDob != null) {
              final updatedData = Map<String, dynamic>.from(widget.patientData);
              updatedData["patientId"]["name"] = nameController.text;
              updatedData["patientId"]["gender"] = genderController.text;
              updatedData["patientId"]["email"] = emailController.text;
              updatedData["patientId"]["dob"] = DateFormat(
                'yyyy-MM-dd',
              ).format(selectedDob!);
              updatedData["status"] = status;
              updatedData["systolicPressure"] =
                  int.tryParse(systolicController.text) ??
                  updatedData["systolicPressure"];
              updatedData["diastolicPressure"] =
                  int.tryParse(diastolicController.text) ??
                  updatedData["diastolicPressure"];
              updatedData["respirationRate"] =
                  int.tryParse(respirationController.text) ??
                  updatedData["respirationRate"];
              updatedData["bloodOxygenation"] =
                  int.tryParse(oxygenController.text) ??
                  updatedData["bloodOxygenation"];
              updatedData["heartRate"] =
                  int.tryParse(heartRateController.text) ??
                  updatedData["heartRate"];
              widget.onSave(updatedData);
              Navigator.pop(context);
            } else if (selectedDob == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select a date of birth")),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C4B4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Save", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildDobField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => _selectDob(context),
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText:
                  selectedDob == null
                      ? "Select Date of Birth"
                      : DateFormat('yyyy-MM-dd').format(selectedDob!),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: _inputDecoration(label, icon),
        validator: validator,
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
