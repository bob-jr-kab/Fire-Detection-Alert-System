import { useRouter } from "expo-router";
import AppText from "@/components/ui/AppText";
import { Image, ImageBackground, View, TouchableOpacity } from "react-native";
import { TextInput } from "react-native";
import { Feather, FontAwesome } from "@expo/vector-icons";
const logo = require("../assets/images/logo.png");
const bgImg = require("../assets/images/bg-2.png");

export default function Index() {
  const router = useRouter();

  return (
    <View className="h-full bg-white">
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
          <AppText weight="bold" className="text-xl mt-6 ">
            Sign In{" "}
          </AppText>
          {/* Email input */}
          <View className="flex-row items-center bg-gray-100 px-4 py-2 rounded-lg mb-4 w-11/12 mt-12">
            <FontAwesome name="envelope" size={16} color="gray" />
            <TextInput
              placeholder="Your email address"
              keyboardType="email-address"
              className="ml-2 flex-1 text-sm "
            />
          </View>
          {/* Password input */}
          <View className="flex-row items-center bg-gray-100 px-4 py-2 rounded-lg mb-6 w-11/12 mt-4">
            <Feather name="lock" size={16} color="gray" />
            <TextInput
              placeholder="Password"
              secureTextEntry
              className="ml-2 flex-1 text-sm "
            />
          </View>

          <AppText className=" text-xs mt-12 text-left ">
            Forgot Password
          </AppText>

          {/* Login Button */}
          <TouchableOpacity
            className="bg-customBg p-4 rounded-xl mt-2 mb-2 w-3/4"
            onPress={() => router.push("/home")}
          >
            <AppText className="text-white text-center  font-semibold">
              Login
            </AppText>
          </TouchableOpacity>

          <View className=" flex-row items-center  g-4  mt-4 mb-4">
            <AppText className="pl-2 text-sm  ">Don't have an account?</AppText>
            <AppText
              className="pl-2 text-xs text-blue-600 "
              onPress={() => router.push("/signup")}
            >
              SignUp
            </AppText>
          </View>
        </View>
      </View>
    </View>
  );
}
