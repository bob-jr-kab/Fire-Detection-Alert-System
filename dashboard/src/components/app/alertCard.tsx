import {
  Avatar,
  Box,
  HStack,
  Link,
  Text,
  Separator,
  VStack,
  Image,
  Button,
} from "@chakra-ui/react";
import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalCloseButton,
  ModalBody,
} from "@chakra-ui/modal";
import { useDisclosure } from "@chakra-ui/react";
import {
  MapPinHouse,
  SquareArrowOutUpRight,
  ThermometerSun,
} from "lucide-react";
import { getFirestore, collection, onSnapshot } from "firebase/firestore";
import app from "../../config/firebase.ts";
import { useEffect, useState, lazy, Suspense } from "react";
import AlertSkeleton from "../ui/AlertSkeleton.tsx";
import { AnimatePresence } from "framer-motion";

function alertCard() {
  const smokeIcon = <Image src="/Smoke.png" height="25px" />;
  const [fireAlerts, setFireAlerts] = useState<FireAlert[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const db = getFirestore(app);
  const { open, onOpen, onClose } = useDisclosure();
  const [selectedLocation, setSelectedLocation] = useState<[number, number]>([
    0, 0,
  ]);
  const handleViewMap = (location: [number, number]) => {
    setSelectedLocation(location);
    onOpen();
  };

  // Dynamic import for the map component
  const MapWithNoSSR = lazy(() => import("../ui/MapModel.tsx"));
  // Define Fire Alert Type
  interface FireAlert {
    id: string;
    location: [number, number];
    address: {
      apartment: string;
      district: string;
      street: string;
    };
    temperature: number;
    smokeLevel: string;
  }

  useEffect(() => {
    const fireAlertRef = collection(db, "fireAlerts");
    setIsLoading(true);
    // Listen for real-time updates
    const unsubscribe = onSnapshot(fireAlertRef, (snapshot) => {
      const alerts: FireAlert[] = snapshot.docs.map((doc) => ({
        ...(doc.data() as Omit<FireAlert, "id">),
        id: doc.id, // Add id separately
      }));
      setIsLoading(false);
      setFireAlerts(alerts);
    });
    return () => unsubscribe(); // Cleanup listener when component unmounts
  }, []);

  return (
    <AnimatePresence mode="wait">
      {isLoading
        ? // Show skeleton loaders while loading
          Array.from({ length: 3 }).map((_, index) => (
            <AlertSkeleton key={`skeleton-${index}`} />
          ))
        : fireAlerts.map((alert) => (
            <Box
              key={alert.id}
              bg={{ _dark: "#4d4d4d", _light: "#fffff" }}
              color={{ _dark: "white/80", _light: "black/90" }}
              width="300px"
              height="210px"
              padding={"1rem"}
              paddingTop={"0.5rem"}
              borderRadius="10px"
              border={"1px solidrgb(255, 255, 255)"}
              boxShadow="lg"
            >
              <Box textAlign="right ">
                <Text fontSize="md" fontWeight="medium">
                  {alert.address.district}
                </Text>
              </Box>
              <HStack justifyContent="space-between" marginTop="-10px">
                <HStack marginTop="-10px">
                  <Avatar.Root
                    bg={{ _light: "#ececec`", _dark: "#3c3c3c" }}
                    size="md"
                  >
                    <Avatar.Image
                      src="/notifications.png"
                      height="25px"
                      width="25px"
                    />
                  </Avatar.Root>

                  <Text
                    fontSize="lg"
                    color={{ _light: "#cbc1db", _dark: "#cbc1db/20" }}
                  >
                    Fire Alert
                  </Text>
                </HStack>

                <HStack>
                  <Link onClick={() => handleViewMap(alert.location)}>
                    <Text
                      fontSize="10px"
                      color={{ _light: "#636ae8", _dark: "#141424" }}
                    >
                      View on map
                    </Text>
                    <SquareArrowOutUpRight size={11} color="#adc8cf" />
                  </Link>
                </HStack>
              </HStack>
              <Separator marginTop="5px" />

              {/* Card contents */}

              <HStack
                alignItems={"center"}
                marginTop="15px"
                paddingLeft={"30px"}
              >
                <MapPinHouse
                  size={35}
                  opacity="45%"
                  color="#161618"
                  strokeWidth={2}
                />
                <VStack alignItems="start" marginLeft="10px" gap="0px">
                  <Text textStyle="sm" fontWeight="semibold">
                    {alert.address.apartment}
                  </Text>
                  <Text textStyle="sm" fontWeight="medium">
                    {alert.address.street}
                  </Text>
                </VStack>
              </HStack>

              <HStack marginTop="10px">
                <HStack>
                  <ThermometerSun size={20} />
                  <Text textStyle="xs" fontWeight="semibold">
                    Temp:
                    <Box as="span" px="1" color="red">
                      {alert.temperature}°C
                    </Box>
                  </Text>
                </HStack>
                <HStack>
                  {smokeIcon}
                  <Text textStyle="xs" fontWeight="semibold">
                    Smoke:{" "}
                    <Box
                      as="span"
                      px="1"
                      color="red"
                      borderRadius="md"
                      fontWeight="bold"
                    >
                      {alert.smokeLevel}
                    </Box>
                  </Text>
                </HStack>
              </HStack>

              <Box textAlign="right" paddingTop="10px">
                <Button
                  height={25}
                  bg={{ _dark: "#3c3c3c", _light: "black/50" }}
                  color={{ _dark: "white/80", _light: "white" }}
                  width={74}
                  borderRadius="15px"
                  shadow={"xs"}
                >
                  Respond
                </Button>
              </Box>
            </Box>
          ))}
      {/*  implemented modal */}
      <Modal
        isOpen={open}
        onClose={onClose}
        isCentered
        size={{
          base: "full", // Full screen on mobile
          md: "xl", // Fixed width on larger screens
          lg: "2xl", // Slightly larger on big screens
        }}
      >
        <ModalOverlay bg="blackAlpha.600" backdropFilter="blur(4px)" />
        <ModalContent
          maxW="800px" // Maximum width
          maxH="90vh" // Maximum height (90% of viewport)
          borderRadius="xl"
          overflow="hidden"
        >
          <ModalCloseButton
            zIndex={1} // Ensure it's above the map
            bg="black"
            borderRadius="full"
            _hover={{ bg: "gray.100" }}
            color={"red"}
          />
          <ModalBody p={0}>
            <Suspense
              fallback={
                <Box
                  height="400px"
                  display="flex"
                  alignItems="center"
                  justifyContent="center"
                >
                  Loading map...
                </Box>
              }
            >
              <Box
                width="100%"
                height={{ base: "100vh", md: "70vh" }} // Full height on mobile, fixed on desktop
                minH="400px" // Minimum height
              >
                <MapWithNoSSR center={selectedLocation} />
              </Box>
            </Suspense>
          </ModalBody>
        </ModalContent>
      </Modal>
    </AnimatePresence>
  );
}
export default alertCard;
