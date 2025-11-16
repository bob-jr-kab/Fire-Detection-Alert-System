import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String emergencyNumber = "199";
  String name = "John";
  String apartment = "FAYA APART";
  String address = "Mimoza sk , Marmara 52";

  bool saveLocation = false;

  bool editingEmergency = false;
  bool editingPersonal = false;

  final TextEditingController emergencyController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      emergencyNumber = prefs.getString("emergencyNumber") ?? "199";
      name = prefs.getString("name") ?? "John";
      apartment = prefs.getString("apartment") ?? "FAYA APART";
      address = prefs.getString("address") ?? "Mimoza sk , Marmara 52";
      saveLocation = prefs.getBool("saveLocation") ?? false;
    });
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("emergencyNumber", emergencyNumber);
    await prefs.setString("name", name);
    await prefs.setString("apartment", apartment);
    await prefs.setString("address", address);
    await prefs.setBool("saveLocation", saveLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 220,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8C79E6), Color(0xFFD87CB9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // Header
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
                      SizedBox(width: 10),
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

                // White content panel (fill full remaining height)
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
                          // Emergency Number Section
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
                                        saveData();
                                      });
                                    }),
                                  ],
                                )
                              : _infoRow("Emergency Number", emergencyNumber),
                          const SizedBox(height: 25),

                          // Personal Details Section
                          _sectionTitle("Personal Details", () {
                            setState(() {
                              editingPersonal = true;
                              nameController.text = name;
                              apartmentController.text = apartment;
                              addressController.text = address;
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
                                    const SizedBox(height: 12),
                                    _saveButton(() {
                                      setState(() {
                                        name = nameController.text.trim();
                                        apartment = apartmentController.text
                                            .trim();
                                        address = addressController.text.trim();
                                        editingPersonal = false;
                                        saveData();
                                      });
                                    }),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _infoRow("Name", name),
                                    _infoRow("Apartment", apartment),
                                    _infoRow("Address", address),
                                  ],
                                ),
                          const SizedBox(height: 25),

                          // Save Location Toggle
                          Row(
                            children: [
                              Switch(
                                value: saveLocation,
                                onChanged: (val) {
                                  setState(() {
                                    saveLocation = val;
                                    saveData();
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Save Current Location",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),

                          const SizedBox(height: 35),

                          // Menu Items
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

  // --------------------------
  // WIDGET HELPERS
  // --------------------------
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
