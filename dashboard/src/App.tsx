import { Box } from "@chakra-ui/react";
import Navbar from "./components/app/nav-bar";
import Layout from "./layout";
function App() {
  return (
    <Box bg={{ _dark: "#212121", _light: "#ffffff" }} minHeight="100vh">
      <Navbar />
      <Layout />
    </Box>
  );
}

export default App;
