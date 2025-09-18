import {
    useFonts as useBaumans,
    Baumans_400Regular,
  } from "@expo-google-fonts/baumans";
  
  import {
    useFonts as useAROneSans,
    AROneSans_400Regular,
    AROneSans_500Medium,
    AROneSans_700Bold,
  } from "@expo-google-fonts/ar-one-sans";
  
  export const useGlobalFonts = () => {
    const [baumansLoaded] = useBaumans({ Baumans_400Regular });
    const [arOneSansLoaded] = useAROneSans({
      AROneSans_400Regular,
      AROneSans_500Medium,
      AROneSans_700Bold,
    });
  
    return baumansLoaded && arOneSansLoaded;
  };
  