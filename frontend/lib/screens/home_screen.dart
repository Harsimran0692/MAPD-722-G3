import 'package:flutter/material.dart';
import 'package:frontend/models/patients.dart';
import 'package:frontend/screens/patients_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/widgets/patient_card.dart';
import 'package:frontend/widgets/add_patient.dart';

// HomeScreen widget to display the main dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // Constructor for HomeScreen

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// State class for HomeScreen with animation support
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final Patients patientService = Patients(); // Service to fetch patient data
  List<Map<String, dynamic>> patients = []; // List of all patients
  List<Map<String, dynamic>> filteredPatients = []; // Filtered list of patients
  String filterStatus = "All"; // Status filter state
  String filterGender = "All"; // Gender filter state
  String searchQuery = ""; // Search query state
  RangeValues ageRange = const RangeValues(0, 100); // Age range filter state

  String userName = "Dr. John Smith"; // User's name
  String userEmail = "john.smith@example.com"; // User's email
  String userImage =
      "https://www.gravatar.com/avatar/2c7d99fe281ecd3bcd65ab915bac6dd5?s=250"; // User's profile image URL

  int _selectedIndex =
      1; // Current index for bottom navigation (default to Home)
  late AnimationController _animationController; // Controller for animations
  late Animation<double> _fadeAnimation; // Fade animation for UI elements
  bool _isLoading = true; // Loading state indicator

  @override
  void initState() {
    super.initState();
    // Initialize animation controller and start animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _fetchPatientsOnLoad(); // Fetch patients when screen loads
  }

  @override
  void dispose() {
    _animationController.dispose(); // Clean up animation controller
    super.dispose();
  }

  // Fetch patients when screen loads and update loading state
  Future<void> _fetchPatientsOnLoad() async {
    setState(() {
      _isLoading = true;
    });
    await fetchPatientsClinical();
    setState(() {
      _isLoading = false;
    });
  }

  // Fetch patient data with clinical information from API
  Future<void> fetchPatientsClinical() async {
    try {
      final fetchedPatients = await patientService.fetchPatientsClinical();
      setState(() {
        patients = fetchedPatients;
        filteredPatients = List.from(patients);
        filterPatients(); // Apply filters after fetching
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching patients: $e')));
      setState(() {
        patients = [];
        filteredPatients = [];
      });
    }
  }

  // Filter patients based on status, gender, age, and search query
  void filterPatients() {
    setState(() {
      filteredPatients =
          patients.where((patient) {
            final patientStatus =
                patient["status"]?.toString().toLowerCase() ?? "";
            final matchesStatus =
                filterStatus == "All" ||
                patientStatus == filterStatus.toLowerCase();
            final patientGender =
                patient["patientId"]?["gender"]?.toString().toLowerCase() ?? "";
            final matchesGender =
                filterGender == "All" ||
                patientGender == filterGender.toLowerCase();
            final patientDob = DateTime.tryParse(
              patient["patientId"]?["dob"] ?? "",
            );
            final patientAge =
                patientDob != null ? DateTime.now().year - patientDob.year : 0;
            final matchesAge =
                patientAge >= ageRange.start && patientAge <= ageRange.end;
            final patientName =
                patient["patientId"]?["name"]?.toString().toLowerCase() ?? "";
            final matchesName =
                searchQuery.trim().isEmpty ||
                patientName.contains(searchQuery.trim().toLowerCase());
            return matchesStatus && matchesGender && matchesAge && matchesName;
          }).toList();
    });
  }

  // Show modal for advanced filtering options
  void showFilterModal() {
    String tempFilterStatus = filterStatus;
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
                                "Status",
                                ["All", "Stable", "Critical", "Recovering"],
                                tempFilterStatus,
                                setStateDialog,
                                (value) => tempFilterStatus = value,
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
                                        filterStatus = tempFilterStatus;
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

  // Build filter section widget for status or gender options
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
                  onSelected: (bool selected) {
                    setStateDialog(() {
                      onSelected(option);
                    });
                  },
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

  // Show dialog to add a new patient
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
            fetchPatients: fetchPatientsClinical,
          ),
    );
  }

  // Update user profile information
  void _onProfileUpdated(String newName, String newEmail) {
    setState(() {
      userName = newName;
      userEmail = newEmail;
    });
  }

  // Handle bottom navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        _fetchPatientsOnLoad(); // Refresh patients when switching to Home
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex, // Show the selected screen
        children: [
          ProfileScreen(
            userName: userName,
            userEmail: userEmail,
            userImage: userImage,
            onProfileUpdated: _onProfileUpdated,
          ), // Profile screen
          _buildHomeContent(), // Home content
          PatientsScreen(patients: filteredPatients), // Patients screen
        ],
      ),
      floatingActionButton:
          _selectedIndex == 2
              ? FloatingActionButton(
                heroTag: "home_fab",
                onPressed: showAddPatientDialog,
                backgroundColor: Colors.teal,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              )
              : null, // FAB only on Patients screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Patients"),
        ],
      ),
    );
  }

  // Build the content for the Home tab
  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 4),
      ); // Show loading spinner
    }

    return Column(
      children: [
        // Header section with user info and search bar
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(0, 50, 17, 1), Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(userImage),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome Back!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(1, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.teal),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search Patient",
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.teal,
                            ),
                            border: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                              filterPatients();
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: showFilterModal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        elevation: 6,
                        shadowColor: Colors.teal,
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Patients (${filteredPatients.length})",
                  style: const TextStyle(
                    fontSize: 26,
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
            ],
          ),
        ),
        // Scrollable patient list section
        Expanded(
          child: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: RefreshIndicator(
              onRefresh: fetchPatientsClinical, // Refresh patient data
              color: Colors.teal,
              child:
                  filteredPatients.isEmpty
                      ? Center(
                        child: Text(
                          "No patients found",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filteredPatients.length,
                        itemBuilder:
                            (context, index) => AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 400),
                              child: PatientCard(
                                patient: filteredPatients[index],
                              ),
                            ),
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
