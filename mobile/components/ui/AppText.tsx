import React from "react";
import { Text, TextProps, TextStyle } from "react-native";

type FontWeight = "regular" | "medium" | "bold";
type FontName = "baumans" | "arOneSans";

interface AppTextProps extends TextProps {
  weight?: FontWeight;
  font?: FontName;
}

const fontMap: Record<FontName, Record<FontWeight, string>> = {
  baumans: {
    regular: "Baumans_400Regular",
    medium: "Baumans_400Regular",
    bold: "Baumans_400Regular",
  },
  arOneSans: {
    regular: "AROneSans_400Regular",
    medium: "AROneSans_500Medium",
    bold: "AROneSans_700Bold",
  },
};

export default function AppText({
  children,
  style,
  weight = "regular",
  font = "arOneSans",
  ...props
}: AppTextProps) {
  const fontFamily = fontMap[font][weight];

  return (
    <Text {...props} style={[{ fontFamily } as TextStyle, style]}>
      {children}
    </Text>
  );
}
