import 'package:flutter/material.dart';
import 'package:frontend/models/patients.dart';
import 'package:frontend/screens/add_clinical_data_screen.dart';
import 'package:frontend/widgets/add_patient.dart';
import 'package:intl/intl.dart';

class PatientsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> patients;

  const PatientsScreen({super.key, required this.patients});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final Patients patientService = Patients();
  late Future<List<Map<String, dynamic>>> _patientsFuture;
  List<Map<String, dynamic>> filteredPatients = [];
  String filterGender = "All";
  String searchQuery = "";
  RangeValues ageRange = const RangeValues(0, 100);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientsOnLoad();
  }

  Future<void> _fetchPatientsOnLoad() async {
    setState(() {
      _isLoading = true;
    });
    _patientsFuture = _fetchPatientsInitial();
    await _patientsFuture;
    setState(() {
      _isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchPatientsInitial() async {
    try {
      final fetchedPatients = await patientService.fetchPatients();
      widget.patients.clear();
      widget.patients.addAll(
        fetchedPatients.map((p) {
          if (p["dob"] != null) {
            final dob = DateTime.tryParse(p["dob"]);
            if (dob != null) p["dob"] = _formatDate(dob);
          }
          return p;
        }).toList(),
      );
      filteredPatients = List.from(widget.patients);
      filterPatients();
      return widget.patients;
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching patients: $e')));
      return [];
    }
  }

  Future<void> _fetchPatients() async {
    try {
      final fetchedPatients = await patientService.fetchPatients();
      setState(() {
        widget.patients.clear();
        widget.patients.addAll(
          fetchedPatients.map((p) {
            if (p["dob"] != null) {
              final dob = DateTime.tryParse(p["dob"]);
              if (dob != null) p["dob"] = _formatDate(dob);
            }
            return p;
          }).toList(),
        );
        filteredPatients = List.from(widget.patients);
        filterPatients();
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching patients: $e')));
    }
  }

  void filterPatients() {
    setState(() {
      filteredPatients =
          widget.patients.where((patient) {
            final patientGender =
                patient["gender"]?.toString().toLowerCase() ?? "";
            final matchesGender =
                filterGender == "All" ||
                patientGender == filterGender.toLowerCase();
            final patientDob = DateTime.tryParse(patient["dob"] ?? "");
            final patientAge =
                patientDob != null ? DateTime.now().year - patientDob.year : 0;
            final matchesAge =
                patientAge >= ageRange.start && patientAge <= ageRange.end;
            final patientName = patient["name"]?.toString().toLowerCase() ?? "";
            final matchesName =
                searchQuery.trim().isEmpty ||
                patientName.contains(searchQuery.trim().toLowerCase());
            return matchesGender && matchesAge && matchesName;
          }).toList();
    });
  }

  void showAddPatientDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => AddPatientDialog(
            patientService: patientService,
            fetchPatients: _fetchPatientsAndReload,
          ),
    );
  }

  void _showFilterModal() {
    String tempFilterGender = filterGender;
    RangeValues tempAgeRange = ageRange;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => DraggableScrollableSheet(
                  initialChildSize: 0.7,
                  minChildSize: 0.5,
                  maxChildSize: 0.9,
                  builder:
                      (context, scrollController) => SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Advanced Filters",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildFilterSection(
                                "Gender",
                                ["All", "Male", "Female", "Other"],
                                tempFilterGender,
                                setStateDialog,
                                (value) => tempFilterGender = value,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Age Range",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                  fontSize: 18,
                                ),
                              ),
                              RangeSlider(
                                values: tempAgeRange,
                                min: 0,
                                max: 100,
                                divisions: 100,
                                labels: RangeLabels(
                                  "${tempAgeRange.start.round()}",
                                  "${tempAgeRange.end.round()}",
                                ),
                                activeColor: Colors.teal,
                                onChanged:
                                    (values) => setStateDialog(
                                      () => tempAgeRange = values,
                                    ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        filterGender = tempFilterGender;
                                        ageRange = tempAgeRange;
                                        filterPatients();
                                      });
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: const Text(
                                      "Apply",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                ),
          ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selected,
    StateSetter setStateDialog,
    Function(String) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options.map((option) {
                final isSelected = selected == option;
                return ChoiceChip(
                  label: Text(option, style: const TextStyle(fontSize: 16)),
                  selected: isSelected,
                  onSelected:
                      (bool selected) =>
                          setStateDialog(() => onSelected(option)),
                  selectedColor: Colors.teal,
                  backgroundColor: Colors.grey[100],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  elevation: isSelected ? 4 : 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  int _calculateAge(String? dob) {
    if (dob == null) return 0;
    final birthDate = DateTime.tryParse(dob);
    if (birthDate == null) return 0;
    return DateTime.now().year - birthDate.year;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _fetchPatientsAndReload() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchPatients();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deletePatient(Map<String, dynamic> patient) async {
    try {
      final patientId = patient["_id"]?.toString();
      if (patientId == null) throw Exception("Patient ID not found");
      await patientService.deletePatient(patientId);
      await _fetchPatientsAndReload();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${patient["name"]} deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting patient: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _editPatient(Map<String, dynamic> patient) async {
    final nameController = TextEditingController(text: patient["name"] ?? "");
    final emailController = TextEditingController(text: patient["email"] ?? "");
    DateTime? selectedDob = DateTime.tryParse(patient["dob"] ?? "");
    final dobController = TextEditingController(
      text: selectedDob != null ? _formatDate(selectedDob) : "",
    );

    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text(
                  "Edit Patient",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Name"),
                      ),
                      TextField(
                        controller: dobController,
                        decoration: const InputDecoration(
                          labelText: "DOB (YYYY-MM-DD)",
                        ),
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDob ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null && picked != selectedDob) {
                            setState(() {
                              selectedDob = picked;
                              dobController.text = _formatDate(picked);
                            });
                          }
                        },
                      ),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: "Email"),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final updatedData = {
                        if (nameController.text.isNotEmpty)
                          "name": nameController.text,
                        if (dobController.text.isNotEmpty)
                          "dob": dobController.text,
                        if (emailController.text.isNotEmpty)
                          "email": emailController.text,
                      };
                      if (updatedData.isNotEmpty) {
                        try {
                          final patientId = patient["_id"]?.toString();
                          if (patientId == null)
                            throw Exception("Patient ID not found");
                          final updatedPatient = await patientService
                              .updatePatient(patientId, updatedData);
                          await _fetchPatientsAndReload();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "${updatedPatient["patient"]["name"]} updated successfully",
                              ),
                            ),
                          );
                          Navigator.pop(context, true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating patient: $e'),
                            ),
                          );
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.pop(context, false);
                        }
                      } else {
                        Navigator.pop(context, false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showAddClinicalDataDialog(BuildContext context, String patientId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddClinicalDataScreen(patientId: patientId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004D40), Color(0xFF26A69A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  )
                  : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _patientsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.teal),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      } else {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                30,
                                20,
                                20,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.teal.shade900,
                                    Colors.teal.shade700,
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(30),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Patients Dashboard",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Card(
                                          elevation: 10,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            side: BorderSide(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText: "Search Patients",
                                              hintStyle: TextStyle(
                                                color: Colors.grey[400],
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.search,
                                                color: Colors.teal,
                                              ),
                                              border: InputBorder.none,
                                              filled: true,
                                              fillColor: Colors.white
                                                  .withOpacity(0.95),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                            ),
                                            onChanged:
                                                (value) => setState(() {
                                                  searchQuery = value;
                                                  filterPatients();
                                                }),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      ElevatedButton(
                                        onPressed: _showFilterModal,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal.shade800,
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(18),
                                          elevation: 8,
                                        ),
                                        child: const Icon(
                                          Icons.filter_list,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        20,
                                        20,
                                        10,
                                      ),
                                      child: Text(
                                        "All Patients (${filteredPatients.length})",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: RefreshIndicator(
                                        onRefresh: _fetchPatientsAndReload,
                                        color: Colors.teal,
                                        child:
                                            filteredPatients.isEmpty
                                                ? Center(
                                                  child: Text(
                                                    "No Patients Found",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                                : ListView.builder(
                                                  padding: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  itemCount:
                                                      filteredPatients.length,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    final patient =
                                                        filteredPatients[index];
                                                    return Dismissible(
                                                      key: Key(
                                                        patient["_id"]
                                                                ?.toString() ??
                                                            index.toString(),
                                                      ),
                                                      background: Container(
                                                        color: Colors.green,
                                                        alignment:
                                                            Alignment
                                                                .centerLeft,
                                                        padding:
                                                            const EdgeInsets.only(
                                                              left: 20,
                                                            ),
                                                        child: const Icon(
                                                          Icons.edit,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      secondaryBackground: Container(
                                                        color: Colors.red,
                                                        alignment:
                                                            Alignment
                                                                .centerRight,
                                                        padding:
                                                            const EdgeInsets.only(
                                                              right: 20,
                                                            ),
                                                        child: const Icon(
                                                          Icons.delete,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      confirmDismiss: (
                                                        direction,
                                                      ) async {
                                                        if (direction ==
                                                            DismissDirection
                                                                .endToStart) {
                                                          return await showDialog<
                                                            bool
                                                          >(
                                                            context: context,
                                                            builder:
                                                                (
                                                                  context,
                                                                ) => AlertDialog(
                                                                  title: const Text(
                                                                    "Confirm Delete",
                                                                  ),
                                                                  content: Text(
                                                                    "Are you sure you want to delete ${patient["name"]}?",
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () => Navigator.pop(
                                                                            context,
                                                                            false,
                                                                          ),
                                                                      child: const Text(
                                                                        "Cancel",
                                                                      ),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () => Navigator.pop(
                                                                            context,
                                                                            true,
                                                                          ),
                                                                      child: const Text(
                                                                        "Delete",
                                                                        style: TextStyle(
                                                                          color:
                                                                              Colors.red,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                          );
                                                        } else if (direction ==
                                                            DismissDirection
                                                                .startToEnd) {
                                                          return await _editPatient(
                                                            patient,
                                                          );
                                                        }
                                                        return false;
                                                      },
                                                      onDismissed: (direction) {
                                                        if (direction ==
                                                            DismissDirection
                                                                .endToStart) {
                                                          _deletePatient(
                                                            patient,
                                                          );
                                                        }
                                                      },
                                                      child: Card(
                                                        elevation: 5,
                                                        margin:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                15,
                                                              ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                15,
                                                              ),
                                                          child: Row(
                                                            children: [
                                                              CircleAvatar(
                                                                radius: 30,
                                                                backgroundColor:
                                                                    Colors.teal
                                                                        .withOpacity(
                                                                          0.1,
                                                                        ),
                                                                child: Text(
                                                                  patient["name"]
                                                                              ?.isNotEmpty ==
                                                                          true
                                                                      ? patient["name"][0]
                                                                          .toUpperCase()
                                                                      : "?",
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        Colors
                                                                            .teal,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 15,
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children:
                                                                      _buildPatientSummary(
                                                                        patient,
                                                                      ),
                                                                ),
                                                              ),
                                                              FutureBuilder<
                                                                bool
                                                              >(
                                                                future: patientService
                                                                    .hasClinicalData(
                                                                      patient["_id"]
                                                                              ?.toString() ??
                                                                          "",
                                                                    ),
                                                                builder: (
                                                                  context,
                                                                  snapshot,
                                                                ) {
                                                                  if (snapshot
                                                                          .connectionState ==
                                                                      ConnectionState
                                                                          .waiting) {
                                                                    return const SizedBox(
                                                                      width: 24,
                                                                      height:
                                                                          24,
                                                                      child: CircularProgressIndicator(
                                                                        color:
                                                                            Colors.teal,
                                                                        strokeWidth:
                                                                            2,
                                                                      ),
                                                                    );
                                                                  }
                                                                  final hasClinicalData =
                                                                      snapshot
                                                                          .data ??
                                                                      false;
                                                                  return IconButton(
                                                                    icon: Icon(
                                                                      Icons
                                                                          .medical_services,
                                                                      color:
                                                                          hasClinicalData
                                                                              ? Colors.grey
                                                                              : Colors.teal,
                                                                    ),
                                                                    onPressed:
                                                                        hasClinicalData
                                                                            ? null
                                                                            : () => _showAddClinicalDataDialog(
                                                                              context,
                                                                              patient["_id"]?.toString() ??
                                                                                  "",
                                                                            ),
                                                                    tooltip:
                                                                        hasClinicalData
                                                                            ? 'Clinical Data Already Added'
                                                                            : 'Add Clinical Data',
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "patients_fab", // Unique tag for PatientsScreen FAB
        onPressed: showAddPatientDialog,
        backgroundColor: Colors.teal.shade700,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  List<Widget> _buildPatientSummary(Map<String, dynamic> patient) {
    return [
      Text(
        patient["name"] ?? "Unknown",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        "Gender: ${patient["gender"] ?? "N/A"}",
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      ),
      const SizedBox(height: 4),
      Text(
        "DOB: ${patient["dob"] ?? "N/A"}",
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      ),
      const SizedBox(height: 4),
      Text(
        "Age: ${_calculateAge(patient["dob"])}",
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      ),
    ];
  }
}
