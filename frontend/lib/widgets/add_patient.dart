import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input filtering
import 'package:intl/intl.dart'; // For date formatting
import 'package:frontend/models/patients.dart'; // Adjust import based on your project structure

class AddPatientDialog extends StatefulWidget {
  final Patients patientService; // Service to add patient
  final VoidCallback fetchPatients; // Callback to refresh patient list

  const AddPatientDialog({
    super.key,
    required this.patientService,
    required this.fetchPatients,
  });

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _respirationController = TextEditingController();
  final _oxygenController = TextEditingController();
  final _heartRateController = TextEditingController();
  DateTime? _selectedDob;
  String _selectedGender = 'Male'; // Default value

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _respirationController.dispose();
    _oxygenController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }

  Future<void> _selectDob(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDob ??
          DateTime.now().subtract(
            const Duration(days: 365 * 18),
          ), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Add New Patient',
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
                _nameController,
                "Name",
                Icons.person,
                validator:
                    (value) => value!.isEmpty ? 'Name is required' : null,
              ),
              _buildDobField(context),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: _inputDecoration("Gender", Icons.transgender),
                items:
                    ['Male', 'Female', 'Other']
                        .map(
                          (gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _selectedGender = value!),
                validator:
                    (value) => value == null ? 'Gender is required' : null,
              ),
              _buildTextField(
                _emailController,
                "Email",
                Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Email is required'
                            : !value.contains('@')
                            ? 'Enter a valid email'
                            : null,
              ),
              _buildTextField(
                _systolicController,
                "Systolic Pressure (mmHg)",
                Icons.favorite,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Systolic BP is required";
                  final systolic = int.tryParse(value);
                  if (systolic == null) return "Must be a number";
                  if (systolic < 50 || systolic > 300)
                    return "Must be between 50-300";
                  return null;
                },
              ),
              _buildTextField(
                _diastolicController,
                "Diastolic Pressure (mmHg)",
                Icons.favorite_border,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Diastolic BP is required";
                  final diastolic = int.tryParse(value);
                  if (diastolic == null) return "Must be a number";
                  if (diastolic < 30 || diastolic > 200)
                    return "Must be between 30-200";
                  final systolic = int.tryParse(_systolicController.text);
                  if (systolic != null &&
                      diastolic != null &&
                      systolic <= diastolic) {
                    return "Systolic must be greater than Diastolic";
                  }
                  return null;
                },
              ),
              _buildTextField(
                _respirationController,
                "Respiration Rate (breaths/min)",
                Icons.air,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Respiration Rate is required";
                  final respiration = int.tryParse(value);
                  if (respiration == null) return "Must be a number";
                  if (respiration < 5 || respiration > 60)
                    return "Must be between 5-60";
                  return null;
                },
              ),
              _buildTextField(
                _oxygenController,
                "Blood Oxygenation (%)",
                Icons.opacity,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Oxygen level is required";
                  final oxygen = int.tryParse(value);
                  if (oxygen == null) return "Must be a number";
                  if (oxygen < 0 || oxygen > 100)
                    return "Must be between 0-100";
                  return null;
                },
              ),
              _buildTextField(
                _heartRateController,
                "Heart Rate (bpm)",
                Icons.monitor_heart,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Heart Rate is required";
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
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate() && _selectedDob != null) {
              try {
                final newPatient = {
                  "patientId": {
                    "name": _nameController.text,
                    "dob": DateFormat('yyyy-MM-dd').format(_selectedDob!),
                    "gender": _selectedGender,
                    "email": _emailController.text,
                  },
                  "status": "Stable", // Default status
                  "systolicPressure": int.parse(_systolicController.text),
                  "diastolicPressure": int.parse(_diastolicController.text),
                  "respirationRate": int.parse(_respirationController.text),
                  "bloodOxygenation": int.parse(_oxygenController.text),
                  "heartRate": int.parse(_heartRateController.text),
                  "doctorNotes": [],
                };

                // await widget.patientService.addPatient(newPatient);
                widget.fetchPatients(); // Refresh patient list
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Patient added successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding patient: $e')),
                );
              }
            } else if (_selectedDob == null) {
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
          child: const Text(
            'Add Patient',
            style: TextStyle(color: Colors.white),
          ),
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
                  _selectedDob == null
                      ? "Select Date of Birth"
                      : DateFormat('yyyy-MM-dd').format(_selectedDob!),
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
