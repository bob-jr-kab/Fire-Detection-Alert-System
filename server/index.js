const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const http = require("http");
const { initSocket } = require("./config/socket");
const mongoose = require("mongoose");

dotenv.config();

const app = express();
const server = http.createServer(app);

// ✅ Initialize Socket.IO
const io = initSocket(server);

// ✅ Middleware
app.use(
  cors({
    origin: [
      "https://rhkbbkgq-3000.euw.devtunnels.ms", // ✅ Allow full ngrok domain (HTTPS)
      /\.ngrok\.io$/, // wildcard for fallback
      /localhost(:\d+)?$/,
      /192\.168\.\d+\.\d+(:\d+)?$/, // local IPs
    ],
    credentials: true,
  })
);
app.use(express.json());
// ✅ Make io available in routes
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("🔥 Connected to MongoDB"))
  .catch((err) => console.error("❌ MongoDB connection error:", err));

// ✅ Make io available in routes
app.set("socketio", io);
app.post("/api/sensor-data", (req, res) => {
  const sensorData = req.body;
  console.log("Received sensor data from ESP:", sensorData);

  // Get the io instance and broadcast the data WITH the pairingToken
  const io = req.app.get("socketio");
  io.emit("sensor-data", {
    device_id: sensorData.device_id,
    temperature: sensorData.temperature,
    humidity: sensorData.humidity,
    smokeLevel: sensorData.smokeLevel,
    flameDetected: sensorData.flameDetected,
    ipAddress: sensorData.ipAddress,
    pairingToken: sensorData.pairingToken, // ✅ CRITICAL: Forward this token
  });

  res.status(200).send("Data received successfully");
});
// ✅ Routes
const fireAlertRoutes = require("./routes/AlertRouter");
app.use("/api/fire-alerts", fireAlertRoutes);

// ✅ Start Server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
  console.log(`🌐 Accepting WebSocket connections via WSS`);
});
