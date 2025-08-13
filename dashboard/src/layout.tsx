import { Box, Stack, Text } from "@chakra-ui/react";
import AlertCard from "./components/app/alertCard";
import HistoryCard from "./components/app/historyCard";

function layout() {
  return (
    <Box
      padding={{ base: "1rem 1rem 0 1rem", md: "1rem 5rem 0 5rem" }}
      width="100%"
      display={{ base: "block", md: "flex" }}
      marginTop={"1rem"}
      justifyContent="space-between"
    >
      <Box>
        <Text fontFamily="cursive" fontSize="xl" fontWeight="bold">
          Incoming alerts
        </Text>
        <Stack
          direction="row"
          flexWrap="wrap"
          gap="2rem"
          marginTop="10px"
          paddingLeft={{ base: "1.4rem", md: "0px" }}
        >
          <AlertCard />
          {/* <Modal /> */}
        </Stack>
      </Box>
      <Box marginTop={{ base: "2rem", md: "0px" }}>
        <Text fontFamily="cursive" fontSize="xl" fontWeight="bold">
          🕒 Alerts History
        </Text>
        <Stack marginTop="10px" paddingLeft={{ base: "1.4rem", md: "0px" }}>
          <HistoryCard />
        </Stack>
      </Box>
    </Box>
  );
}

export default layout;
