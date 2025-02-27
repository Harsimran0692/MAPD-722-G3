import 'package:flutter/material.dart';
import 'package:frontend/models/patients.dart';
import 'package:frontend/widgets/patient_card.dart';

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
  String searchQuery = "";
  int _selectedIndex = 0;

  // Form controllers for adding new patient
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedGender = 'Male';

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
        filteredPatients = patients;
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
            final matchesStatus =
                filterStatus == "All" || patient["status"] == filterStatus;
            final matchesName = patient["name"].toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
            return matchesStatus && matchesName;
          }).toList();
    });
  }

  void showFilterModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
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
                  "Filter by Status",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children:
                      ["All", "Stable", "Critical", "Recovering"].map((status) {
                        return ChoiceChip(
                          label: Text(status),
                          selected: filterStatus == status,
                          onSelected: (selected) {
                            setState(() {
                              filterStatus = status;
                              filterPatients();
                              Navigator.pop(context);
                            });
                          },
                          selectedColor: Colors.teal,
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(
                            color:
                                filterStatus == status
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showAddPatientDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Add New Patient'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator:
                        (value) => value!.isEmpty ? 'Name is required' : null,
                  ),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) => value!.isEmpty ? 'Age is required' : null,
                  ),
                  TextFormField(
                    controller: _dobController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth (YYYY-MM-DD)',
                    ),
                    validator:
                        (value) => value!.isEmpty ? 'DOB is required' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items:
                        ['Male', 'Female', 'Other']
                            .map(
                              (gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                    validator:
                        (value) => value == null ? 'Gender is required' : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Email is required'
                                : !value.contains('@')
                                ? 'Enter a valid email'
                                : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // if (_formKey.currentState!.validate()) {
                //   try {
                //     final newPatient = {
                //       'name': _nameController.text,
                //       'age': int.parse(_ageController.text),
                //       'dob':
                //           DateTime.parse(_dobController.text).toIso8601String(),
                //       'gender': _selectedGender,
                //       'email': _emailController.text,
                //     };

                //     await patientService.addPatient(
                //       newPatient,
                //     ); // Assuming this method exists
                //     fetchPatients();
                //     Navigator.pop(context);

                //     _nameController.clear();
                //     _ageController.clear();
                //     _dobController.clear();
                //     _emailController.clear();
                //     _selectedGender = 'Male';

                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(
                //         content: Text('Patient added successfully'),
                //       ),
                //     );
                //   } catch (e) {
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(content: Text('Error adding patient: $e')),
                //     );
                //   }
                // }
              },
              child: const Text('Add Patient'),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      "https://www.gravatar.com/avatar/2c7d99fe281ecd3bcd65ab915bac6dd5?s=250",
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000080),
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
                  const SizedBox(width: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search Patient",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        searchQuery = value;
                        filterPatients();
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
            const Text(
              "Patients",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006400),
                fontStyle: FontStyle.italic,
              ),
            ),
            Expanded(
              child: ListView.builder(
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
      // bottomNavigationBar: BottomNavBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddPatientDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
