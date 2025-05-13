import React, { useState, useRef, useEffect } from 'react';
import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  Animated,
  Easing,
  Image,
  Dimensions,
  Platform,
  ScrollView
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { colors, typography, spacing } from '../../theme';
import * as Haptics from 'expo-haptics';
import LuckyWheelWrapper from '../../components/Wheel/LuckyWheelWrapper';
import { Confetti } from 'react-native-fast-confetti';

// Get screen dimensions for responsive design
const { width, height } = Dimensions.get('window');

// Enhanced prize data with more exciting rewards and better icons
const PRIZES = [
  { 
    id: '1', 
    text: '15% Off', 
    name: '15% Off Any Purchase', 
    color: colors.secondary.blue, 
    icon: 'pricetag',
    description: 'Valid at any participating merchant'
  },
  { 
    id: '2', 
    text: 'Free Coffee', 
    name: 'Free Coffee', 
    color: colors.primary.red, 
    icon: 'cafe',
    description: 'Redeem at Downtown Coffee'
  },
  { 
    id: '3', 
    text: 'Try Again', 
    name: 'Better Luck Next Time', 
    color: colors.text.tertiary, 
    icon: 'refresh',
    description: 'Keep spinning for a chance to win!'
  },
  { 
    id: '4', 
    text: '25% Off Meal', 
    name: '25% Off Meal', 
    color: colors.status.success, 
    icon: 'restaurant',
    description: 'Valid at Gourmet Bistro'
  },
  { 
    id: '5', 
    text: 'Free Dessert', 
    name: 'Free Dessert', 
    color: colors.status.info, 
    icon: 'ice-cream',
    description: 'Valid at City Bakery'
  },
  { 
    id: '6', 
    text: '$50 JACKPOT', 
    name: 'JACKPOT! $50 Credit', 
    color: '#FFD700', // Gold color for jackpot
    icon: 'trophy',
    description: 'Big winner! $50 credit to any merchant'
  },
];

const SlotMachineScreen = ({ navigation }) => {
  const [spinsRemaining, setSpinsRemaining] = useState(2);
  const [currentPrize, setCurrentPrize] = useState(null);
  const [showConfetti, setShowConfetti] = useState(false);
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const scaleAnim = useRef(new Animated.Value(0.95)).current;
  
  // Reset UI when screen appears
  useEffect(() => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 600,
        useNativeDriver: true,
      }),
      Animated.timing(scaleAnim, {
        toValue: 1,
        duration: 600,
        easing: Easing.out(Easing.back(1.5)),
        useNativeDriver: true,
      })
    ]).start();
    
    return () => {
      fadeAnim.setValue(0);
      scaleAnim.setValue(0.95);
    };
  }, []);
  
  // Handle spin completion
  const handleSpinComplete = (prize, index) => {
    setCurrentPrize(prize);
    setSpinsRemaining(prev => Math.max(0, prev - 1));
    
    // Show confetti effect for big prizes (jackpot or meals)
    if (prize.id === '6' || prize.id === '4' || prize.id === '5') {
      setShowConfetti(true);
      // Strong haptic feedback for winning
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      
      // Hide confetti after 3 seconds
      setTimeout(() => {
        setShowConfetti(false);
      }, 3000);
    } else if (prize.id !== '3') {
      // Medium success for other prizes
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    } else {
      // For "Try Again" result
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
      
      // Slightly shake the screen for "Try Again" with subtle animation
      const shakeAnimation = Animated.sequence([
        Animated.timing(scaleAnim, { 
          toValue: 0.98, 
          duration: 100, 
          useNativeDriver: true,
          easing: Easing.inOut(Easing.ease) 
        }),
        Animated.timing(scaleAnim, { 
          toValue: 1, 
          duration: 100, 
          useNativeDriver: true,
          easing: Easing.inOut(Easing.ease) 
        })
      ]);
      
      // Play the shake animation twice
      Animated.sequence([shakeAnimation, shakeAnimation]).start();
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      {/* Background styling */}
      <View style={styles.backgroundContainer}>
        <View style={styles.backgroundCircle} />
      </View>
      
      <View style={styles.header}>
        <Image 
          source={require('../../../assets/peglogored.png')} 
          style={styles.logo}
          resizeMode="contain"
        />
      </View>
      
      <ScrollView 
        style={styles.scrollView}
        contentContainerStyle={styles.scrollViewContent}
        showsVerticalScrollIndicator={true}
      >
        <Animated.View 
          style={[
            styles.content, 
            { 
              opacity: fadeAnim,
              transform: [{ scale: scaleAnim }]
            }
          ]}
        >
          {/* Spins remaining indicator - restored per user request */}
          <View style={styles.spinsContainer}>
            <Text style={styles.spinsText}>
              Spins Remaining: <Text style={styles.spinsCount}>{spinsRemaining}</Text>
            </Text>
          </View>
          
          {/* Only show wheel if spins remain */}
          {spinsRemaining > 0 ? (
            <LuckyWheelWrapper
              segments={PRIZES}
              onFinish={handleSpinComplete}
              primaryColor={colors.primary.red}
              textColor={colors.primary.white}
              duration={5000}
              size={width * 0.85}
            />
          ) : (
            <View style={styles.noSpinsContainer}>
              <Ionicons name="hourglass-outline" size={50} color={colors.text.tertiary} />
              <Text style={styles.noSpinsText}>No Spins Remaining</Text>
              <Text style={styles.noSpinsSubtext}>Come back tomorrow for more chances to win!</Text>
            </View>
          )}
          
          {/* Current prize description */}
          {currentPrize && currentPrize.id !== '3' && (
            <Animated.View style={styles.prizeDetailsContainer}>
              <View style={styles.prizeHeader}>
                <Ionicons 
                  name={currentPrize.icon || 'trophy'} 
                  size={24} 
                  color={currentPrize.color || colors.secondary.blue} 
                />
                <Text style={styles.prizeTitle}>{currentPrize.name}</Text>
              </View>
              
              <Text style={styles.prizeDescription}>
                {currentPrize.description}
              </Text>
              
              <TouchableOpacity 
                style={styles.redeemButton}
                activeOpacity={0.7}
              >
                <Text style={styles.redeemButtonText}>Redeem Prize</Text>
                <Ionicons name="chevron-forward" size={16} color={colors.primary.white} />
              </TouchableOpacity>
            </Animated.View>
          )}
        </Animated.View>
      </ScrollView>
      
      {/* Confetti effect for big wins */}
      {showConfetti && (
        <View style={styles.confettiContainer} pointerEvents="none">
          <Confetti 
            count={200}
            colors={['#FFD700', '#FF5252', '#4CAF50', '#2196F3', '#9C27B0', '#FF9800']}
            fallDuration={4000}
            fadeOutOnEnd
            cannonsPositions={[
              { x: width / 2, y: height / 4 },
              { x: width / 4, y: height / 3 },
              { x: width * 3/4, y: height / 3 }
            ]}
          />
        </View>
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.ui.background,
    position: 'relative',
    overflow: 'hidden',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.ui.border,
    zIndex: 2,
  },
  logo: {
    width: 40,
    height: 40,
  },
  scrollView: {
    flex: 1,
    width: '100%',
  },
  scrollViewContent: {
    flexGrow: 1,
    paddingBottom: spacing.xxl,
  },
  content: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: spacing.md,
    zIndex: 2,
    width: '100%',
  },
  spinsContainer: {
    marginBottom: spacing.lg,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.md,
    backgroundColor: colors.ui.card,
    borderRadius: spacing.borderRadius.md,
    ...spacing.shadow.small,
    borderWidth: 1,
    borderColor: colors.primary.red,
  },
  spinsText: {
    fontSize: typography.fontSize.md,
    color: colors.text.secondary,
    letterSpacing: 0.5,
    textAlign: 'center',
  },
  spinsCount: {
    fontWeight: typography.fontWeight.bold,
    color: colors.primary.red,
  },
  noSpinsContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: spacing.xl,
    backgroundColor: colors.ui.card,
    borderRadius: spacing.borderRadius.lg,
    marginVertical: spacing.xl,
    width: '90%',
    maxWidth: 350,
    ...spacing.shadow.small,
  },
  noSpinsText: {
    fontSize: typography.fontSize.lg,
    fontWeight: typography.fontWeight.bold,
    color: colors.text.primary,
    marginTop: spacing.md,
    marginBottom: spacing.sm,
    textAlign: 'center',
  },
  noSpinsSubtext: {
    fontSize: typography.fontSize.sm,
    color: colors.text.tertiary,
    textAlign: 'center',
  },
  prizeDetailsContainer: {
    width: '100%',
    marginTop: spacing.lg,
    padding: spacing.md,
    backgroundColor: colors.ui.card,
    borderRadius: spacing.borderRadius.lg,
    alignSelf: 'center',
    maxWidth: 500,
    ...spacing.shadow.small,
  },
  prizeHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  prizeTitle: {
    fontSize: typography.fontSize.lg,
    fontWeight: typography.fontWeight.bold,
    color: colors.text.primary,
    marginLeft: spacing.sm,
  },
  prizeDescription: {
    fontSize: typography.fontSize.md,
    color: colors.text.secondary,
    marginBottom: spacing.md,
  },
  redeemButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.secondary.blue,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.md,
    borderRadius: spacing.borderRadius.md,
    ...spacing.shadow.small,
  },
  redeemButtonText: {
    color: colors.primary.white,
    fontWeight: typography.fontWeight.medium,
    marginRight: spacing.xs,
  },
  confettiContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 3,
  },
  backgroundContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 1,
    backgroundColor: colors.ui.background,
  },
  backgroundCircle: {
    position: 'absolute',
    width: width * 2,
    height: width * 2,
    borderRadius: width,
    backgroundColor: 'rgba(240, 240, 250, 0.05)',
    top: -width / 2,
    left: -width / 2,
    zIndex: 1,
  }
});

export default SlotMachineScreen; 