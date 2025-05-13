import React, { useRef, useState, useEffect } from 'react';
import { 
  View, 
  StyleSheet, 
  Animated, 
  Easing,
  TouchableOpacity, 
  Text,
  Dimensions,
  Platform,
  Image,
  LayoutAnimation,
  UIManager,
  PanResponder
} from 'react-native';
import Svg, { 
  G, 
  Path, 
  Text as SvgText, 
  Circle, 
  Defs, 
  LinearGradient, 
  Stop, 
  RadialGradient,
  ClipPath,
  Rect
} from 'react-native-svg';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { colors, typography, spacing } from '../../theme';

// Enable LayoutAnimation for Android
if (Platform.OS === 'android' && UIManager.setLayoutAnimationEnabledExperimental) {
  UIManager.setLayoutAnimationEnabledExperimental(true);
}

// Get screen dimensions
const { width, height } = Dimensions.get('window');

const SpinningWheel = ({
  segments = [],
  size = Math.min(width * 0.8, height * 0.5, 400), // Responsive size based on screen dimensions
  onFinish = () => {},
  primaryColor = colors.primary.red,
  textColor = colors.primary.white,
  duration = 5000,
  winnerIndex = null,
  spinToCenter = true
}) => {
  // Animation values
  const spinValue = useRef(new Animated.Value(0)).current;
  const buttonScale = useRef(new Animated.Value(1)).current;
  const glowOpacity = useRef(new Animated.Value(0)).current;
  const wheelScale = useRef(new Animated.Value(1)).current;
  
  // State
  const [isSpinning, setIsSpinning] = useState(false);
  const [winner, setWinner] = useState(null);
  const [hasSpun, setHasSpun] = useState(false);
  const [dragEnabled, setDragEnabled] = useState(true);
  const [manualSpinAngle, setManualSpinAngle] = useState(0);
  
  // Constants
  const wheelRadius = size / 2;
  const centerX = wheelRadius;
  const centerY = wheelRadius;
  const segmentAngle = 360 / segments.length;
  const angleOffset = 90; // Offset so the segment points to the top marker
  
  // Pan responder for manual spinning
  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => dragEnabled && !isSpinning,
      onMoveShouldSetPanResponder: () => dragEnabled && !isSpinning,
      onPanResponderGrant: () => {
        // Provide feedback when touch starts
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      },
      onPanResponderMove: (evt, gestureState) => {
        if (isSpinning) return;
        
        // Calculate angle based on touch position relative to wheel center
        const { moveX, moveY } = gestureState;
        const rect = {
          x: wheelRadius - centerX,
          y: wheelRadius - centerY
        };
        
        // Calculate angle using arctangent
        let angle = Math.atan2(moveY - centerY, moveX - centerX) * (180 / Math.PI);
        if (angle < 0) angle += 360; // Convert to 0-360 range
        
        // Update manual spin angle
        setManualSpinAngle(angle);
        
        // Apply angle to the wheel
        spinValue.setValue(angle / 360);
      },
      onPanResponderRelease: (evt, gestureState) => {
        if (isSpinning) return;
        
        // Calculate velocity for a "flick" gesture
        const { vx, vy } = gestureState;
        const velocity = Math.sqrt(vx * vx + vy * vy);
        
        // If velocity is above threshold, trigger a spin
        if (velocity > 0.3) {
          // Direction based on gesture
          const direction = vx > 0 ? 1 : -1;
          startSpin(direction, velocity);
        }
      }
    })
  ).current;

  // Animation for button pulsing
  useEffect(() => {
    const pulseAnimation = Animated.loop(
      Animated.sequence([
        Animated.timing(buttonScale, {
          toValue: 1.1,
          duration: 800,
          easing: Easing.out(Easing.ease),
          useNativeDriver: true,
        }),
        Animated.timing(buttonScale, {
          toValue: 1,
          duration: 800,
          easing: Easing.in(Easing.ease),
          useNativeDriver: true,
        })
      ])
    );
    
    if (!isSpinning && !hasSpun) {
      pulseAnimation.start();
    } else {
      buttonScale.setValue(1);
      pulseAnimation.stop();
    }
    
    return () => pulseAnimation.stop();
  }, [isSpinning, hasSpun]);

  // Update wheel size when orientation changes
  useEffect(() => {
    const updateLayout = () => {
      const { width: newWidth, height: newHeight } = Dimensions.get('window');
      // This will cause component to re-render with new size
      LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
    };

    // Listen for dimension changes (orientation changes)
    Dimensions.addEventListener('change', updateLayout);

    // Cleanup listener
    return () => {
      // Handle removal differently based on API version
      if (Dimensions.removeEventListener) {
        Dimensions.removeEventListener('change', updateLayout);
      }
    };
  }, []);

  // Generate path for a segment
  const generateSegmentPath = (i) => {
    const startAngle = (i * segmentAngle - segmentAngle / 2 + angleOffset) * Math.PI / 180;
    const endAngle = ((i + 1) * segmentAngle - segmentAngle / 2 + angleOffset) * Math.PI / 180;
    
    const startX = centerX + (wheelRadius - 5) * Math.cos(startAngle);
    const startY = centerY + (wheelRadius - 5) * Math.sin(startAngle);
    const endX = centerX + (wheelRadius - 5) * Math.cos(endAngle);
    const endY = centerY + (wheelRadius - 5) * Math.sin(endAngle);
    
    const largeArcFlag = segmentAngle > 180 ? 1 : 0;
    
    // Generate the SVG path
    return `M ${centerX} ${centerY} L ${startX} ${startY} A ${wheelRadius - 5} ${wheelRadius - 5} 0 ${largeArcFlag} 1 ${endX} ${endY} Z`;
  };

  // Start spinning animation
  const startSpin = (direction = 1, velocityMultiplier = 1) => {
    if (isSpinning) return;
    
    // Provide haptic feedback
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    
    // Mark as spinning
    setIsSpinning(true);
    setHasSpun(true);
    setDragEnabled(false);
    
    // Determine the winning segment
    let targetIndex;
    if (winnerIndex !== null && winnerIndex >= 0 && winnerIndex < segments.length) {
      targetIndex = winnerIndex;
    } else {
      targetIndex = Math.floor(Math.random() * segments.length);
    }
    
    // Calculate total rotation needed to land on the target segment
    // We want the wheel to spin at least 5 full rotations plus the specific angle
    const currentRotation = spinValue.__getValue() * 360;
    const targetAngle = 360 - (targetIndex * segmentAngle); // Inverted for clockwise rotation
    const minimumSpinDegrees = 360 * 5; // At least 5 full rotations
    
    // Add extra variance to make spins less predictable
    const extraSpin = Math.random() * 360; // Random additional rotation
    
    // Calculate total rotation amount
    let totalRotation = currentRotation + minimumSpinDegrees + targetAngle + extraSpin;
    
    // Adjust duration based on velocity for manual spins
    const adjustedDuration = velocityMultiplier > 1 
      ? duration / Math.min(velocityMultiplier, 3) // Faster for flick gestures
      : duration;
    
    // Wheel spin animation with physics-based easing
    Animated.timing(spinValue, {
      toValue: totalRotation / 360,
      duration: adjustedDuration,
      easing: Easing.out(Easing.cubic), // Physics-based easing
      useNativeDriver: true,
    }).start(() => {
      // Spin complete
      setIsSpinning(false);
      setWinner(segments[targetIndex]);
      
      // Add some bounce effect at the end
      Animated.sequence([
        Animated.timing(wheelScale, {
          toValue: 1.05,
          duration: 150,
          easing: Easing.out(Easing.ease),
          useNativeDriver: true,
        }),
        Animated.timing(wheelScale, {
          toValue: 1,
          duration: 150,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
      ]).start();
      
      // Glow animation for the winner
      Animated.timing(glowOpacity, {
        toValue: 1,
        duration: 500,
        useNativeDriver: true,
      }).start();
      
      // Provide success haptic feedback
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      
      // Call the onFinish callback
      if (onFinish) {
        onFinish(segments[targetIndex], targetIndex);
      }
      
      // Re-enable dragging after a delay
      setTimeout(() => {
        setDragEnabled(true);
      }, 1000);
    });
    
    // Scale animation for wheel while spinning
    Animated.sequence([
      // Scale up slightly when starting
      Animated.timing(wheelScale, {
        toValue: 1.02,
        duration: 200,
        useNativeDriver: true,
      }),
      // Scale back to normal during spin
      Animated.timing(wheelScale, {
        toValue: 1,
        duration: 500,
        useNativeDriver: true,
      }),
    ]).start();
  };

  // Animated rotation style
  const wheelRotationStyle = {
    transform: [
      { rotate: spinValue.interpolate({
          inputRange: [0, 1],
          outputRange: ['0deg', '360deg'],
        })
      },
      { scale: wheelScale }
    ]
  };
  
  // Button animation style
  const buttonAnimationStyle = {
    transform: [{ scale: buttonScale }]
  };
  
  // Glow animation style
  const glowAnimationStyle = {
    opacity: glowOpacity
  };
  
  return (
    <View style={styles.container}>
      {/* Wheel Container */}
      <View style={styles.wheelContainer}>
        {/* Wheel glow effect */}
        <Animated.View 
          style={[
            styles.wheelGlow,
            { width: size + 20, height: size + 20 },
            glowAnimationStyle
          ]}
        />
        
        {/* Wheel Pointer/Indicator */}
        <View style={styles.indicatorContainer}>
          <View style={styles.indicatorOuter}>
            <View style={[styles.indicatorInner, { borderTopColor: primaryColor }]} />
          </View>
        </View>
        
        {/* Main Wheel */}
        <Animated.View 
          {...panResponder.panHandlers}
          style={[
            styles.wheel, 
            { width: size, height: size },
            wheelRotationStyle
          ]}
        >
          <Svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
            {/* Defs for gradients and filters */}
            <Defs>
              {/* Shimmer gradient for wheel segments */}
              <LinearGradient id="shimmerGradient" x1="0" y1="0" x2="1" y2="1">
                <Stop offset="0" stopColor="rgba(255,255,255,0.1)" />
                <Stop offset="0.5" stopColor="rgba(255,255,255,0.3)" />
                <Stop offset="1" stopColor="rgba(255,255,255,0.1)" />
              </LinearGradient>
              
              {/* Center button gradient */}
              <RadialGradient
                id="centerGradient"
                cx="0.5"
                cy="0.5"
                rx="0.5"
                ry="0.5"
                fx="0.4"
                fy="0.4"
              >
                <Stop offset="0" stopColor={`${primaryColor}FF`} />
                <Stop offset="1" stopColor={`${primaryColor}AA`} />
              </RadialGradient>
            </Defs>
            
            {/* Wheel Outer Ring */}
            <Circle
              cx={centerX}
              cy={centerY}
              r={wheelRadius}
              fill="none"
              stroke={primaryColor}
              strokeWidth={5}
              strokeLinecap="round"
            />
            
            {/* Wheel Segments */}
            {segments.map((segment, i) => (
              <G key={`segment-${i}`}>
                {/* Segment background */}
                <Path
                  d={generateSegmentPath(i)}
                  fill={segment.color || (i % 2 === 0 ? primaryColor : '#222')}
                  stroke="transparent"
                  strokeWidth={0}
                />
                
                {/* Shimmer overlay */}
                <Path
                  d={generateSegmentPath(i)}
                  fill="url(#shimmerGradient)"
                  opacity={0.15}
                />
                
                {/* Segment divider lines - made completely transparent */}
                <Path
                  d={`M ${centerX} ${centerY} L ${
                    centerX + wheelRadius * Math.cos((i * segmentAngle + angleOffset) * Math.PI / 180)
                  } ${
                    centerY + wheelRadius * Math.sin((i * segmentAngle + angleOffset) * Math.PI / 180)
                  }`}
                  stroke="transparent"
                  strokeWidth={0}
                />
                
                {/* Text positioning */}
                <G 
                  rotation={(i * segmentAngle + segmentAngle / 2 + angleOffset)} 
                  transformOrigin={`${centerX} ${centerY}`}
                >
                  {/* Text */}
                  <SvgText
                    x={centerX}
                    y={centerY - wheelRadius * 0.7} // Position text away from center
                    fill={textColor}
                    fontSize={Math.min(16, size / 20)}
                    fontWeight="bold"
                    textAnchor="middle"
                  >
                    {segment.text}
                  </SvgText>
                  
                  {/* Icon as Unicode character for better compatibility */}
                  <SvgText
                    x={centerX}
                    y={centerY - wheelRadius * 0.4} // Position icon closer to center than text
                    fill={textColor}
                    fontSize={Math.min(24, size / 15)}
                    textAnchor="middle"
                  >
                    {getIconForSegment(segment.icon)}
                  </SvgText>
                </G>
              </G>
            ))}
            
            {/* Center circle with improved design */}
            <Circle
              cx={centerX}
              cy={centerY}
              r={wheelRadius * 0.15}
              fill="url(#centerGradient)"
              stroke="#fff"
              strokeWidth={2}
            />
            
            {/* Shine effect on center button */}
            <Circle
              cx={centerX - wheelRadius * 0.05}
              cy={centerY - wheelRadius * 0.05}
              r={wheelRadius * 0.08}
              fill="rgba(255,255,255,0.3)"
              opacity={0.5}
            />
            
            {/* Pegs around the wheel for casino feel */}
            {Array.from({ length: segments.length * 2 }).map((_, i) => {
              const angle = (i * 180 / segments.length + angleOffset) * Math.PI / 180;
              return (
                <Circle
                  key={`peg-${i}`}
                  cx={centerX + (wheelRadius - 15) * Math.cos(angle)}
                  cy={centerY + (wheelRadius - 15) * Math.sin(angle)}
                  r={4}
                  fill="#fff"
                />
              );
            })}
          </Svg>
        </Animated.View>
      </View>
        
      {/* Spin Button - Moved below the wheel */}
      <Animated.View style={[styles.spinButtonContainer, buttonAnimationStyle]}>
        <TouchableOpacity
          style={[styles.spinButton, { backgroundColor: primaryColor }]}
          onPress={() => startSpin()}
          disabled={isSpinning}
          activeOpacity={0.8}
        >
          <Text style={styles.spinButtonText}>
            {isSpinning ? 'Spinning...' : 'SPIN'}
          </Text>
        </TouchableOpacity>
      </Animated.View>
      
      {/* Prize information - Only showing "Try Again" notification */}
      {winner && winner.id === '3' && (
        <View style={styles.winnerContainer}>
          <Ionicons name="refresh" size={32} color={colors.text.tertiary} />
          <Text style={styles.winnerTitle}>Better Luck Next Time</Text>
          <Text style={styles.winnerText}>Keep trying for a chance to win amazing prizes!</Text>
        </View>
      )}
    </View>
  );
};

// Helper function to convert icon names to Unicode symbols for SVG Text
function getIconForSegment(iconName) {
  const iconMap = {
    'pricetag': '🏷️',
    'cafe': '☕',
    'refresh': '🔄',
    'restaurant': '🍽️',
    'ice-cream': '🍦',
    'trophy': '🏆',
    'gift': '🎁',
    'ticket': '🎟️',
    'pizza': '🍕',
    'bed': '🛏️',
    'airplane': '✈️',
    'cart': '🛒',
    'star': '⭐',
    'cash': '💰'
  };
  
  return iconMap[iconName] || '🎯';
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: spacing.lg,
    width: '100%',
  },
  wheelContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
    marginVertical: spacing.xl,
    width: '100%',
  },
  wheelGlow: {
    position: 'absolute',
    borderRadius: 1000,
    backgroundColor: 'transparent',
    borderWidth: 15,
    borderColor: 'rgba(255, 215, 0, 0.2)', // Golden glow
    ...Platform.select({
      ios: {
        shadowColor: 'rgba(255, 215, 0, 0.8)',
        shadowOffset: { width: 0, height: 0 },
        shadowOpacity: 0.8,
        shadowRadius: 20,
      },
      android: {
        elevation: 8,
      },
    }),
  },
  wheel: {
    borderRadius: 1000,
    overflow: 'hidden',
    ...Platform.select({
      ios: {
        shadowColor: 'rgba(0,0,0,0.5)',
        shadowOffset: { width: 0, height: 5 },
        shadowOpacity: 0.5,
        shadowRadius: 10,
      },
      android: {
        elevation: 10,
      },
    }),
  },
  indicatorContainer: {
    position: 'absolute',
    top: -25,
    alignItems: 'center',
    zIndex: 10,
  },
  indicatorOuter: {
    width: 30,
    height: 30,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#222',
    borderRadius: 8,
    borderBottomLeftRadius: 15,
    borderBottomRightRadius: 15,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 3 },
        shadowOpacity: 0.5,
        shadowRadius: 5,
      },
      android: {
        elevation: 6,
      },
    }),
  },
  indicatorInner: {
    width: 0,
    height: 0,
    borderLeftWidth: 10,
    borderRightWidth: 10,
    borderTopWidth: 18,
    borderLeftColor: 'transparent',
    borderRightColor: 'transparent',
    marginBottom: -6,
  },
  spinButtonContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: spacing.md,
    zIndex: 5,
  },
  spinButton: {
    width: 100,
    height: 50,
    borderRadius: 25,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 3,
    borderColor: '#fff',
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
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 18,
  },
  winnerContainer: {
    marginTop: spacing.xl,
    padding: spacing.md,
    backgroundColor: colors.ui.card,
    borderRadius: spacing.borderRadius.lg,
    alignItems: 'center',
    justifyContent: 'center',
    width: '100%',
    maxWidth: 350,
    alignSelf: 'center',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.2,
        shadowRadius: 6,
      },
      android: {
        elevation: 6,
      },
    }),
  },
  winnerTitle: {
    fontSize: typography.fontSize.lg,
    fontWeight: 'bold',
    color: colors.text.primary,
    marginBottom: spacing.sm,
  },
  winnerText: {
    fontSize: typography.fontSize.md,
    color: colors.text.primary,
    textAlign: 'center',
  },
  winnerTextHighlight: {
    fontWeight: 'bold',
  },
  winnerIconContainer: {
    marginTop: spacing.md,
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'rgba(0,0,0,0.05)',
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default SpinningWheel; 