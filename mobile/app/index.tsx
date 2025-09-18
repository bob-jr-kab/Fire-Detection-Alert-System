import { useRouter } from "expo-router";
import AppText from "@/components/ui/AppText";
import { Image, ImageBackground, View, TouchableOpacity } from "react-native";
import { StatusBar } from "react-native";

const logo = require("../assets/images/logo.png");
const bgImg = require("../assets/images/bg-2.png");
const fireImage = require("../assets/images/fireImage.png");

export default function Index() {
  const router = useRouter();

  return (
    <View className="h-full bg-white">
      <StatusBar barStyle="dark-content" backgroundColor="white" translucent />
      <ImageBackground
        source={bgImg}
        style={{ flex: 1, justifyContent: "center", alignItems: "center" }}
        resizeMode="cover"
      >
        <Image source={logo} className="w-32 h-32" />
        <AppText font="baumans" className="text-3xl text-white">
          SafeSpark
        </AppText>
      </ImageBackground>

      <View className=" bg-white -mt-12 rounded-t-3xl border-2 border-gray-200 p-4 shadow-3xl; h-3/5">
        <View className="h-full bg-white items-center  shadow-2xl border-2 border-gray-300 border-t-0  shadow-black/60 rounded-b-3xl rounded-t-xl">
          <View className="mt-12  mb-4">
            <Image source={fireImage} />
          </View>

          <AppText className="text-lg bg-white text-center mb-4">
            Ensuring your safety during fire {"\n"} emergencies.
          </AppText>

          {/* Login Button */}
          <TouchableOpacity
            className="bg-customBg p-4 rounded-xl mb-4 w-3/4"
            onPress={() => router.push("/login")}
          >
            <AppText className="text-white text-center font-semibold">
              Get Started
            </AppText>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}
