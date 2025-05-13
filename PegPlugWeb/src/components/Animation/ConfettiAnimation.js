import React, { useEffect } from 'react';
import { View, StyleSheet, Dimensions } from 'react-native';
import Animated, { 
  useSharedValue, 
  useAnimatedStyle, 
  withTiming, 
  withDelay, 
  Easing,
  runOnJS,
  withSequence
} from 'react-native-reanimated';
import { colors } from '../../theme';

const { width, height } = Dimensions.get('window');

const CONFETTI_COLORS = [
  colors.primary.red,
  colors.secondary.blue,
  '#FFD700', // Gold
  '#FF4F00', // Orange
  '#8A2BE2', // Purple
  '#32CD32', // Lime Green
  '#FF1493', // Pink
  '#00BFFF', // Deep Sky Blue
  '#FF00FF', // Magenta
  '#FFFF00', // Yellow
];

/**
 * ConfettiAnimation - Displays celebratory confetti particles
 * 
 * @param {boolean} active - Whether the confetti should be active
 * @param {number} duration - How long the confetti animation should last (in ms)
 * @param {number} count - Number of confetti particles
 * @param {function} onComplete - Callback when animation completes
 */
const ConfettiAnimation = ({ 
  active = false, 
  duration = 3000, 
  count = 100,
  onComplete = () => {},
}) => {
  // Generate confetti pieces
  const confetti = React.useMemo(() => {
    return Array.from({ length: count }).map(() => {
      // Random properties for each piece
      return {
        color: CONFETTI_COLORS[Math.floor(Math.random() * CONFETTI_COLORS.length)],
        x: Math.random() * width,
        y: -20 - Math.random() * 100, // Start above screen
        size: 5 + Math.random() * 10,
        angle: Math.random() * 360,
        delay: Math.random() * 500,
        speedX: (Math.random() - 0.5) * 8,
        speedY: 3 + Math.random() * 5,
        speedRotation: (Math.random() - 0.5) * 15,
        opacity: 0.7 + Math.random() * 0.3,
      };
    });
  }, [count]);

  // Handle animation completion
  const animationComplete = () => {
    onComplete();
  };

  // Render individual confetti pieces
  const renderConfetti = () => {
    return confetti.map((piece, index) => {
      // Animated values
      const x = useSharedValue(piece.x);
      const y = useSharedValue(piece.y);
      const rotate = useSharedValue(piece.angle);
      const opacity = useSharedValue(0);

      // Start animation when active
      useEffect(() => {
        if (active) {
          // Fade in
          opacity.value = withDelay(
            piece.delay,
            withTiming(piece.opacity, { duration: 200 })
          );

          // Movement animation
          const fallDuration = duration - piece.delay;
          
          // Horizontal zigzag movement
          x.value = withDelay(
            piece.delay,
            withSequence(
              withTiming(piece.x + piece.speedX * 20, { 
                duration: fallDuration * 0.3 
              }),
              withTiming(piece.x - piece.speedX * 15, { 
                duration: fallDuration * 0.3 
              }),
              withTiming(piece.x + piece.speedX * 10, { 
                duration: fallDuration * 0.4,
                easing: Easing.bezier(0.25, 0.1, 0.25, 1) 
              }),
            )
          );
          
          // Vertical falling movement
          y.value = withDelay(
            piece.delay,
            withTiming(height + 100, {
              duration: fallDuration,
              easing: Easing.bezier(0.215, 0.61, 0.355, 1)
            }, 
            index === 0 ? () => runOnJS(animationComplete)() : undefined)
          );
          
          // Rotation
          rotate.value = withDelay(
            piece.delay,
            withTiming(piece.angle + piece.speedRotation * 20, {
              duration: fallDuration,
            })
          );
        } else {
          // Reset when not active
          opacity.value = withTiming(0, { duration: 200 });
        }
      }, [active]);

      // Create animated style
      const animatedStyle = useAnimatedStyle(() => {
        return {
          position: 'absolute',
          left: x.value,
          top: y.value,
          width: piece.size,
          height: piece.size * (0.6 + Math.random() * 0.8),
          backgroundColor: piece.color,
          borderRadius: piece.size / 5,
          opacity: opacity.value,
          transform: [{ rotate: `${rotate.value}deg` }],
        };
      });

      return <Animated.View key={index} style={animatedStyle} />;
    });
  };

  if (!active) return null;

  return (
    <View style={styles.container} pointerEvents="none">
      {renderConfetti()}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    ...StyleSheet.absoluteFillObject,
    zIndex: 1000,
    pointerEvents: 'none',
  },
});

export default ConfettiAnimation; 