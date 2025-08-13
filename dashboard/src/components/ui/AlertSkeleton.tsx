import { Skeleton, Box, VStack, HStack } from "@chakra-ui/react";
import { motion } from "framer-motion";

const MotionBox = motion(Box);
export const AlertSkeleton = () => {
  return (
    <MotionBox
      initial={{ opacity: 0.5 }}
      animate={{ opacity: 1 }}
      transition={{ repeat: Infinity, duration: 1, repeatType: "reverse" }}
      width="300px"
      height="210px"
      p="1rem"
      borderRadius="10px"
      borderWidth="2px"
      boxShadow="xs"
    >
      <VStack align="stretch" gap={4}>
        {/* Header */}
        <Box textAlign="right">
          <Skeleton height="20px" width="60%" ml="auto" />
        </Box>

        {/* Alert Title */}
        <HStack>
          <Skeleton width="40px" height="40px" borderRadius="full" />
          <Skeleton height="20px" width="100px" />
        </HStack>

        <Skeleton height="1px" width="100%" />

        {/* Address */}
        <HStack gap={4} pl="30px">
          <Skeleton width="30px" height="30px" />
          <VStack align="start" gap={2}>
            <Skeleton height="16px" width="120px" />
            <Skeleton height="16px" width="180px" />
          </VStack>
        </HStack>

        {/* Stats */}
        <HStack gap={6}>
          <HStack>
            <Skeleton width="20px" height="20px" />
            <Skeleton height="16px" width="80px" />
          </HStack>
          <HStack>
            <Skeleton width="20px" height="20px" />
            <Skeleton height="16px" width="80px" />
          </HStack>
        </HStack>

        {/* Button */}
        <Box textAlign="right">
          <Skeleton height="25px" width="74px" borderRadius="15px" ml="auto" />
        </Box>
      </VStack>
    </MotionBox>
  );
};

export default AlertSkeleton;
