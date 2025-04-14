import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/patients.dart';

class AddClinicalDataScreen extends StatefulWidget {
  final String patientId;

  const AddClinicalDataScreen({super.key, required this.patientId});

  @override
  State<AddClinicalDataScreen> createState() => _AddClinicalDataScreenState();
}

class _AddClinicalDataScreenState extends State<AddClinicalDataScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _systolicPressureController = TextEditingController();
  final _diastolicPressureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _respirationRateController = TextEditingController();
  final _bloodOxygenationController = TextEditingController();
  final _doctorNotesController = TextEditingController();
  final Patients _patientService = Patients();

  late AnimationController _animationController;
  late Animation<double> _animation;
  Map<String, dynamic>? _patientInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _fetchPatientInfo();
    _animationController.forward();
  }

  Future<void> _fetchPatientInfo() async {
    try {
      final patients = await _patientService.fetchPatients();
      setState(() {
        _patientInfo = patients.firstWhere(
          (p) => p["_id"] == widget.patientId,
          orElse: () => {},
        );
        _isLoading = false;
      });
    } catch (e) {
      _showErrorDialog('Error fetching patient info: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _systolicPressureController.dispose();
    _diastolicPressureController.dispose();
    _heartRateController.dispose();
    _respirationRateController.dispose();
    _bloodOxygenationController.dispose();
    _doctorNotesController.dispose();
    super.dispose();
  }

  String _calculateStatus({
    required int systolic,
    required int diastolic,
    required int heartRate,
    required int respiratory,
    required double oxygen,
  }) {
    // Example logic to calculate status based on clinical data
    if (systolic < 90 || // Severe hypotension
        systolic > 180 || // Hypertensive crisis
        diastolic < 50 || // Severe low diastolic
        diastolic > 120 || // Hypertensive crisis
        oxygen < 90 || // Severe hypoxemia
        heartRate < 40 || // Severe bradycardia
        heartRate > 130 || // Severe tachycardia
        respiratory < 8 || // Bradypnea
        respiratory > 30) {
      // Tachypnea
      return "Critical";
    }
    // Check for recovering conditions (elevated but not critical)
    else if ((systolic >= 130 &&
            systolic <= 180) || // Stage 1 or 2 hypertension
        (diastolic >= 80 && diastolic <= 120) || // Elevated diastolic
        (oxygen >= 90 && oxygen < 95) || // Mild hypoxemia
        (respiratory >= 20 && respiratory <= 30) || // Elevated breathing rate
        (respiratory >= 8 && respiratory < 12)) {
      // Low breathing rate
      return "Recovering";
    }
    // If none of the above, patient is stable
    else {
      return "Stable";
    }
  }

  Future<void> _submitClinicalData() async {
    if (_formKey.currentState!.validate()) {
      final systolicPressure = int.parse(_systolicPressureController.text);
      final diastolicPressure = int.parse(_diastolicPressureController.text);
      final heartRate = int.parse(_heartRateController.text);
      final respirationRate = int.parse(_respirationRateController.text);
      final bloodOxygenation = double.parse(_bloodOxygenationController.text);

      final clinicalData = {
        "patientId": widget.patientId,
        "status": _calculateStatus(
          systolic: systolicPressure,
          diastolic: diastolicPressure,
          heartRate: heartRate,
          respiratory: respirationRate,
          oxygen: bloodOxygenation,
        ),
        "systolicPressure": systolicPressure,
        "diastolicPressure": diastolicPressure,
        "respirationRate": respirationRate,
        "bloodOxygenation": bloodOxygenation,
        "heartRate": heartRate,
        "doctorNotes":
            _doctorNotesController.text.isNotEmpty
                ? [
                  {
                    "note": _doctorNotesController.text,
                    "createdAt": DateTime.now().toIso8601String(),
                  },
                ]
                : [],
      };

      try {
        final response = await _patientService.addClinicalData(clinicalData);
        if (response["message"] == "Clinical record created successfully.") {
          _showSuccessDialog("Clinical data added successfully!");
        } else {
          _showErrorDialog(response["message"] ?? "Unknown error occurred");
        }
      } catch (e) {
        _showErrorDialog("Error adding clinical data: $e");
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Success", style: TextStyle(color: Colors.teal)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close AddClinicalDataScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  ); // Navigate to home screen
                },
                child: const Text("OK", style: TextStyle(color: Colors.teal)),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Error", style: TextStyle(color: Colors.red)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Colors.teal)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF004D40), Color(0xFF26A69A)],
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : Column(
                    children: [
                      SizeTransition(
                        sizeFactor: _animation,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  "Add Clinical Data",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(2, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.medical_services,
                                color: Colors.white,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                      FadeTransition(
                        opacity: _animation,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.teal.withOpacity(0.2),
                                child: Text(
                                  _patientInfo?["name"]?.isNotEmpty == true
                                      ? _patientInfo!["name"][0].toUpperCase()
                                      : "?",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _patientInfo?["name"] ?? "Unknown",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    Text(
                                      "Gender: ${_patientInfo?["gender"] ?? "N/A"}",
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    Text(
                                      "DOB: ${_patientInfo?["dob"] ?? "N/A"}",
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    Text(
                                      "Age: ${_calculateAge(_patientInfo?["dob"])}",
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: FadeTransition(
                            opacity: _animation,
                            child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.white.withOpacity(0.95),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildFormField(
                                        controller: _systolicPressureController,
                                        label:
                                            "Systolic Pressure (50-250 mmHg)",
                                        icon: Icons.favorite,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Systolic Pressure is required";
                                          }
                                          final sp = int.tryParse(value);
                                          if (sp == null ||
                                              sp < 50 ||
                                              sp > 250) {
                                            return "Enter a valid value (50-250)";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 15),
                                      _buildFormField(
                                        controller:
                                            _diastolicPressureController,
                                        label:
                                            "Diastolic Pressure (30-150 mmHg)",
                                        icon: Icons.favorite_border,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Diastolic Pressure is required";
                                          }
                                          final dp = int.tryParse(value);
                                          if (dp == null ||
                                              dp < 30 ||
                                              dp > 150) {
                                            return "Enter a valid value (30-150)";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 15),
                                      _buildFormField(
                                        controller: _heartRateController,
                                        label: "Heart Rate (30-200 bpm)",
                                        icon: Icons.monitor_heart,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Heart Rate is required";
                                          }
                                          final hr = int.tryParse(value);
                                          if (hr == null ||
                                              hr < 30 ||
                                              hr > 200) {
                                            return "Enter a valid value (30-200)";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 15),
                                      _buildFormField(
                                        controller: _respirationRateController,
                                        label:
                                            "Respiration Rate (12-40 breaths/min)",
                                        icon: Icons.air,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Respiration Rate is required";
                                          }
                                          final rr = int.tryParse(value);
                                          if (rr == null ||
                                              rr < 12 ||
                                              rr > 40) {
                                            return "Enter a valid value (12-40)";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 15),
                                      _buildFormField(
                                        controller: _bloodOxygenationController,
                                        label: "Blood Oxygenation (70-100%)",
                                        icon: Icons.opacity,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Blood Oxygenation is required";
                                          }
                                          final bo = double.tryParse(value);
                                          if (bo == null ||
                                              bo < 70 ||
                                              bo > 100) {
                                            return "Enter a valid value (70-100)";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 15),
                                      _buildFormField(
                                        controller: _doctorNotesController,
                                        label: "Doctor Notes (optional)",
                                        icon: Icons.note,
                                        maxLines: 3,
                                      ),
                                      const SizedBox(height: 30),
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: _submitClinicalData,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 40,
                                              vertical: 15,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 5,
                                          ),
                                          child: const Text(
                                            "Submit Clinical Data",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  int _calculateAge(String? dob) {
    if (dob == null) return 0;
    final birthDate = DateTime.tryParse(dob);
    if (birthDate == null) return 0;
    return DateTime.now().year - birthDate.year;
  }
}
