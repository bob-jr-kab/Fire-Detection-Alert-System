import { VStack, Text, Box, HStack } from "@chakra-ui/react";
import React, { useEffect, useState } from "react";
import axios from "axios";
import {
  formatMongoTimestamp,
  formatRelativeTime,
} from "../../config/timeFormat.ts";
import { Dot } from "lucide-react";
import { HistoryCardSkeleton } from "../ui/HistoryCardSkeleton.tsx";

interface FireAlert {
  _id: string;
  timestamp: string;
  address: {
    apartment: string;
    street: string;
    district: string;
  };
}

const HistoryCard: React.FC = () => {
  const [fireAlerts, setFireAlerts] = useState<FireAlert[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    axios
      .get<FireAlert[]>("http://localhost:3000/api/fire-alerts")
      .then((response) => {
        setFireAlerts(response.data);
        setIsLoading(false);
      })
      .catch((error) => {
        console.error("Error fetching data:", error);
        setIsLoading(false);
      });
  }, []);

  return (
    <>
      {isLoading
        ? Array.from({ length: 3 }).map((_, index) => (
            <HistoryCardSkeleton key={`skeleton-${index}`} />
          ))
        : fireAlerts.map((alert) => {
            const { date } = formatMongoTimestamp(alert.timestamp);
            const relativeTime = formatRelativeTime(alert.timestamp);
            return (
              // <-- Added return statement here
              <VStack
                key={alert._id}
                bg={{ _dark: "#6d6d6d", _light: "#cbc5cc" }}
                width={{ base: "300px", md: "220px" }}
                height="auto"
                padding="0.5rem"
                borderRadius="10px"
                boxShadow="xs"
                alignItems="start"
                color={{ _dark: "#cbc1db", _light: "black/60" }}
                gap="2px"
              >
                <HStack justifyContent="space-between" width="100%">
                  <HStack gap="0px" marginLeft={"-10px"}>
                    <Dot />
                    <Text textStyle="xs" fontWeight="semibold">
                      {alert.address.district}
                    </Text>
                  </HStack>
                  <Text
                    textStyle="2xs"
                    fontWeight="light"
                    color={{ _dark: "blue.200", _light: "blue.500" }}
                  >
                    {relativeTime}
                  </Text>
                </HStack>
                <VStack
                  width="100%"
                  alignItems="start"
                  paddingLeft="10px"
                  gap="0px"
                >
                  <Text textStyle="xs" fontWeight="medium">
                    {alert.address.apartment}
                  </Text>
                  <Text textStyle="2xs" fontWeight="medium">
                    {alert.address.street}
                  </Text>
                </VStack>
                <Box width="100%" paddingTop="5px" paddingBottom="5px">
                  <Text textStyle="2xs" fontWeight="light">
                    ⏰ {date}
                  </Text>
                </Box>
              </VStack>
            );
          })}
    </>
  );
};

export default HistoryCard;
