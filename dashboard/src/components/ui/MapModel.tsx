import { TileLayer, Marker, Popup, MapContainer } from "react-leaflet";
import L from "leaflet";
import "leaflet/dist/leaflet.css";

// Fix for default marker icons
const DefaultIcon = L.icon({
  iconUrl: "./map-pin.png",
  // iconRetinaUrl: "/images/marker-icon-2x.png",
  // shadowUrl: "/images/marker-shadow.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
});

L.Marker.prototype.options.icon = DefaultIcon;

interface MapComponentProps {
  center: [number, number];
}

export default function MapComponent({ center }: MapComponentProps) {
  return (
    <MapContainer
      center={center}
      zoom={15}
      style={{
        height: "100%", // Takes full height of parent
        width: "100%", // Takes full width of parent
        borderRadius: "inherit", // Inherits from parent
      }}
    >
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      />
      <Marker position={center}>
        <Popup>Alert Location</Popup>
      </Marker>
    </MapContainer>
  );
}
