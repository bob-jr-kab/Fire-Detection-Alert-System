import { useState } from "react";
import { useRouter } from "expo-router";
import {
  Image,
  ImageBackground,
  TextInput,
  TouchableOpacity,
  View,
} from "react-native";
import AppText from "@/components/ui/AppText";
import { Feather, FontAwesome, MaterialIcons } from "@expo/vector-icons";

const logo = require("../assets/images/logo.png");
const bgImg = require("../assets/images/bg-2.png");

export default function SignUp() {
  const router = useRouter();
  const [agree, setAgree] = useState(false);

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

      <View className="bg-white -mt-12 rounded-t-3xl border-2 border-gray-200 p-4 h-3/5">
        <View className="h-full bg-white items-center shadow-2xl border-2 border-gray-300 border-t-0 shadow-black/60 rounded-b-3xl rounded-t-xl">
          <AppText weight="bold" className="text-xl mt-6">
            Create Account
          </AppText>

          {/* Email input */}
          <View className="flex-row items-center bg-gray-100 px-4 py-2 rounded-lg mb-4 w-11/12 mt-4">
            <FontAwesome name="envelope" size={16} color="gray" />
            <TextInput
              placeholder="Your email address"
              keyboardType="email-address"
              className="ml-2 flex-1 text-sm"
            />
          </View>

          {/* Password input */}
          <View className="flex-row items-center bg-gray-100 px-4 py-2 rounded-lg mb-4 w-11/12">
            <Feather name="lock" size={16} color="gray" />
            <TextInput
              placeholder="Password"
              secureTextEntry
              className="ml-2 flex-1 text-sm"
            />
          </View>

          {/* Confirm Password */}
          <View className="flex-row items-center bg-gray-100 px-4 py-2 rounded-lg mb-2 w-11/12">
            <Feather name="lock" size={16} color="gray" />
            <TextInput
              placeholder="Confirm Password"
              secureTextEntry
              className="ml-2 flex-1 text-sm"
            />
          </View>

          {/* Terms and Conditions Checkbox */}
          <TouchableOpacity
            className="flex-row items-center ml-4 mt-8 mb-2 w-11/12"
            onPress={() => setAgree(!agree)}
            activeOpacity={0.8}
          >
            <MaterialIcons
              name={agree ? "check-box" : "check-box-outline-blank"}
              size={15}
              color={agree ? "#4f46e5" : "#888"}
            />
            <AppText className="ml-2 text-xs">
              I agree to the{" "}
              <AppText className="text-blue-600 underline">
                Terms and Conditions
              </AppText>
            </AppText>
          </TouchableOpacity>

          {/* Sign Up Button */}
          <TouchableOpacity
            disabled={!agree}
            className={`p-4 rounded-xl mt-2 mb-4 w-3/4 ${
              agree ? "bg-customBg" : "bg-gray-300"
            }`}
            onPress={() => {
              if (agree) router.push("/home"); // navigate only if agreed
            }}
          >
            <AppText className="text-white text-center font-semibold">
              Sign Up
            </AppText>
          </TouchableOpacity>

          {/* Already have account */}
          <View className="flex-row items-center mt-2">
            <AppText className="text-sm">Already have an account?</AppText>
            <AppText
              className="pl-2 text-xs text-blue-600"
              onPress={() => router.push("/login")}
            >
              Sign In
            </AppText>
          </View>
        </View>
      </View>
    </View>
  );
}
