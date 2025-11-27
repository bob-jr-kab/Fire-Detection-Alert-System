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

    if (saveLocation && locationCoords != null) {
      await prefs.setDouble("longitude", locationCoords![0]);
      await prefs.setDouble("latitude", locationCoords![1]);
    } else {
      // Remove location data when toggle is off
      await prefs.remove("longitude");
      await prefs.remove("latitude");
      setState(() {
        locationCoords = null;
      });
    }
  }

  // ---------------------------
  // Fetch Location
  // ---------------------------
  Future<void> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable location services")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location permission permanently denied. Please enable in settings.",
          ),
        ),
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        locationCoords = [position.longitude, position.latitude];
      });

      await saveData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location saved successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to get location: $e")));
    }
  }

  // ---------------------------
  // Clear Location Data
  // ---------------------------
  Future<void> clearLocationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("longitude");
    await prefs.remove("latitude");

    setState(() {
      locationCoords = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Location data cleared")));
  }

  // ---------------------------
  // Handle Location Toggle
  // ---------------------------
  Future<void> handleLocationToggle(bool value) async {
    setState(() {
      saveLocation = value;
    });

    if (value) {
      // Toggle ON - get location
      await getLocation();
    } else {
      // Toggle OFF - clear location data
      await clearLocationData();
    }

    await saveData();
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
                // HEADER with Breadcrumb
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Breadcrumb
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Home",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Settings",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Main Header
                      Row(
                        children: [
                          Image.asset("assets/images/logo.png", height: 48),
                          const SizedBox(width: 12),
                          const Text(
                            "SafeSpark Settings",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

                          // LOCATION SECTION
                          _sectionTitle("Location Settings", null),

                          const SizedBox(height: 15),

                          // Location Toggle Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Save Current Location",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Switch(
                                      value: saveLocation,
                                      onChanged: handleLocationToggle,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "Enable to automatically include your location in emergency alerts",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Location Status
                                if (saveLocation && locationCoords != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green.shade600,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Location Saved",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                "Coordinates: ••••••••, ••••••••",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: clearLocationData,
                                          icon: Icon(
                                            Icons.refresh,
                                            color: Colors.grey.shade600,
                                            size: 20,
                                          ),
                                          tooltip: "Refresh location",
                                        ),
                                      ],
                                    ),
                                  )
                                else if (saveLocation && locationCoords == null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.orange.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_searching,
                                          color: Colors.orange.shade600,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Expanded(
                                          child: Text(
                                            "Fetching location... Tap refresh",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: getLocation,
                                          icon: Icon(
                                            Icons.refresh,
                                            color: Colors.orange.shade600,
                                            size: 20,
                                          ),
                                          tooltip: "Get location",
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_off,
                                          color: Colors.grey.shade600,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Expanded(
                                          child: Text(
                                            "Location saving disabled",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // OTHER SETTINGS
                          _sectionTitle("Other Settings", null),
                          const SizedBox(height: 10),
                          _menuItem("User Manual", Icons.help_outline),
                          _menuItem("Terms and Conditions", Icons.description),
                          _menuItem("Privacy Policy", Icons.privacy_tip),

                          const SizedBox(height: 20),
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
  Widget _sectionTitle(String title, VoidCallback? onEdit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "Not set",
              style: TextStyle(
                fontSize: 16,
                color: value.isNotEmpty ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputBox(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _saveButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: const Color(0xFF8C79E6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Save Changes",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _menuItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }
}
