import AddDeviceModal from "@/components/AddDeviceModal"; // Import the new modal component
import AppText from "@/components/ui/AppText";
import { Feather } from "@expo/vector-icons";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { Picker } from "@react-native-picker/picker";
import { useRouter } from "expo-router";
import { useEffect, useState } from "react";
import { Image, ImageBackground, TouchableOpacity, View } from "react-native";
import Popover from "react-native-popover-view";
import { io } from "socket.io-client";

const logo = require("../assets/images/logo.png");
const bgImg = require("../assets/images/bg-2.png");
const smokeIcon = require("../assets/images/smoke.png");
const humidityIcon = require("../assets/images/Humidity.png");
const temperatureIcon = require("../assets/images/Temperature.png");
const flameIcon = require("../assets/images/flame.png");

const SERVER_URL = "https://9b23e1ce033d.ngrok-free.app";

type Device = {
  id: string;
  name: string;
};

type SensorData = {
  temperature: number;
  humidity: number;
  smokeLevel: number;
  flameDetected: boolean;
  device_id: string; // Sensor data now includes device_id
  device_name?: string; // Optional: The friendly name might also come from ESP
};

type AllSensorData = {
  [deviceId: string]: SensorData;
};

export default function Home() {
  const router = useRouter();
  const [allSensorData, setAllSensorData] = useState<AllSensorData>({});
  const [devices, setDevices] = useState<Device[]>([]);
  // Changed type to string | undefined and initialized to undefined
  const [selectedDeviceId, setSelectedDeviceId] = useState<string | undefined>(
    undefined
  );
  const [showAddDeviceModal, setShowAddDeviceModal] = useState(false);

  // Load devices and selected device from AsyncStorage on component mount
  useEffect(() => {
    const loadDevices = async () => {
      try {
        const storedDevices = await AsyncStorage.getItem("devices");
        let parsedDevices: Device[] = [];
        if (storedDevices) {
          parsedDevices = JSON.parse(storedDevices);
          setDevices(parsedDevices);
        }

        const storedSelectedDeviceId = await AsyncStorage.getItem(
          "selectedDeviceId"
        );

        // If a stored ID exists, use it. Otherwise, if there are devices, select the first one.
        // Otherwise, leave as undefined.
        if (storedSelectedDeviceId) {
          setSelectedDeviceId(storedSelectedDeviceId);
        } else if (parsedDevices.length > 0) {
          setSelectedDeviceId(parsedDevices[0].id);
        } else {
          setSelectedDeviceId(undefined); // Ensure it's undefined if no devices
        }
      } catch (error) {
        console.error("Failed to load devices from AsyncStorage:", error);
        setDevices([]); // Clear devices on error
        setSelectedDeviceId(undefined); // Clear selected ID on error
      }
    };
    loadDevices();
  }, []); // Empty dependency array means this runs once on mount

  // Update selected device if devices array changes or if the currently selected one becomes invalid
  useEffect(() => {
    // If there are devices but no device is selected, select the first one
    if (devices.length > 0 && selectedDeviceId === undefined) {
      setSelectedDeviceId(devices[0].id);
    }
    // If a device is selected but it's no longer in the 'devices' list (e.g., removed)
    else if (
      selectedDeviceId !== undefined &&
      !devices.find((d) => d.id === selectedDeviceId)
    ) {
      // Select the first available device, or set to undefined if no devices left
      setSelectedDeviceId(devices.length > 0 ? devices[0].id : undefined);
    }
  }, [devices, selectedDeviceId]); // Rerun if devices or selectedDeviceId changes

  // Effect to handle WebSocket connection and data updates
  useEffect(() => {
    const socket = io(SERVER_URL, { transports: ["websocket"] });
    socket.on("connect", () =>
      console.log("✅ Connected to WebSocket Server!")
    );

    socket.on("sensor-data", (data: SensorData) => {
      // Update the allSensorData state with the new data
      setAllSensorData((prevData) => ({
        ...prevData,
        [data.device_id]: data,
      }));

      // If this is a new device (not in current devices state) and no device is selected, automatically select it
      // This is helpful if the first device added is the one sending data
      if (
        !devices.some((d) => d.id === data.device_id) &&
        selectedDeviceId === undefined
      ) {
        const newDevice: Device = {
          id: data.device_id,
          name:
            data.device_name ||
            `Device ${data.device_id.substring(data.device_id.length - 5)}`, // Use last 5 chars of MAC if no name
        };
        const updatedDevices = [...devices, newDevice];
        setDevices(updatedDevices);
        setSelectedDeviceId(newDevice.id);
        AsyncStorage.setItem("devices", JSON.stringify(updatedDevices));
        AsyncStorage.setItem("selectedDeviceId", newDevice.id);
      }
    });

    socket.on("connect_error", (err) =>
      console.error("Connection error:", err.message)
    );

    return () => {
      socket.disconnect();
    };
  }, [devices, selectedDeviceId]); // Rerun if devices or selectedDeviceId changes

  // Function to save devices to AsyncStorage
  const saveDevices = async (updatedDevices: Device[]) => {
    try {
      await AsyncStorage.setItem("devices", JSON.stringify(updatedDevices));
      setDevices(updatedDevices);
    } catch (error) {
      console.error("Failed to save devices to AsyncStorage:", error);
    }
  };

  // Function to save selected device ID to AsyncStorage
  // Updated to accept string | undefined
  const saveSelectedDeviceId = async (deviceId: string | undefined) => {
    try {
      if (deviceId !== undefined) {
        await AsyncStorage.setItem("selectedDeviceId", deviceId);
      } else {
        await AsyncStorage.removeItem("selectedDeviceId"); // Remove if setting to undefined
      }
      setSelectedDeviceId(deviceId);
    } catch (error) {
      console.error(
        "Failed to save selected device ID to AsyncStorage:",
        error
      );
    }
  };

  // Callback when a device is successfully added via the modal
  const handleDeviceAdded = async (newDevice: { id: string; name: string }) => {
    const updatedDevices = [...devices, newDevice];
    await saveDevices(updatedDevices);
    await saveSelectedDeviceId(newDevice.id); // Automatically select the new device
    setShowAddDeviceModal(false); // Close the modal
  };

  // Get sensor data for the currently selected device
  const currentSensorData = selectedDeviceId
    ? allSensorData[selectedDeviceId]
    : undefined; // Changed from null to undefined for consistency

  const handleAlert = async () => {
    if (!currentSensorData || selectedDeviceId === undefined) {
      // Check for undefined
      console.warn(
        "No Data",
        "Sensor data or selected device is not available yet."
      );
      return;
    }

    try {
      // 1. Get user info from AsyncStorage
      const name = await AsyncStorage.getItem("name");
      const apartment = await AsyncStorage.getItem("apartment");
      const address = await AsyncStorage.getItem("address");
      const district = await AsyncStorage.getItem("district");
      const storedLocation = await AsyncStorage.getItem("location");

      let parsedLocation: number[] | null = null; // Explicitly type parsedLocation
      if (storedLocation) {
        try {
          parsedLocation = JSON.parse(storedLocation);
        } catch (e) {
          console.error(
            "Failed to parse stored location as JSON array, attempting old format:",
            e
          );
          const parts = storedLocation
            .split(",")
            .map((part) => parseFloat(part.trim()));
          if (parts.length === 2 && !isNaN(parts[0]) && !isNaN(parts[1])) {
            parsedLocation = [parts[1], parts[0]];
          } else {
            console.error(
              "Stored location is neither valid JSON nor old comma-separated format:",
              storedLocation
            );
            parsedLocation = null;
          }
        }
      }

      const alertPayload = {
        ...currentSensorData, // Use data from the selected device
        location: parsedLocation,
        address: {
          apartment: apartment || "N/A",
          street: address || "N/A",
          district: district || "N/A",
        },
        name: name || "Unknown User",
        device_id: selectedDeviceId, // Use the selected device's ID
      };

      const response = await fetch(
        `${SERVER_URL}/api/fire-alerts/confirm-alert`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(alertPayload),
        }
      );

      const result = await response.json();

      if (response.ok) {
        console.log("Alert Sent!", "The authorities have been notified.");
      } else {
        console.error("Error", result.message || "Could not send the alert.");
      }
    } catch (error) {
      console.error("❌ Error sending alert:", error);
      console.error(
        "Network Error",
        "Failed to send the alert. Please check your connection."
      );
    }
  };

  const lastUpdated = new Date().toLocaleTimeString();

  return (
    <View className="h-full bg-white">
      {/* Header */}
      <ImageBackground
        source={bgImg}
        style={{
          flex: 1,
          flexDirection: "row",
          alignItems: "center",
          paddingLeft: 20,
        }}
        resizeMode="cover"
      >
        <TouchableOpacity
          onPress={() => router.push("/settings")}
          className="absolute top-12 right-4 mt-4 p-2"
        >
          <Feather name="settings" size={20} color="white" />
        </TouchableOpacity>
        {/* Add Device Button */}
        <TouchableOpacity
          onPress={() => setShowAddDeviceModal(true)}
          className="absolute top-12 right-12 mt-4 p-2"
        >
          <Feather name="plus-circle" size={20} color="white" />
        </TouchableOpacity>

        <Image source={logo} className="w-12 h-12" />
        <AppText font="baumans" className="text-3xl text-white pl-4">
          SafeSpark
        </AppText>
      </ImageBackground>

      {/* Main content */}
      <View className="bg-white -mt-12 rounded-t-3xl border-2 border-gray-200 p-4 shadow-3xl h-5/6">
        <AppText className="text-sm bg-white text-left mb-2">
          Last Updated: {lastUpdated}
        </AppText>

        {/* Device Selector */}
        {devices.length > 0 ? (
          <View className="mb-4 border rounded-lg border-gray-300 overflow-hidden">
            <Picker
              selectedValue={selectedDeviceId} // This is now string | undefined
              onValueChange={(itemValue: string) =>
                saveSelectedDeviceId(itemValue)
              }
              style={{ height: 50, width: "100%", backgroundColor: "#f0f0f0" }}
              itemStyle={{ fontSize: 16 }} // Adjust font size for items
            >
              {devices.map((device) => (
                <Picker.Item
                  key={device.id}
                  label={device.name}
                  value={device.id}
                />
              ))}
            </Picker>
          </View>
        ) : (
          <AppText className="text-center text-gray-500 mb-4">
            No devices added yet. Tap '+' to add one.
          </AppText>
        )}

        {/* Sensor Data Display */}
        {currentSensorData ? (
          <>
            {/* Temperature Card */}
            <View className="bg-cardBg border-2 border-gray-200 rounded-lg p-4 mb-4 shadow-md justify-between items-center">
              <AppText weight="bold" className="text-xl">
                Temperature
              </AppText>
              <Popover
                from={
                  <TouchableOpacity className="absolute top-2 right-2">
                    <Feather name="info" size={16} color="grey" />
                  </TouchableOpacity>
                }
              >
                <View className="p-2">
                  <AppText>
                    Normal: 20-26°C. High temps `{"> 40°C"}` can indicate fire
                    risk.
                  </AppText>
                </View>
              </Popover>
              <View className="flex-row gap-4 mt-3">
                <AppText font="baumans" className="text-3xl text-customText">
                  {currentSensorData
                    ? `${currentSensorData.temperature.toFixed(1)} °C`
                    : "-- °C"}
                </AppText>
                <Image source={temperatureIcon} className="w-12 h-12" />
              </View>
            </View>

            {/* Humidity */}
            <View className="bg-cardBg border-2 border-gray-200 rounded-lg p-4 mb-4 shadow-md justify-between items-center">
              <AppText weight="bold" className="text-xl">
                Humidity
              </AppText>
              <Popover
                from={
                  <TouchableOpacity className="absolute top-2 right-2">
                    <Feather name="info" size={16} color="grey" />
                  </TouchableOpacity>
                }
              >
                <View className="p-2">
                  <AppText>
                    Measures moisture in the air. Very low humidity can increase
                    static electricity.
                  </AppText>
                </View>
              </Popover>
              <View className="flex-row gap-4 mt-3">
                <AppText font="baumans" className="text-3xl text-customText">
                  {currentSensorData
                    ? `${currentSensorData.humidity.toFixed(1)}%`
                    : "-- %"}
                </AppText>
                <Image source={humidityIcon} className="w-12 h-12" />
              </View>
            </View>

            {/* Smoke */}
            <View className="bg-cardBg border-2 border-gray-200 rounded-lg p-4 mb-4 shadow-md justify-between items-center">
              <AppText weight="bold" className="text-xl">
                Smoke
              </AppText>
              <Popover
                from={
                  <TouchableOpacity className="absolute top-2 right-2">
                    <Feather name="info" size={16} color="grey" />
                  </TouchableOpacity>
                }
              >
                <View className="p-2">
                  <AppText>
                    Detects smoke particles (ppm). Levels above 300 ppm are
                    considered dangerous.
                  </AppText>
                </View>
              </Popover>
              <View className="flex-row gap-4 mt-3">
                <AppText font="baumans" className="text-3xl text-customText">
                  {currentSensorData
                    ? `${currentSensorData.smokeLevel} ppm`
                    : "-- ppm"}
                </AppText>
                <Image source={smokeIcon} className="w-12 h-12" />
              </View>
            </View>

            {/* Flame */}
            <View className="bg-cardBg border-2 border-gray-200 rounded-lg p-4 mb-4 shadow-md justify-between items-center">
              <AppText weight="bold" className="text-xl">
                Flame Status
              </AppText>
              <Popover
                from={
                  <TouchableOpacity className="absolute top-2 right-2">
                    <Feather name="info" size={16} color="grey" />
                  </TouchableOpacity>
                }
              >
                <View className="p-2">
                  <AppText>
                    This sensor looks for the infrared signature of a direct
                    flame.
                  </AppText>
                </View>
              </Popover>
              <View className="flex-row gap-4 mt-3 items-center">
                {currentSensorData?.flameDetected ? (
                  <View>
                    <AppText font="baumans" className="text-3xl text-red-600">
                      Flame Detected
                    </AppText>
                    <Image source={flameIcon} className="w-12 h-12" />
                  </View>
                ) : (
                  <AppText font="baumans" className="text-3xl text-gray-500">
                    No Flame Detected
                  </AppText>
                )}
              </View>
            </View>

            {/* Alert Button */}
            <View className="items-center mt-6">
              <TouchableOpacity
                onPress={handleAlert}
                className="bg-customBg w-24 h-24 border-4 border-red-500 rounded-full justify-center items-center mb-4"
              >
                <AppText className="text-white text-center font-semibold">
                  Alert
                </AppText>
              </TouchableOpacity>
            </View>
          </>
        ) : (
          <AppText className="text-center text-gray-500 mt-8">
            {selectedDeviceId
              ? "Waiting for sensor data..."
              : "Please add and select a device to view data."}
          </AppText>
        )}
      </View>

      {/* Add Device Modal Component */}
      <AddDeviceModal
        visible={showAddDeviceModal}
        onClose={() => setShowAddDeviceModal(false)}
        onDeviceAdded={handleDeviceAdded}
      />
    </View>
  );
}
