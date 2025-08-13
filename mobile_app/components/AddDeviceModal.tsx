// components/AddDeviceModal.tsx
import React, { useState } from "react";
import {
  Modal,
  View,
  TextInput,
  Button,
  StyleSheet,
  TouchableOpacity,
} from "react-native";
import AppText from "./ui/AppText"; // Assuming you have this AppText component
import { AntDesign } from "@expo/vector-icons"; // For close icon

type AddDeviceModalProps = {
  visible: boolean;
  onClose: () => void;
  onDeviceAdded: (device: { id: string; name: string }) => void;
};

const ESP32_AP_IP = "192.168.4.1"; // Default IP when ESP32 is in AP mode

const AddDeviceModal: React.FC<AddDeviceModalProps> = ({
  visible,
  onClose,
  onDeviceAdded,
}) => {
  const [step, setStep] = useState(1);
  const [homeSsid, setHomeSsid] = useState("");
  const [homePassword, setHomePassword] = useState("");
  const [deviceName, setDeviceName] = useState("");
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  const resetState = () => {
    setStep(1);
    setHomeSsid("");
    setHomePassword("");
    setDeviceName("");
    setLoading(false);
    setErrorMessage("");
  };

  const handleSendCredentials = async () => {
    if (!homeSsid.trim() || !homePassword.trim() || !deviceName.trim()) {
      setErrorMessage(
        "Please fill all fields: Home Wi-Fi SSID, Password, and Device Name."
      );
      return;
    }

    setLoading(true);
    setErrorMessage("");

    try {
      // Create URL-encoded form data
      const formBody = `ssid=${encodeURIComponent(
        homeSsid
      )}&password=${encodeURIComponent(
        homePassword
      )}&deviceName=${encodeURIComponent(deviceName)}`;

      console.log("Sending form data:", formBody);
      console.log("Request URL:", `http://${ESP32_AP_IP}/config`);
      console.log("Request headers:", {
        "Content-Type": "application/x-www-form-urlencoded",
      });

      const response = await fetch(`http://${ESP32_AP_IP}/config`, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: formBody,
      });

      console.log("Response status:", response.status);
      const result = await response.json();
      console.log("Response body:", result);

      if (response.ok) {
        console.log("ESP32 Config Response:", result);
        if (result.deviceId) {
          onDeviceAdded({ id: result.deviceId, name: deviceName });
          setStep(3);
        } else {
          setErrorMessage(
            "ESP32 did not return a device ID. Configuration might be incomplete."
          );
        }
      } else {
        setErrorMessage(
          `Failed to send config to ESP32: ${result.message || "Unknown error"}`
        );
        console.error("ESP32 Config Error:", result);
      }
    } catch (error) {
      console.error("Network error sending config to ESP32:", error);
      setErrorMessage(
        "Could not connect to ESP32. Ensure your phone is connected to the ESP32's Wi-Fi AP."
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <Modal
      animationType="slide"
      transparent={true}
      visible={visible}
      onRequestClose={onClose}
    >
      <View style={styles.centeredView}>
        <View style={styles.modalView}>
          <TouchableOpacity
            onPress={() => {
              onClose();
              resetState();
            }}
            style={styles.closeButton}
          >
            <AntDesign name="closecircle" size={24} color="grey" />
          </TouchableOpacity>

          <AppText style={styles.modalTitle}>Add New Device</AppText>

          {step === 1 && (
            <View>
              <AppText style={styles.modalText}>
                Step 1: Power on your new SafeSpark device. It will create a
                Wi-Fi network named similar to "SafeSpark_ESP_XXXX".
                <AppText weight="bold">
                  {" "}
                  Please manually connect your phone to this Wi-Fi network in
                  your phone's settings.
                </AppText>
              </AppText>
              <Button
                title="I'm Connected to ESP's Wi-Fi"
                onPress={() => setStep(2)}
              />
            </View>
          )}

          {step === 2 && (
            <View style={styles.stepContainer}>
              <AppText style={styles.modalText}>
                Step 2: Enter your home Wi-Fi details and a name for this
                device.
              </AppText>
              <TextInput
                style={styles.input}
                placeholder="Device Name (e.g., Kitchen)"
                value={deviceName}
                onChangeText={setDeviceName}
              />
              <TextInput
                style={styles.input}
                placeholder="Your Home Wi-Fi SSID"
                value={homeSsid}
                onChangeText={setHomeSsid}
                autoCapitalize="none"
              />
              <TextInput
                style={styles.input}
                placeholder="Your Home Wi-Fi Password"
                value={homePassword}
                onChangeText={setHomePassword}
                secureTextEntry
                autoCapitalize="none"
              />
              {errorMessage ? (
                <AppText style={styles.errorMessage}>{errorMessage}</AppText>
              ) : null}
              <Button
                title={loading ? "Sending..." : "Send Credentials to Device"}
                onPress={handleSendCredentials}
                disabled={loading}
              />
            </View>
          )}

          {step === 3 && (
            <View>
              <AppText style={styles.modalText}>
                Success! Your device has received the Wi-Fi credentials.
                <AppText weight="bold">
                  {" "}
                  Now, please reconnect your phone to your normal home Wi-Fi
                  network.
                </AppText>
                Your device will attempt to connect to the home Wi-Fi and start
                sending data.
              </AppText>
              <Button
                title="Done"
                onPress={() => {
                  onClose();
                  resetState();
                }}
              />
            </View>
          )}
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  centeredView: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "rgba(0,0,0,0.6)",
  },
  modalView: {
    margin: 20,
    backgroundColor: "white",
    borderRadius: 20,
    padding: 25,
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
    width: "90%",
    maxHeight: "80%",
  },
  closeButton: {
    position: "absolute",
    top: 10,
    right: 10,
    zIndex: 1,
  },
  modalTitle: {
    fontSize: 22,
    fontWeight: "bold",
    marginBottom: 20,
    textAlign: "center",
  },
  modalText: {
    marginBottom: 15,
    textAlign: "center",
    fontSize: 16,
  },
  stepContainer: {
    width: "100%",
  },
  input: {
    height: 45,
    borderColor: "#ddd",
    borderWidth: 1,
    borderRadius: 8,
    marginBottom: 15,
    paddingHorizontal: 12,
    width: "100%",
    backgroundColor: "#f9f9f9",
  },
  errorMessage: {
    color: "red",
    textAlign: "center",
    marginBottom: 10,
  },
});

export default AddDeviceModal;
