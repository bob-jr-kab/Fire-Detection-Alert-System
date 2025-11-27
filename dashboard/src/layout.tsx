import { Box, Stack, Text, Button, VStack } from "@chakra-ui/react";
import AlertCard from "./components/app/alertCard";
import HistoryCard from "./components/app/historyCard";
import { useState } from "react";

function Layout() {
  const [visibleCount, setVisibleCount] = useState(10); // show 10 at first

  return (
    <Box
      padding={{ base: "1rem 1rem 0 1rem", md: "1rem 5rem 0 5rem" }}
      width="100%"
      display={{ base: "block", md: "flex" }}
      marginTop="1rem"
      justifyContent="space-between"
      gap="2rem"
    >
      {/* LEFT — Incoming Alerts */}
      <Box flex="1">
        <Text fontFamily="cursive" fontSize="xl" fontWeight="bold">
          Incoming alerts
        </Text>

        <Stack
          flexWrap="wrap"
          gap="1rem"
          marginTop="10px"
          paddingLeft={{ base: "1.4rem", md: "0px" }}
        >
          <AlertCard />
        </Stack>
      </Box>

      {/* RIGHT — Scrollable History */}
      <Box flex="0.2">
        <Text fontFamily="cursive" fontSize="xl" fontWeight="bold">
          🕒 Alerts History
        </Text>

        {/* Scroll Container */}
        <Box marginTop="10px" maxH="550px" overflowY="auto" paddingRight="5px">
          <VStack
            gap="1rem"
            alignItems="start"
            paddingLeft={{ base: "1.5rem", md: "0px" }}
          >
            <HistoryCard visibleCount={visibleCount} />
          </VStack>
        </Box>

        {/* Load More Button */}
        <Button
          width="100%"
          marginTop="10px"
          variant="outline"
          borderRadius="10px"
          onClick={() => setVisibleCount((prev) => prev + 10)}
        >
          Load more...
        </Button>
      </Box>
    </Box>
  );
}

export default Layout;
