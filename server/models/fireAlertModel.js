const mongoose = require("mongoose");

// ✅ Fire Alert Schema (MongoDB)
const fireAlertSchema = new mongoose.Schema({
  location: { type: [Number], required: false },
  address: {
    apartment: { type: String, required: false },
    street: { type: String, required: false },
    district: { type: String, required: false },
  },

  temperature: { type: Number, required: false },
  smokeLevel: { type: String, required: false },
  timestamp: { type: Date, default: Date.now },
});

module.exports = mongoose.model("AlertHistory", fireAlertSchema);
