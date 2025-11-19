import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Stored Data
  String emergencyNumber = "";
  String name = "";
  String apartment = "";
  String address = "";
  String district = "";

  List<double>? locationCoords; // [longitude, latitude]

  bool saveLocation = false;

  bool editingEmergency = false;
  bool editingPersonal = false;

  // Controllers
  final emergencyController = TextEditingController();
  final nameController = TextEditingController();
  final apartmentController = TextEditingController();
  final addressController = TextEditingController();
  final districtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ---------------------------
  // Load FROM SharedPreferences
  // ---------------------------
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      emergencyNumber = prefs.getString("emergencyNumber") ?? "199";
      name = prefs.getString("name") ?? "John";
      apartment = prefs.getString("apartment") ?? "FAYA APART";
      address = prefs.getString("address") ?? "Mimoza sk , Marmara 52";
      district = prefs.getString("district") ?? "";
      saveLocation = prefs.getBool("saveLocation") ?? false;

      // Load coords
      final lon = prefs.getDouble("longitude");
      final lat = prefs.getDouble("latitude");
      if (lon != null && lat != null) {
        locationCoords = [lon, lat];
      }
    });
  }

  // ---------------------------
  // Save TO SharedPreferences
  // ---------------------------
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("emergencyNumber", emergencyNumber);
    await prefs.setString("name", name);
    await prefs.setString("apartment", apartment);
    await prefs.setString("address", address);
    await prefs.setString("district", district);

    await prefs.setBool("saveLocation", saveLocation);

    if (locationCoords != null) {
      await prefs.setDouble("longitude", locationCoords![0]);
      await prefs.setDouble("latitude", locationCoords![1]);
    }
  }

  // ---------------------------
  // Fetch Location
  // ---------------------------
  Future<void> getLocation() async {
    bool perm = await Geolocator.isLocationServiceEnabled();
    if (!perm) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission required")),
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition();

    setState(() {
      locationCoords = [pos.longitude, pos.latitude];
    });

    saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Gradient
        Container(
          height: 220,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8C79E6), Color(0xFFD87CB9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 26,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Image.asset("assets/images/logo.png", height: 48),
                      const SizedBox(width: 10),
                      const Text(
                        "SafeSpark",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // WHITE PANEL
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(26),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // EMERGENCY SECTION
                          _sectionTitle("Emergency Number", () {
                            setState(() {
                              editingEmergency = true;
                              emergencyController.text = emergencyNumber;
                            });
                          }),

                          const SizedBox(height: 10),

                          editingEmergency
                              ? Column(
                                  children: [
                                    TextField(
                                      controller: emergencyController,
                                      keyboardType: TextInputType.phone,
                                      decoration: _inputBox("Emergency Number"),
                                    ),
                                    const SizedBox(height: 10),
                                    _saveButton(() {
                                      setState(() {
                                        emergencyNumber = emergencyController
                                            .text
                                            .trim();
                                        editingEmergency = false;
                                      });
                                      saveData();
                                    }),
                                  ],
                                )
                              : _infoRow("Emergency Number", emergencyNumber),

                          const SizedBox(height: 25),

                          // PERSONAL DETAILS
                          _sectionTitle("Personal Details", () {
                            setState(() {
                              editingPersonal = true;
                              nameController.text = name;
                              apartmentController.text = apartment;
                              addressController.text = address;
                              districtController.text = district;
                            });
                          }),

                          const SizedBox(height: 10),

                          editingPersonal
                              ? Column(
                                  children: [
                                    TextField(
                                      controller: nameController,
                                      decoration: _inputBox("Name"),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: apartmentController,
                                      decoration: _inputBox("Apartment"),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: addressController,
                                      decoration: _inputBox("Address"),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: districtController,
                                      decoration: _inputBox("District"),
                                    ),
                                    const SizedBox(height: 12),
                                    _saveButton(() {
                                      setState(() {
                                        name = nameController.text.trim();
                                        apartment = apartmentController.text
                                            .trim();
                                        address = addressController.text.trim();
                                        district = districtController.text
                                            .trim();
                                        editingPersonal = false;
                                      });
                                      saveData();
                                    }),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _infoRow("Name", name),
                                    _infoRow("Apartment", apartment),
                                    _infoRow("Address", address),
                                    _infoRow("District", district),
                                  ],
                                ),

                          const SizedBox(height: 25),

                          // Location Toggle
                          Row(
                            children: [
                              Switch(
                                value: saveLocation,
                                onChanged: (val) {
                                  setState(() {
                                    saveLocation = val;
                                  });
                                  saveData();

                                  if (val == true) getLocation();
                                },
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Save Current Location",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),

                          if (locationCoords != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "Longitude: ${locationCoords![0]}, Latitude: ${locationCoords![1]}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),

                          const SizedBox(height: 30),

                          _menuItem("User Manual"),
                          _menuItem("Terms and Conditions"),
                          _menuItem("Privacy Policy"),
                        ],
                      ),
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

  // ----------------------------
  // Helpers
  // ----------------------------
  Widget _sectionTitle(String title, VoidCallback onEdit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, size: 20)),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text("$label : $value", style: const TextStyle(fontSize: 16)),
    );
  }

  InputDecoration _inputBox(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _saveButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.black,
        ),
        child: const Text("Save"),
      ),
    );
  }

  Widget _menuItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }
}
