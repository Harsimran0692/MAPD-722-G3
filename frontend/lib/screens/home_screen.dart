import 'package:flutter/material.dart';
import 'package:frontend/models/patients.dart'; // Adjust import
import 'package:frontend/widgets/patient_card.dart'; // Adjust import
import 'package:frontend/widgets/add_patient.dart'; // Import the new widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Patients patientService = Patients();
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  String filterStatus = "All";
  String filterGender = "All";
  String searchQuery = "";
  RangeValues ageRange = const RangeValues(0, 100); // Default age range

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    try {
      final fetchedPatients = await patientService.fetchData();
      setState(() {
        patients = fetchedPatients;
        filteredPatients = List.from(patients);
        filterPatients();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching patients: $e')));
      print('Error fetching patients: $e');
    }
  }

  void filterPatients() {
    setState(() {
      filteredPatients =
          patients.where((patient) {
            // Status filter
            final patientStatus = patient["status"]?.toString() ?? "";
            final matchesStatus =
                filterStatus == "All" ||
                patientStatus.toLowerCase() == filterStatus.toLowerCase();

            // Gender filter
            final patientGender =
                patient["patientId"]["gender"]?.toString() ?? "";
            final matchesGender =
                filterGender == "All" ||
                patientGender.toLowerCase() == filterGender.toLowerCase();

            // Age filter
            final patientDob =
                patient["patientId"]["dob"] != null
                    ? DateTime.tryParse(patient["patientId"]["dob"])
                    : null;
            final patientAge =
                patientDob != null
                    ? DateTime.now().year - patientDob.year
                    : 0; // Approximate age
            final matchesAge =
                patientAge >= ageRange.start && patientAge <= ageRange.end;

            // Name filter (Search)
            final patientName = patient["patientId"]["name"]?.toString() ?? "";
            final trimmedQuery = searchQuery.trim().toLowerCase();
            final matchesName =
                trimmedQuery.isEmpty ||
                patientName.toLowerCase().contains(trimmedQuery);

            return matchesStatus && matchesGender && matchesAge && matchesName;
          }).toList();
    });
  }

  void showFilterModal() {
    String tempFilterStatus = filterStatus;
    String tempFilterGender = filterGender;
    RangeValues tempAgeRange = ageRange;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Advanced Filters",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0277BD),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Status",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 10,
                          children:
                              ["All", "Stable", "Critical", "Recovering"].map((
                                status,
                              ) {
                                return ChoiceChip(
                                  label: Text(status),
                                  selected: tempFilterStatus == status,
                                  onSelected: (selected) {
                                    setStateDialog(
                                      () => tempFilterStatus = status,
                                    );
                                  },
                                  selectedColor: const Color(0xFF00C4B4),
                                  backgroundColor: Colors.grey[200],
                                  labelStyle: TextStyle(
                                    color:
                                        tempFilterStatus == status
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Gender",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 10,
                          children:
                              ["All", "Male", "Female", "Other"].map((gender) {
                                return ChoiceChip(
                                  label: Text(gender),
                                  selected: tempFilterGender == gender,
                                  onSelected: (selected) {
                                    setStateDialog(
                                      () => tempFilterGender = gender,
                                    );
                                  },
                                  selectedColor: const Color(0xFF00C4B4),
                                  backgroundColor: Colors.grey[200],
                                  labelStyle: TextStyle(
                                    color:
                                        tempFilterGender == gender
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Age Range",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        RangeSlider(
                          values: tempAgeRange,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          labels: RangeLabels(
                            tempAgeRange.start.round().toString(),
                            tempAgeRange.end.round().toString(),
                          ),
                          activeColor: const Color(0xFF00C4B4),
                          onChanged: (RangeValues values) {
                            setStateDialog(() => tempAgeRange = values);
                          },
                        ),
                        const SizedBox(height: 12),
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
                                  filterStatus = tempFilterStatus;
                                  filterGender = tempFilterGender;
                                  ageRange = tempAgeRange;
                                  filterPatients();
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C4B4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Apply",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  void showAddPatientDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddPatientDialog(
            patientService: patientService,
            fetchPatients: fetchPatients,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SenCare",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 1, 69, 1),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: fetchPatients,
          color: const Color(0xFF00C4B4),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          "https://www.gravatar.com/avatar/2c7d99fe281ecd3bcd65ab915bac6dd5?s=250",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Welcome Back!",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0277BD),
                              ),
                            ),
                            Text(
                              "Dr. Adma Smith",
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFF8B0000),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search Patient",
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF00C4B4),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value; // Update searchQuery
                              filterPatients(); // Re-filter patients based on new query
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: showFilterModal,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Patients (${filteredPatients.length})",
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006400),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child:
                      filteredPatients.isEmpty
                          ? const Center(
                            child: Text(
                              "No patients found",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: filteredPatients.length,
                            itemBuilder: (context, index) {
                              final patient = filteredPatients[index];
                              return PatientCard(patient: patient);
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddPatientDialog,
        backgroundColor: const Color(0xFF00C4B4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
