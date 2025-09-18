import AppText from "@/components/ui/AppText";
import { AntDesign, Feather } from "@expo/vector-icons";
import AsyncStorage from "@react-native-async-storage/async-storage";
import * as Location from "expo-location";
import { useRouter } from "expo-router";
import { useEffect, useState } from "react";
import {
  Alert,
  Image,
  ImageBackground,
  Switch,
  TextInput,
  TouchableOpacity,
  View,
} from "react-native";

const logo = require("../assets/images/logo.png");
const bgImg = require("../assets/images/bg-2.png");

export default function Settings() {
  const [emailAlert, setEmailAlert] = useState(true);
  const [smsAlert, setSmsAlert] = useState(false);

  const [emergencyNumber, setEmergencyNumber] = useState("");
  const [name, setName] = useState("");
  const [apartment, setApartment] = useState("");
  const [address, setAddress] = useState("");
  // Changed location to store an array of numbers [longitude, latitude]
  const [location, setLocation] = useState<number[] | null>(null);
  // Added state for district
  const [district, setDistrict] = useState("");

  const [isEditingNumber, setIsEditingNumber] = useState(false);
  const [isEditingDetails, setIsEditingDetails] = useState(false);
  const [initialData, setInitialData] = useState({
    emergencyNumber: "",
    name: "",
    apartment: "",
    address: "",
    district: "", // Added district to initialData
  });

  // Updated hasChanges to include district
  const hasChanges =
    emergencyNumber !== initialData.emergencyNumber ||
    name !== initialData.name ||
    apartment !== initialData.apartment ||
    address !== initialData.address ||
    district !== initialData.district;

  useEffect(() => {
    const loadData = async () => {
      const storedNumber = await AsyncStorage.getItem("emergencyNumber");
      const storedName = await AsyncStorage.getItem("name");
      const storedApartment = await AsyncStorage.getItem("apartment");
      const storedAddress = await AsyncStorage.getItem("address");
      const storedDistrict = await AsyncStorage.getItem("district"); // Load district
      const storedLocation = await AsyncStorage.getItem("location");

      setEmergencyNumber(storedNumber || "");
      setName(storedName || "");
      setApartment(storedApartment || "");
      setAddress(storedAddress || "");
      setDistrict(storedDistrict || ""); // Set district state

      // Parse stored location back into an array
      if (storedLocation) {
        try {
          // Attempt to parse as JSON array (new format)
          setLocation(JSON.parse(storedLocation));
        } catch (e) {
          console.error(
            "Failed to parse stored location as JSON array, attempting old format:",
            e
          );
          // If JSON parsing fails, try to parse the old comma-separated string format
          const parts = storedLocation
            .split(",")
            .map((part) => parseFloat(part.trim()));
          if (parts.length === 2 && !isNaN(parts[0]) && !isNaN(parts[1])) {
            // Assuming the old format was "latitude, longitude" and we want [longitude, latitude]
            const oldFormatCoords = [parts[1], parts[0]];
            setLocation(oldFormatCoords);
            // Immediately save the corrected format back to AsyncStorage
            await AsyncStorage.setItem(
              "location",
              JSON.stringify(oldFormatCoords)
            );
          } else {
            console.error(
              "Stored location is neither valid JSON nor old comma-separated format:",
              storedLocation
            );
            setLocation(null);
          }
        }
      } else {
        setLocation(null);
      }

      setInitialData({
        emergencyNumber: storedNumber || "",
        name: storedName || "",
        apartment: storedApartment || "",
        address: storedAddress || "",
        district: storedDistrict || "", // Set initial district
      });
    };

    loadData();
  }, []);

  const handleSave = async () => {
    await AsyncStorage.setItem("emergencyNumber", emergencyNumber);
    await AsyncStorage.setItem("name", name);
    await AsyncStorage.setItem("apartment", apartment);
    await AsyncStorage.setItem("address", address);
    await AsyncStorage.setItem("district", district); // Save district

    setInitialData({ emergencyNumber, name, apartment, address, district }); // Update initialData
    setIsEditingNumber(false);
    setIsEditingDetails(false);
  };

  const handleGetLocation = async () => {
    const { status } = await Location.requestForegroundPermissionsAsync();
    if (status !== "granted") {
      Alert.alert("Permission Denied", "Location permission is required.");
      return;
    }

    const loc = await Location.getCurrentPositionAsync({});
    // Store location as [longitude, latitude] array
    const coords = [loc.coords.longitude, loc.coords.latitude];
    setLocation(coords);
    // Store the array as a JSON string in AsyncStorage
    await AsyncStorage.setItem("location", JSON.stringify(coords));
  };
  const router = useRouter();
  return (
    <View className="h-full bg-white">
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
        <View className="absolute top-12 right-4 mt-4 p-2 bg-black w-8 h-8 rounded-full items-center justify-center">
          <AppText className="text-white font-bold">B</AppText>
        </View>

        <Image source={logo} className="w-12 h-12" />
        <AppText font="baumans" className="text-3xl text-white pl-4">
          SafeSpark
        </AppText>
      </ImageBackground>

      <View className="bg-white -mt-12 rounded-t-3xl border-2 border-gray-200 p-4 shadow-3xl h-5/6">
        <View className="flex-row  gap-2 mb-4">
          <TouchableOpacity onPress={() => router.push("/home")}>
            <AntDesign name="arrowleft" size={24} color="black" />
          </TouchableOpacity>

          <AppText font="baumans" className="font-bold text-xl">
            Settings
          </AppText>
        </View>

        <View className="ml-4">
          {/* Alerts */}
          <View className="flex-row justify-between items-center mb-2">
            <AppText className="text-base">Email Alerts</AppText>
            <Switch value={emailAlert} onValueChange={setEmailAlert} />
          </View>
          <View className="flex-row justify-between items-center mb-4">
            <AppText className="text-base">Sms Alerts</AppText>
            <Switch value={smsAlert} onValueChange={setSmsAlert} />
          </View>

          {/* Emergency Number */}
          <View className="flex-row justify-between items-center">
            <AppText className="text-lg font-semibold">
              Emergency Number
            </AppText>
            <TouchableOpacity
              onPress={() => setIsEditingNumber(!isEditingNumber)}
            >
              <Feather name="edit-3" size={16} />
            </TouchableOpacity>
          </View>
          {isEditingNumber ? (
            <TextInput
              value={emergencyNumber}
              onChangeText={setEmergencyNumber}
              className="border rounded-lg px-3 py-2 my-2"
              keyboardType="phone-pad"
            />
          ) : (
            <AppText className="text-base ml-2 text-gray-500 mb-2">
              Emergency Number: {emergencyNumber}
            </AppText>
          )}

          {/* Personal Details */}
          <View className="flex-row justify-between items-center">
            <AppText className="text-lg font-semibold">
              Personal Details
            </AppText>
            <TouchableOpacity
              onPress={() => setIsEditingDetails(!isEditingDetails)}
            >
              <Feather name="edit-3" size={16} />
            </TouchableOpacity>
          </View>

          {isEditingDetails ? (
            <>
              <TextInput
                value={name}
                onChangeText={setName}
                placeholder="Name"
                className="border rounded-lg px-3 py-2 my-1"
              />
              <TextInput
                value={apartment}
                onChangeText={setApartment}
                placeholder="Apartment"
                className="border rounded-lg px-3 py-2 my-1"
              />
              <TextInput
                value={address}
                onChangeText={setAddress}
                placeholder="Street Address"
                className="border rounded-lg px-3 py-2 my-1"
              />
              {/* New input for District */}
              <TextInput
                value={district}
                onChangeText={setDistrict}
                placeholder="District"
                className="border rounded-lg px-3 py-2 my-1"
              />
            </>
          ) : (
            <>
              <AppText className="text-base ml-2 text-gray-500">
                Name: {name}
              </AppText>
              <AppText className="text-base ml-2 text-gray-500">
                Apartment: {apartment}
              </AppText>
              <AppText className="text-base ml-2 text-gray-500">
                Street Address: {address}
              </AppText>
              {/* Display District */}
              <AppText className="text-base ml-2 text-gray-500">
                District: {district}
              </AppText>
            </>
          )}

          {/* Location */}
          <AppText className="text-base ml-2 mt-4 text-gray-500">
            Save Current Location:
          </AppText>
          {location && (
            // Display longitude and latitude
            <AppText className="text-sm ml-2 text-gray-500">
              Longitude: {location[0]}, Latitude: {location[1]}
            </AppText>
          )}
          <TouchableOpacity
            onPress={handleGetLocation}
            className="bg-blue-100 border border-blue-400 rounded-md px-4 py-2 mt-2 mb-4 w-48 items-center"
          >
            <AppText className="text-blue-600">Get Location</AppText>
          </TouchableOpacity>

          {/* Save Button */}
          {(isEditingNumber || isEditingDetails) && (
            <TouchableOpacity
              disabled={!hasChanges}
              onPress={handleSave}
              className={`py-3 rounded-xl items-center ${
                hasChanges ? "bg-blue-500" : "bg-gray-300"
              }`}
            >
              <AppText className="text-white font-semibold">Save</AppText>
            </TouchableOpacity>
          )}

          {/* Policies */}
          <AppText className="text-lg mt-4 font-semibold">
            Privacy Policy
          </AppText>
          <AppText className="text-lg mt-2 font-semibold">
            Terms and Conditions
          </AppText>
        </View>

        {/* Logout */}
        <TouchableOpacity
          onPress={() => router.replace("/")}
          className="bg-red-400 py-3 rounded-xl mt-6 items-center"
        >
          <AppText className="text-white font-semibold">LogOut</AppText>
        </TouchableOpacity>
      </View>
    </View>
  );
}
