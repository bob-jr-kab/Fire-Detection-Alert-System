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
  const db = getFirestore(app);
  const { open, onOpen, onClose } = useDisclosure();
  const [selectedLocation, setSelectedLocation] = useState<[number, number]>([
    0, 0,
  ]);
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const prevCriticalIdsRef = useRef<Set<string>>(new Set());
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

  // Initialize audio
  useEffect(() => {
    audioRef.current = new Audio(siren);
    audioRef.current.loop = true;

    return () => {
      audioRef.current?.pause();
    };
  }, []);

  // Play siren for critical alerts
  const playSiren = () => {
    audioRef.current?.play().catch((err) => {
      console.log("Autoplay blocked:", err);
    });
  };

  // Stop siren
  const stopSiren = () => {
    audioRef.current?.pause();
    // optional: rewind to start so next play begins from start
    if (audioRef.current) audioRef.current.currentTime = 0;
  };

  const handleViewMap = (location: [number, number]) => {
    setSelectedLocation(location);
    onOpen();
  };

  // Check if alert is critical
  const isCriticalAlert = (alert: FireAlert): boolean => {
    const smokeLevel = parseInt(alert.smokeLevel) || 0;
    return alert.flameDetected || smokeLevel > 800 || alert.temperature > 45;
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

  useEffect(() => {
    const currentCriticalIds = new Set(
      fireAlerts.filter(isCriticalAlert).map((a) => a.id)
    );

    // skip processing on initial render to avoid auto-unmuting on initial load
    if (firstRenderRef.current) {
      firstRenderRef.current = false;
      prevCriticalIdsRef.current = currentCriticalIds;
      return;
    }

    // find newly added critical alert ids
    const newCriticalIds = [...currentCriticalIds].filter(
      (id) => !prevCriticalIdsRef.current.has(id)
    );

    if (newCriticalIds.length > 0) {
      // if currently muted, unmute and play
      if (isSirenMuted) {
        setIsSirenMuted(false);
        playSiren();
      } else {
        // if already unmuted ensure siren plays
        if (currentCriticalIds.size > 0) playSiren();
      }
    }

    prevCriticalIdsRef.current = currentCriticalIds;
  }, [fireAlerts, isSirenMuted]);
  useEffect(() => {
    const hasCriticalAlerts = fireAlerts.some(isCriticalAlert);

    if (isSirenMuted) {
      stopSiren();
      return;
    }

    if (hasCriticalAlerts) {
      playSiren();
    } else {
      stopSiren();
    }
  }, [fireAlerts, isSirenMuted]);
  // Fixed animation variants with proper typing
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

  const criticalPulseVariants: Variants = {
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
      {/* Siren Controls */}
      {fireAlerts.some(isCriticalAlert) && (
        <MotionBox
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg"
        >
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
                CRITICAL ALERT ACTIVE
              </Text>
            </HStack>
            <Button
              size="sm"
              colorScheme={isSirenMuted ? "gray" : "red"}
              onClick={() => {
                // toggle mute state and ensure audio updates immediately
                const newMuted = !isSirenMuted;
                setIsSirenMuted(newMuted);
                if (newMuted) {
                  stopSiren();
                } else {
                  // only play if there are critical alerts
                  if (fireAlerts.some(isCriticalAlert)) playSiren();
                }
              }}
            >
              {isSirenMuted ? "🔇 Unmute" : "🔊 Mute Siren"}
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
              const critical = isCriticalAlert(alert);

              return (
                <MotionBox
                  key={alert.id}
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
                      _light: critical ? "#fef2f2" : "#ffffff",
                    }}
                    color={{ _dark: "white/80", _light: "black/90" }}
                    width="300px"
                    height="210px"
                    padding="1rem"
                    paddingTop={critical ? "1.5rem" : "0.5rem"}
                    borderRadius="10px"
                    border={
                      critical
                        ? "2px solid #f87171"
                        : "1px solid rgb(255, 255, 255)"
                    }
                    boxShadow={
                      critical ? "0 4px 20px rgba(239, 68, 68, 0.3)" : "lg"
                    }
                    position="relative"
                    overflow="hidden"
                    // Use animate prop with proper typing
                    animate={critical ? "pulse" : "visible"}
                    variants={critical ? criticalPulseVariants : {}}
                  >
                    {/* Critical Alert Badge */}
                    {critical && (
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
                        🚨 CRITICAL ALERT
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
                          variants={critical ? colorPulseVariants : {}}
                          animate={critical ? "pulse" : "visible"}
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
                            alert.temperature > 45 ? "flicker" : "visible"
                          }
                        >
                          <ThermometerSun
                            size={20}
                            color={
                              alert.temperature > 45 ? "#ef4444" : "#161618"
                            }
                          />
                        </motion.div>
                        <Text textStyle="xs" fontWeight="semibold">
                          Temp:
                          <Box
                            as="span"
                            px="1"
                            color={alert.temperature > 45 ? "red.600" : "red"}
                          >
                            {alert.temperature}°C
                          </Box>
                        </Text>
                      </HStack>
                      <HStack>
                        <motion.div
                          variants={flameVariants}
                          animate={
                            parseInt(alert.smokeLevel) > 800
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
                              parseInt(alert.smokeLevel) > 800
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
                          _light: critical ? "red.500" : "black/50",
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
