const express = require("express");
const router = express.Router();
const FireAlert = require("../models/fireAlertModel.js");
const firestore = require("../config/firebaseConfig.js"); // RTDB
const socket = require("../config/socket");
// 🔌 ESP32 sends real-time sensor data here
router.post("/sensor-data", (req, res) => {
  const sensorData = req.body;
  // IMPORTANT: The sensorData object MUST contain 'pairingToken'
  // as sent by the ESP32 hardware.
  const socketio = req.app.get("socketio");
  socketio.emit("sensor-data", sensorData);
  res.status(200).send("Data received");
});

// ✅ Mobile app confirms a fire alert → this route stores it
router.post("/confirm-alert", async (req, res) => {
  try {
    const alert = req.body;

    // Validate essential fields. 'location' is now expected to be an array.
    if (
      !alert ||
      !alert.location ||
      !Array.isArray(alert.location) ||
      alert.location.length !== 2 || // Ensure location is a 2-element array
      !alert.temperature === undefined ||
      !alert.smokeLevel === undefined ||
      !alert.device_id
    ) {
      return res
        .status(400)
        .json({ message: "Incomplete or invalid fire alert data" });
    }

    const savedAlert = await FireAlert.create({
      ...alert,
      timestamp: new Date(),
    });

    await firestore.collection("fireAlerts").add({
      ...alert,
      timestamp: new Date().toISOString(),
    });

    console.log("🔥 Alert saved to MongoDB & Firebase RTDB");

    res
      .status(201)
      .json({ message: "Alert confirmed and stored", id: savedAlert._id });
  } catch (error) {
    console.error("❌ Error confirming fire alert:", error);
    res.status(500).json({ message: "Error storing fire alert", error });
  }
});

// GET all confirmed alerts (from MongoDB)
router.get("/", async (req, res) => {
  try {
    const alerts = await FireAlert.find().sort({ timestamp: -1 });
    res.json(alerts);
  } catch (error) {
    res.status(500).json({ message: "Error fetching fire alerts", error });
  }
});

module.exports = router;
