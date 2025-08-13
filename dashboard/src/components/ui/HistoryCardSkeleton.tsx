import { VStack, Box, HStack, Skeleton } from "@chakra-ui/react";
import { Dot } from "lucide-react";

export const HistoryCardSkeleton = () => {
  return (
    <VStack
      bg={{ _dark: "#6d6d6d", _light: "#cbc5cc" }}
      width={{ base: "300px", md: "220px" }}
      height="auto"
      padding="0.5rem"
      borderRadius="10px"
      boxShadow="xs"
      alignItems="start"
      gap="2px"
    >
      {/* District and Time */}
      <HStack justifyContent="space-between" width="100%">
        <HStack gap="0px" marginLeft="-10px">
          <Dot opacity={0.3} /> {/* Semi-transparent dot */}
          <Skeleton height="14px" width="80px" />
        </HStack>
        <Skeleton height="12px" width="50px" />
      </HStack>

      {/* Address */}
      <VStack width="100%" alignItems="start" paddingLeft="10px" gap="0px">
        <Skeleton height="14px" width="120px" mt={1} />
        <Skeleton height="12px" width="160px" mt={1} />
      </VStack>

      {/* Date */}
      <Box width="100%" paddingTop="5px" paddingBottom="5px">
        <Skeleton height="12px" width="100px" />
      </Box>
    </VStack>
  );
};
