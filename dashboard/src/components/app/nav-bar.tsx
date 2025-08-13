import { HStack, Image, Text } from "@chakra-ui/react";
import { ColorModeButton } from "../ui/color-mode";

function navbar() {
  return (
    <HStack
      height="50px"
      justifyContent="space-between"
      bg={{ _dark: "#3c3c3c", _light: "#808080" }}
      color="white"
      fontSize="1rem"
      borderBottom={"1px #4d4d4d solid"}
      padding={{ base: "0 1rem 0 1rem", md: "0 2rem 0 2rem" }}
    >
      <HStack gap="1rem" alignItems="center">
        <Image src="/logo.png" height="70px" marginTop={"5"} />{" "}
        <Text fontFamily="cursive"> FIRE DEPARTMENT</Text>
      </HStack>
      <ColorModeButton
        borderRadius={"50%"}
        bg={{ _light: "GrayText", _dark: "#4d4d4d" }}
      />
    </HStack>
  );
}

export default navbar;
