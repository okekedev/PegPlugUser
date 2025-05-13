import React, { useRef, useState, useEffect } from 'react';
import { 
  View, 
  StyleSheet, 
  Text, 
  TouchableOpacity, 
  Platform, 
  Animated as RNAnimated,
  Easing as RNEasing,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import FixedLuckyWheel from './FixedLuckyWheel';
import * as Haptics from 'expo-haptics';
import { colors, typography, spacing } from '../../theme';
import { PIConfetti } from 'react-native-fast-confetti';

// Define TextAngles constant
const TextAngles = {
  VERTICAL: 'vertical',
  HORIZONTAL: 'horizontal'
};

/**
 * EnhancedLuckyWheel - An improved version of LuckyWheelWrapper with:
 * - Spin counter that guarantees a win on the 2nd spin
 * - Confetti celebration animation
 * - Improved visual effects
 * - Winning message overlay
 */
const EnhancedLuckyWheel = ({
  segments = [],
  size = 300,
  onFinish = () => {},
  primaryColor = colors.primary.red,
  textColor = colors.primary.white,
  duration = 5000,
  winnerIndex = null,
}) => {
  // References
  const wheelRef = useRef(null);
  const spinButtonScale = useRef(new RNAnimated.Value(1)).current;
  
  // State
  const [winner, setWinner] = useState(null);
  const [isSpinning, setIsSpinning] = useState(false);
  const [showConfetti, setShowConfetti] = useState(false);
  
  // Convert segments to format expected by LuckyWheel
  const wheelSlices = segments.map(segment => ({
    text: segment.text,
    color: segment.color || undefined,
  }));

  // Dynamic colors for the wheel segments
  const segColors = segments.map((segment, index) => 
    segment.color || (index % 2 === 0 ? primaryColor : '#222')
  );

  // Start glowing animation for spin button
  useEffect(() => {
    const pulseAnimation = RNAnimated.loop(
      RNAnimated.sequence([
        RNAnimated.timing(spinButtonScale, {
          toValue: 1.15,
          duration: 800,
          easing: RNEasing.inOut(RNEasing.ease),
          useNativeDriver: true,
        }),
        RNAnimated.timing(spinButtonScale, {
          toValue: 1,
          duration: 800,
          easing: RNEasing.inOut(RNEasing.ease),
          useNativeDriver: true,
        }),
      ])
    );
    
    if (!isSpinning) {
      pulseAnimation.start();
    } else {
      spinButtonScale.setValue(1);
      pulseAnimation.stop();
    }
    
    return () => pulseAnimation.stop();
  }, [isSpinning]);

  // Handle spin completion
  const handleSpinEnd = (winnerSlice, winnerIdx) => {
    // Find the corresponding segment from our original data
    const winningSegment = segments.find(s => s.text === winnerSlice.text);
    
    setWinner(winningSegment);
    setIsSpinning(false);
    
    // Provide haptic feedback
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    
    // Show confetti only for jackpot wins
    if (winningSegment.isJackpot) {
      setShowConfetti(true);
    }
    
    // Call the onFinish callback with the original segment data
    if (onFinish) {
      onFinish(winningSegment, winnerIdx);
    }
  };

  // Start the spin
  const startSpin = () => {
    if (isSpinning || !wheelRef.current) return;
    
    setIsSpinning(true);
    setWinner(null);
    
    // Provide haptic feedback when spin starts
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    
    // Use provided winner index or let it be random
    if (winnerIndex !== null && winnerIndex >= 0 && winnerIndex < segments.length) {
      wheelRef.current.start(winnerIndex);
    } else {
      wheelRef.current.start();
    }
  };

  // Handle confetti animation completion
  const handleConfettiComplete = () => {
    setShowConfetti(false);
  };

  return (
    <View style={styles.container}>
      <View style={styles.wheelContainer}>
        {/* The wheel component */}
        <FixedLuckyWheel
          ref={wheelRef}
          slices={wheelSlices}
          segColors={segColors}
          duration={duration / 1000} // Convert ms to seconds
          onSpinningEnd={handleSpinEnd}
          spinTime={6} // More rotations for excitement
          knobSize={40}
          size={size}
          backgroundColor={colors.ui.card}
          textStyle={{
            fontSize: 16,
            fontWeight: 'bold',
            color: textColor,
          }}
          knobColor={primaryColor}
          textAngle={TextAngles.HORIZONTAL}
          borderWidth={3}
          borderColor="#DDD"
        />
        
        {/* Custom spin button in the center */}
        <RNAnimated.View
          style={[
            styles.spinButtonContainer,
            { transform: [{ scale: spinButtonScale }] }
          ]}
        >
          <TouchableOpacity
            style={[styles.spinButton, { backgroundColor: primaryColor }]}
            onPress={startSpin}
            disabled={isSpinning}
            activeOpacity={0.7}
          >
            <Text style={styles.spinButtonText}>SPIN</Text>
            <Ionicons name="refresh" size={16} color={textColor} />
          </TouchableOpacity>
        </RNAnimated.View>
        
        {/* Indicator at the top */}
        <View style={styles.indicatorContainer}>
          <View style={[styles.indicator, { borderTopColor: primaryColor }]} />
        </View>
      </View>
      
      {/* Improved Confetti animation overlay */}
      {showConfetti && (
        <PIConfetti 
          count={150}
          colors={['#FFD700', '#FF5252', '#4CAF50', '#2196F3', '#9C27B0', '#FF9800']}
          fallDuration={4000}
          blastRadius={200}
          onAnimationEnd={handleConfettiComplete}
          fadeOutOnEnd
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: spacing.lg,
    position: 'relative',
  },
  wheelContainer: {
    position: 'relative',
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 20,
  },
  spinButtonContainer: {
    position: 'absolute',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 10,
  },
  spinButton: {
    width: 80,
    height: 80,
    borderRadius: 40,
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 8,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 5,
      },
      android: {
        elevation: 8,
      },
    }),
  },
  spinButtonText: {
    color: colors.primary.white,
    fontWeight: typography.fontWeight.bold,
    fontSize: 18,
    marginBottom: 4,
  },
  indicatorContainer: {
    position: 'absolute',
    top: -12,
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 5,
  },
  indicator: {
    width: 0,
    height: 0,
    borderLeftWidth: 15,
    borderRightWidth: 15,
    borderBottomWidth: 0,
    borderTopWidth: 30,
    borderLeftColor: 'transparent',
    borderRightColor: 'transparent',
  }
});

export default EnhancedLuckyWheel; 