import React, { useRef, useState, useEffect } from 'react';
import { View, StyleSheet, Text, TouchableOpacity, Platform } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
// Import our fixed component instead of the original
import FixedLuckyWheel from './FixedLuckyWheel';
import * as Haptics from 'expo-haptics';
import { colors, typography, spacing } from '../../theme';

// Define TextAngles constant to fix the missing reference error
const TextAngles = {
  VERTICAL: 'vertical',
  HORIZONTAL: 'horizontal'
};

/**
 * LuckyWheelWrapper - A wrapper component for react-native-lucky-wheel
 * that provides a consistent interface with the previous SpinningWheel component.
 */
const LuckyWheelWrapper = ({
  segments = [],
  size = 300,
  onFinish = () => {},
  primaryColor = colors.primary.red,
  textColor = colors.primary.white,
  duration = 5000,
  winnerIndex = null,
}) => {
  // Reference to the LuckyWheel component
  const wheelRef = useRef(null);
  const [winner, setWinner] = useState(null);
  const [isSpinning, setIsSpinning] = useState(false);

  // Convert our segments to the format expected by LuckyWheel
  const wheelSlices = segments.map(segment => ({
    text: segment.text,
    // Use slice's color or alternate between primaryColor and a darker shade
    color: segment.color || undefined,
  }));

  // Background colors for the slices (if not provided in segments)
  const segColors = segments.map((segment, index) => 
    segment.color || (index % 2 === 0 ? primaryColor : '#222')
  );

  // Handle spin completion
  const handleSpinEnd = (winnerSlice) => {
    // Find the corresponding segment from our original data
    const winningSegment = segments.find(s => s.text === winnerSlice.text);
    const winningIndex = segments.findIndex(s => s.text === winnerSlice.text);
    
    setWinner(winningSegment);
    setIsSpinning(false);
    
    // Provide haptic feedback
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    
    // Call the onFinish callback with the original segment data
    if (onFinish) {
      onFinish(winningSegment, winningIndex);
    }
  };

  // Start the spin
  const startSpin = () => {
    if (isSpinning || !wheelRef.current) return;
    
    setIsSpinning(true);
    // Provide haptic feedback when spin starts
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);

    // Determine winner if specified, otherwise random
    if (winnerIndex !== null && winnerIndex >= 0 && winnerIndex < segments.length) {
      // Use the specified winner
      wheelRef.current.start(winnerIndex);
    } else {
      // Let the wheel pick a random winner
      wheelRef.current.start();
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.wheelContainer}>
        {/* Use our fixed wheel component */}
        <FixedLuckyWheel
          ref={wheelRef}
          slices={wheelSlices}
          segColors={segColors}
          duration={duration / 1000} // Convert ms to seconds
          onSpinningEnd={handleSpinEnd}
          spinTime={5} // Number of rotations
          knobSize={36}
          size={size}
          backgroundColor={colors.ui.card}
          textStyle={{
            fontSize: 14,
            fontWeight: 'bold',
            color: textColor,
          }}
          knobColor={primaryColor}
          textAngle={TextAngles.HORIZONTAL} // Use our constant
          borderWidth={2}
          borderColor="#DDD"
        />
        
        {/* Custom spin button in the center */}
        <TouchableOpacity
          style={[styles.spinButton, { backgroundColor: primaryColor }]}
          onPress={startSpin}
          disabled={isSpinning}
          activeOpacity={0.8}
        >
          <Text style={styles.spinButtonText}>SPIN</Text>
          <Ionicons name="refresh" size={16} color={textColor} />
        </TouchableOpacity>
        
        {/* Optional indicator at the top */}
        <View style={styles.indicatorContainer}>
          <View style={[styles.indicator, { borderTopColor: primaryColor }]} />
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: spacing.md,
  },
  wheelContainer: {
    position: 'relative',
    alignItems: 'center',
    justifyContent: 'center',
  },
  spinButton: {
    position: 'absolute',
    alignItems: 'center',
    justifyContent: 'center',
    width: 70,
    height: 70,
    borderRadius: 35,
    backgroundColor: colors.primary.red,
    elevation: 5,
    zIndex: 10,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
      },
      android: {
        elevation: 5,
      },
    }),
  },
  spinButtonText: {
    color: colors.primary.white,
    fontWeight: typography.fontWeight.bold,
    marginBottom: 2,
  },
  indicatorContainer: {
    position: 'absolute',
    top: -5,
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 10,
  },
  indicator: {
    width: 0,
    height: 0,
    borderLeftWidth: 10,
    borderRightWidth: 10,
    borderBottomWidth: 0,
    borderTopWidth: 20,
    borderLeftColor: 'transparent',
    borderRightColor: 'transparent',
    borderTopColor: colors.primary.red,
  },
});

export default LuckyWheelWrapper; 