let io = null;

const initSocket = (server) => {
  io = require("socket.io")(server, {
    cors: {
      origin: "*", // ✅ allow dev tunnels + flutter
      methods: ["GET", "POST"],
    },
    transports: ["polling", "websocket"], // ✅ REQUIRED
  });

  io.on("connection", (socket) => {
    console.log("🟢 Socket.IO client connected:", socket.id);

    socket.emit("connected", { status: "ok" });

    socket.on("disconnect", () => {
      console.log("🔴 Socket.IO client disconnected:", socket.id);
    });
  });

  return io;
};

module.exports = { initSocket };
