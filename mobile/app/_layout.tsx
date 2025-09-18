import "../global.css";
import { useGlobalFonts } from "../hooks/useGlobalFonts";
import { Text, View } from "react-native";
import { Stack } from "expo-router";

export default function RootLayout() {
  const fontsLoaded = useGlobalFonts();

  if (!fontsLoaded) {
    return (
      <View>
        <Text>Loading fonts...</Text>
      </View>
    );
  }

  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="index" />
      <Stack.Screen name="login" />
      <Stack.Screen name="signup" />
      <Stack.Screen name="home" />
      <Stack.Screen name="settings" />
    </Stack>
  );
}
