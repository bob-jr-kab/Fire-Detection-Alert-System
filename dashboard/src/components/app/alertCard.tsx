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
import { useEffect, useState, lazy, Suspense, useRef } from "react";
import AlertSkeleton from "../ui/AlertSkeleton.tsx";
import { AnimatePresence, motion } from "framer-motion";
import type { Variants, Transition } from "framer-motion";
import siren from "../../assets/siren.mp3";

// Create motion components with proper typing
const MotionBox = motion(Box);
const MotionText = motion(Text);
const MotionButton = motion(Button);

function AlertCard() {
  const smokeIcon = <Image src="/Smoke.png" height="25px" />;
  const [fireAlerts, setFireAlerts] = useState<FireAlert[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSirenMuted, setIsSirenMuted] = useState(false);
  const [browserNotificationsEnabled, setBrowserNotificationsEnabled] =
    useState(false);
  const db = getFirestore(app);
  const { open, onOpen, onClose } = useDisclosure();
  const [selectedLocation, setSelectedLocation] = useState<[number, number]>([
    0, 0,
  ]);
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const prevAlertIdsRef = useRef<Set<string>>(new Set());
  const firstRenderRef = useRef<boolean>(true);

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
    flameDetected?: boolean;
    device_name?: string;
    timestamp?: any;
  }

  // Request browser notification permission
  const requestNotificationPermission = async () => {
    if (!("Notification" in window)) {
      console.log("This browser does not support notifications");
      return false;
    }

    if (Notification.permission === "granted") {
      setBrowserNotificationsEnabled(true);
      return true;
    }

    if (Notification.permission !== "denied") {
      const permission = await Notification.requestPermission();
      if (permission === "granted") {
        setBrowserNotificationsEnabled(true);
        return true;
      }
    }

    setBrowserNotificationsEnabled(false);
    return false;
  };

  // Show browser notification (system-level notification)
  const showBrowserNotification = (alert: FireAlert) => {
    if (!browserNotificationsEnabled || !("Notification" in window)) return;

    const title = "🔥 Fire Alert - SafeSpark";

    let body = `Location: ${alert.address.apartment}, ${alert.address.street}\n`;
    body += `Temperature: ${alert.temperature}°C | Smoke: ${alert.smokeLevel} ppm`;

    if (alert.flameDetected) {
      body += `\n🔥 FLAME DETECTED`;
    }

    const notification = new Notification(title, {
      body: body,
      icon: "/notification-icon.png", // Add this to your public folder
      badge: "/notification-badge.png",
      tag: alert.id, // Prevent duplicate notifications
      requireInteraction: true, // Keep notification open until dismissed
      silent: false,
    });

    // Handle notification click
    notification.onclick = () => {
      window.focus();
      notification.close();
      // Optional: scroll to the specific alert in the dashboard
      const alertElement = document.getElementById(`alert-${alert.id}`);
      if (alertElement) {
        alertElement.scrollIntoView({ behavior: "smooth" });
      }
    };

    // Auto-close after 10 seconds (safety fallback)
    setTimeout(() => {
      notification.close();
    }, 10000);
  };

  // Initialize audio and notifications
  useEffect(() => {
    audioRef.current = new Audio(siren);
    audioRef.current.loop = true;

    // Request notification permission on component mount
    requestNotificationPermission();

    return () => {
      audioRef.current?.pause();
    };
  }, []);

  // Play siren for ANY alert
  const playSiren = () => {
    audioRef.current?.play().catch((err) => {
      console.log("Autoplay blocked:", err);
    });
  };

  // Stop siren
  const stopSiren = () => {
    audioRef.current?.pause();
    if (audioRef.current) audioRef.current.currentTime = 0;
  };

  const handleViewMap = (location: [number, number]) => {
    setSelectedLocation(location);
    onOpen();
  };

  // Dynamic import for the map component
  const MapWithNoSSR = lazy(() => import("../ui/MapModel.tsx"));

  useEffect(() => {
    const fireAlertRef = collection(db, "fireAlerts");
    setIsLoading(true);

    const unsubscribe = onSnapshot(fireAlertRef, (snapshot) => {
      const alerts: FireAlert[] = snapshot.docs.map((doc) => ({
        ...(doc.data() as Omit<FireAlert, "id">),
        id: doc.id,
      }));

      setIsLoading(false);
      setFireAlerts(alerts);
    });

    return () => {
      unsubscribe();
      stopSiren();
    };
  }, []);

  // Handle new alerts and trigger siren + notifications
  useEffect(() => {
    const currentAlertIds = new Set(fireAlerts.map((a) => a.id));

    // Skip processing on initial render
    if (firstRenderRef.current) {
      firstRenderRef.current = false;
      prevAlertIdsRef.current = currentAlertIds;
      return;
    }

    // Find newly added alert ids
    const newAlertIds = [...currentAlertIds].filter(
      (id) => !prevAlertIdsRef.current.has(id)
    );

    // Show notifications and trigger siren for new alerts
    fireAlerts.forEach((alert) => {
      if (newAlertIds.includes(alert.id)) {
        console.log("🔥 New alert received:", alert.id);

        // 🟢 Always unmute on new alert
        setIsSirenMuted(false);

        // Trigger siren immediately
        playSiren();

        // Trigger browser notification
        showBrowserNotification(alert);
      }
    });

    prevAlertIdsRef.current = currentAlertIds;
  }, [fireAlerts]);

  // Handle siren state based on alerts
  useEffect(() => {
    const hasAlerts = fireAlerts.length > 0;

    if (isSirenMuted) {
      stopSiren();
      return;
    }

    if (hasAlerts) {
      playSiren();
    } else {
      stopSiren();
    }
  }, [fireAlerts, isSirenMuted]);

  // Animation variants
  const cardVariants = {
    hidden: {
      opacity: 0,
      y: 20,
      scale: 0.95,
    },
    visible: {
      opacity: 1,
      y: 0,
      scale: 1,
      transition: {
        type: "spring" as const,
        stiffness: 300,
        damping: 25,
      },
    },
    exit: {
      opacity: 0,
      x: -100,
      transition: {
        duration: 0.3,
      },
    },
  };

  const alertPulseVariants: Variants = {
    pulse: {
      backgroundColor: [
        "rgba(254, 226, 226, 0.1)",
        "rgba(254, 226, 226, 0.3)",
        "rgba(254, 226, 226, 0.1)",
      ],
      borderColor: ["#fecaca", "#f87171", "#fecaca"],
      boxShadow: [
        "0 0 0 0 rgba(239, 68, 68, 0.4)",
        "0 0 0 10px rgba(239, 68, 68, 0)",
        "0 0 0 0 rgba(239, 68, 68, 0)",
      ],
      transition: {
        duration: 2,
        repeat: Infinity,
        ease: "easeInOut",
      } as Transition,
    },
  };

  const shakeVariants: Variants = {
    shake: {
      x: [0, -5, 5, -5, 5, 0],
      transition: {
        duration: 0.5,
        repeat: Infinity,
        ease: "easeInOut",
      } as Transition,
    },
  };

  const flameVariants: Variants = {
    flicker: {
      scale: [1, 1.1, 0.9, 1.1, 1],
      opacity: [1, 0.8, 0.9, 0.7, 1],
      transition: {
        duration: 0.8,
        repeat: Infinity,
        ease: "easeInOut",
      } as Transition,
    },
  };

  const colorPulseVariants: Variants = {
    pulse: {
      color: ["#cbc1db", "#f87171", "#cbc1db"],
      transition: {
        duration: 1,
        repeat: Infinity,
        ease: "easeInOut",
      } as Transition,
    },
  };

  return (
    <Box>
      {/* Siren and Notification Controls - Show when ANY alerts exist */}
      {fireAlerts.length > 0 && (
        <MotionBox
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg"
        >
          <VStack align="stretch" gap={3}>
            <HStack justify="space-between">
              <HStack>
                <motion.div
                  animate={{
                    rotate: [0, 360],
                    scale: [1, 1.2, 1],
                  }}
                  transition={{
                    duration: 1,
                    repeat: Infinity,
                    ease: "linear",
                  }}
                >
                  <Text fontSize="xl">🚨</Text>
                </motion.div>
                <Text fontWeight="bold" color="red.600">
                  ACTIVE FIRE ALERTS - {fireAlerts.length} ALERT
                  {fireAlerts.length !== 1 ? "S" : ""}
                </Text>
              </HStack>
              <Button
                size="sm"
                colorScheme={isSirenMuted ? "gray" : "red"}
                onClick={() => {
                  const newMuted = !isSirenMuted;
                  setIsSirenMuted(newMuted);
                  if (newMuted) {
                    stopSiren();
                  } else {
                    if (fireAlerts.length > 0) playSiren();
                  }
                }}
              >
                {isSirenMuted ? "🔇 Unmute Siren" : "🔊 Mute Siren"}
              </Button>
            </HStack>

            {/* Notification Controls */}
            <HStack justify="space-between" bg="white" p={2} borderRadius="md">
              <Text fontSize="sm" fontWeight="medium">
                Browser Notifications:
              </Text>
              <Button
                size="sm"
                colorScheme={browserNotificationsEnabled ? "green" : "gray"}
                onClick={requestNotificationPermission}
              >
                {browserNotificationsEnabled ? "🔔 Enabled" : "🔕 Enable"}
              </Button>
            </HStack>
          </VStack>
        </MotionBox>
      )}

      {/* Notification Permission Prompt */}
      {!browserNotificationsEnabled &&
        Notification.permission === "default" && (
          <MotionBox
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="mb-4 p-3 bg-blue-50 border border-blue-200 rounded-lg"
          >
            <HStack justify="space-between">
              <VStack align="start" gap={1}>
                <Text fontSize="sm" fontWeight="medium" color="blue.700">
                  Enable browser notifications
                </Text>
                <Text fontSize="xs" color="blue.600">
                  Get alerts even when browser is closed
                </Text>
              </VStack>
              <Button
                size="sm"
                colorScheme="blue"
                onClick={requestNotificationPermission}
              >
                Enable
              </Button>
            </HStack>
          </MotionBox>
        )}

      <AnimatePresence mode="popLayout">
        {isLoading
          ? Array.from({ length: 3 }).map((_, index) => (
              <AlertSkeleton key={`skeleton-${index}`} />
            ))
          : fireAlerts.map((alert, index) => {
              // All alerts are now considered "active" - no critical filtering
              const hasAlert = true;

              return (
                <MotionBox
                  key={alert.id}
                  id={`alert-${alert.id}`}
                  variants={cardVariants}
                  initial="hidden"
                  animate="visible"
                  exit="exit"
                  layout
                  custom={index}
                  transition={{
                    delay: index * 0.1,
                    type: "spring",
                    stiffness: 300,
                  }}
                  mb={4}
                >
                  <MotionBox
                    bg={{
                      _dark: "#4d4d4d",
                      _light: hasAlert ? "#fef2f2" : "#ffffff",
                    }}
                    color={{ _dark: "white/80", _light: "black/90" }}
                    width="300px"
                    height="210px"
                    padding="1rem"
                    paddingTop={hasAlert ? "1.5rem" : "0.5rem"}
                    borderRadius="10px"
                    border={
                      hasAlert
                        ? "2px solid #f87171"
                        : "1px solid rgb(255, 255, 255)"
                    }
                    boxShadow={
                      hasAlert ? "0 4px 20px rgba(239, 68, 68, 0.3)" : "lg"
                    }
                    position="relative"
                    overflow="hidden"
                    animate={hasAlert ? "pulse" : "visible"}
                    variants={hasAlert ? alertPulseVariants : {}}
                  >
                    {/* Alert Badge - Show for ALL alerts */}
                    {hasAlert && (
                      <MotionBox
                        position="absolute"
                        top="0"
                        left="0"
                        right="0"
                        bg="red.500"
                        color="white"
                        textAlign="center"
                        py={1}
                        fontSize="xs"
                        fontWeight="bold"
                        variants={shakeVariants}
                        animate="shake"
                      >
                        🚨 FIRE ALERT
                      </MotionBox>
                    )}

                    <Box textAlign="right">
                      <Text fontSize="md" fontWeight="medium">
                        {alert.address.district}
                      </Text>
                    </Box>

                    <HStack justifyContent="space-between" marginTop="-10px">
                      <HStack marginTop="-10px">
                        <Avatar.Root
                          bg={{ _light: "#ececec", _dark: "#3c3c3c" }}
                          size="md"
                        >
                          <Avatar.Image
                            src="/notifications.png"
                            height="25px"
                            width="25px"
                          />
                        </Avatar.Root>

                        <MotionText
                          fontSize="lg"
                          color={{ _light: "#cbc1db", _dark: "#cbc1db/20" }}
                          variants={hasAlert ? colorPulseVariants : {}}
                          animate={hasAlert ? "pulse" : "visible"}
                        >
                          Fire Alert
                        </MotionText>
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
                      alignItems="center"
                      marginTop="15px"
                      paddingLeft="30px"
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
                        <motion.div
                          variants={flameVariants}
                          animate={
                            alert.temperature > 30 ? "flicker" : "visible"
                          }
                        >
                          <ThermometerSun
                            size={20}
                            color={
                              alert.temperature > 30 ? "#ef4444" : "#161618"
                            }
                          />
                        </motion.div>
                        <Text textStyle="xs" fontWeight="semibold">
                          Temp:
                          <Box
                            as="span"
                            px="1"
                            color={alert.temperature > 30 ? "red.600" : "red"}
                          >
                            {alert.temperature}°C
                          </Box>
                        </Text>
                      </HStack>
                      <HStack>
                        <motion.div
                          variants={flameVariants}
                          animate={
                            parseInt(alert.smokeLevel) > 100
                              ? "flicker"
                              : "visible"
                          }
                        >
                          {smokeIcon}
                        </motion.div>
                        <Text textStyle="xs" fontWeight="semibold">
                          Smoke:{" "}
                          <Box
                            as="span"
                            px="1"
                            color={
                              parseInt(alert.smokeLevel) > 100
                                ? "red.600"
                                : "red"
                            }
                            borderRadius="md"
                            fontWeight="bold"
                          >
                            {alert.smokeLevel}
                          </Box>
                        </Text>
                      </HStack>
                    </HStack>

                    {/* Flame Detected Indicator */}
                    {alert.flameDetected && (
                      <MotionBox
                        initial={{ opacity: 0, scale: 0 }}
                        animate={{ opacity: 1, scale: 1 }}
                        className="mt-2 flex items-center justify-center"
                        variants={flameVariants}
                      >
                        <Text fontSize="xs" fontWeight="bold" color="red.600">
                          🔥 FLAME DETECTED
                        </Text>
                      </MotionBox>
                    )}

                    <Box textAlign="right" paddingTop="10px">
                      <MotionButton
                        height={25}
                        bg={{
                          _dark: "#3c3c3c",
                          _light: hasAlert ? "red.500" : "black/50",
                        }}
                        color={{ _dark: "white/80", _light: "white" }}
                        width={74}
                        borderRadius="15px"
                        shadow={"xs"}
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                      >
                        Respond
                      </MotionButton>
                    </Box>
                  </MotionBox>
                </MotionBox>
              );
            })}
      </AnimatePresence>

      {/* Modal */}
      <Modal
        isOpen={open}
        onClose={onClose}
        isCentered
        size={{
          base: "full",
          md: "xl",
          lg: "2xl",
        }}
      >
        <ModalOverlay bg="blackAlpha.600" backdropFilter="blur(4px)" />
        <ModalContent
          maxW="800px"
          maxH="90vh"
          borderRadius="xl"
          overflow="hidden"
        >
          <ModalCloseButton
            zIndex={1}
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
                height={{ base: "100vh", md: "70vh" }}
                minH="400px"
              >
                <MapWithNoSSR center={selectedLocation} />
              </Box>
            </Suspense>
          </ModalBody>
        </ModalContent>
      </Modal>
    </Box>
  );
}

export default AlertCard;
