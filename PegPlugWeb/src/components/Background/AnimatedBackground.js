import React, { useRef, useEffect, useMemo } from 'react';
import { View, StyleSheet, Dimensions, Platform } from 'react-native';
import Animated, { 
  useSharedValue, 
  useAnimatedStyle, 
  withTiming, 
  withRepeat, 
  withSequence, 
  Easing,
  withDelay 
} from 'react-native-reanimated';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../../theme';

const { width, height } = Dimensions.get('window');

/**
 * Optimized AnimatedBackground component that creates floating icons
 * with configurable appearance and performance settings.
 * Uses react-native-reanimated for better cross-platform animation.
 */
const AnimatedBackground = ({ 
  particleCount = 25,
  iconTypes = ['cash', 'pricetag', 'gift', 'star', 'trophy', 'ticket'],
  includeCoins = true,
  opacity = 0.25,
  speed = 1.0,
  startPosition = 'random'
}) => {
  // Use fewer particles on slower devices or web
  const actualParticleCount = Platform.OS === 'android' 
    ? Math.min(particleCount, 12) 
    : Platform.OS === 'web'
      ? Math.min(particleCount, 15)
      : Math.min(particleCount, 20);
  
  // Create particles array
  const particles = useMemo(() => {
    // Get full screen dimensions with extra margin
    const fullWidth = width + 200;
    const fullHeight = height + 200;
    
    // Position particles based on the startPosition setting
    const getInitialPosition = () => {
      switch (startPosition) {
        case 'bottom':
          return {
            startX: Math.random() * fullWidth - 100,
            startY: height + Math.random() * 100 // Start below the screen
          };
        case 'middle':
          return {
            startX: Math.random() * fullWidth - 100,
            startY: Math.random() * height * 0.8 + height * 0.1 // Middle 80% of the screen
          };
        case 'random':
        default:
          return {
            startX: Math.random() * fullWidth - 100,
            startY: Math.random() * fullHeight - 100
          };
      }
    };
    
    return Array(actualParticleCount).fill(0).map(() => {
      const position = getInitialPosition();
      
      // For cash icons, use more varied and faster movement
      const isCashOrCoin = iconTypes.length === 1 && iconTypes[0] === 'cash';
      
      // Generate random movement vector with more variation for cash
      const moveX = (Math.random() * 2 - 1) * (isCashOrCoin ? 1.2 : 0.5); 
      const moveY = (Math.random() * 2 - 1) * (isCashOrCoin ? 1.0 : 0.5); 
      
      return {
        // Position properties
        x: position.startX,
        y: position.startY,
        // Movement direction and speed
        moveX: moveX,
        moveY: moveY,
        // Appearance
        size: 18 + (Math.random() * 22), // Slightly larger on average
        isCoin: includeCoins && Math.random() > 0.7,
        iconIndex: Math.floor(Math.random() * iconTypes.length),
        scale: Math.random() * 0.5 + 0.7, // Slightly larger scale
        initialOpacity: Math.random() * opacity * 0.8 + (opacity * 0.2),
        // Animation speeds - faster for more dynamic feel
        wiggleDuration: (1500 + Math.random() * 2000) / speed,
        wiggleDelay: Math.random() * 1000,
        // Initial rotation (only for native platforms)
        rotation: 0
      };
    });
  }, [actualParticleCount, iconTypes, includeCoins, opacity, speed, height, width, startPosition]);
  
  // Create refs for managing particle movement
  const particleRefs = useRef(new Map()).current;
  const animationFrameId = useRef(null);
  const lastTimeRef = useRef(Date.now());
  
  useEffect(() => {
    // Setup animation loop
    const animateParticles = () => {
      const currentTime = Date.now();
      const deltaTime = (currentTime - lastTimeRef.current) / 1000; // Time in seconds
      lastTimeRef.current = currentTime;
      
      // Update each particle position
      particles.forEach((particle, index) => {
        const particleInfo = particleRefs.get(index);
        if (!particleInfo) return;
        
        // Update positions
        particle.x += particle.moveX * deltaTime * 70;
        particle.y += particle.moveY * deltaTime * 70;
        
        // Wrap around screen edges with a buffer
        const buffer = 120;
        if (particle.x < -buffer) particle.x = width + buffer/2;
        if (particle.x > width + buffer) particle.x = -buffer/2;
        if (particle.y < -buffer) particle.y = height + buffer/2;
        if (particle.y > height + buffer) particle.y = -buffer/2;
        
        // Occasionally change direction slightly for more natural movement
        if (Math.random() < 0.01) {
          particle.moveX += (Math.random() * 0.4 - 0.2);
          particle.moveY += (Math.random() * 0.4 - 0.2);
          
          // Keep speed reasonable but allow for more variety
          const speed = Math.sqrt(particle.moveX * particle.moveX + particle.moveY * particle.moveY);
          const maxSpeed = 1.5;
          if (speed > maxSpeed) {
            particle.moveX = (particle.moveX / speed) * maxSpeed;
            particle.moveY = (particle.moveY / speed) * maxSpeed;
          }
        }
        
        // Update shared values
        particleInfo.posX.value = particle.x;
        particleInfo.posY.value = particle.y;
      });
      
      // Schedule next frame
      animationFrameId.current = requestAnimationFrame(animateParticles);
    };
    
    // Start animation loop
    animationFrameId.current = requestAnimationFrame(animateParticles);
    
    // Cleanup
    return () => {
      if (animationFrameId.current) {
        cancelAnimationFrame(animationFrameId.current);
      }
    };
  }, [particles, particleRefs]);
  
  // Render particles using reanimated
  const renderParticles = () => {
    return particles.map((particle, index) => {
      // Initialize shared values for this particle
      const posX = useSharedValue(particle.x);
      const posY = useSharedValue(particle.y);
      const wiggle = useSharedValue(0);
      const scale = useSharedValue(particle.scale);
      const opacity = useSharedValue(0);
      
      // Store references for the animation loop
      if (!particleRefs.has(index)) {
        particleRefs.set(index, { posX, posY, wiggle, scale, opacity });
      }
      
      // Start wiggle animation
      useEffect(() => {
        // Fade in
        opacity.value = withTiming(particle.initialOpacity, { 
          duration: 1000, 
          easing: Easing.out(Easing.cubic) 
        });
        
        // Wiggle animation
        wiggle.value = withDelay(
          particle.wiggleDelay,
          withRepeat(
            withSequence(
              withTiming(1, { 
                duration: particle.wiggleDuration,
                easing: Easing.inOut(Easing.cubic)
              }),
              withTiming(0, { 
                duration: particle.wiggleDuration,
                easing: Easing.inOut(Easing.cubic)
              })
            ),
            -1, // Infinite repeat
            false // No reverse
          )
        );
      }, []);
      
      // Get icon type for this particle
      const iconType = iconTypes[particle.iconIndex];
      const isCoin = particle.isCoin;
      
      // Determine color based on icon type
      const getIconColor = () => {
        // Make all cash and coins green
        if (isCoin || iconType === 'cash') {
          return '#22c55e'; // Bright green for all money icons
        }
        
        switch (iconType) {
          case 'pricetag':
            return colors.status.success;
          case 'gift':
          case 'ticket':
            return colors.primary.red;
          case 'star':
          case 'trophy':
            return colors.secondary.blue;
          case 'restaurant':
          case 'cafe':
          case 'fast-food':
          case 'pizza':
            return colors.status.warning;
          case 'cart':
          case 'bag':
            return colors.secondary.blue;
          case 'airplane':
          case 'bed':
            return colors.status.info;
          default:
            return colors.text.primary;
        }
      };
      
      // Create animated style for particle
      const animatedStyle = useAnimatedStyle(() => {
        // Calculate wiggle rotation (-7 to 7 degrees)
        const rotationDegrees = (wiggle.value * 14) - 7;
        
        return {
          position: 'absolute',
          width: particle.size,
          height: particle.size,
          left: posX.value,
          top: posY.value,
          transform: [
            { rotate: `${rotationDegrees}deg` },
            { scale: scale.value }
          ],
          opacity: opacity.value,
          justifyContent: 'center',
          alignItems: 'center',
        };
      });
      
      return (
        <Animated.View key={index} style={animatedStyle}>
          <Ionicons
            name={isCoin ? 'cash-outline' : `${iconType}-outline`}
            size={particle.size}
            color={getIconColor()}
          />
        </Animated.View>
      );
    });
  };
  
  return (
    <View style={styles.container}>
      {renderParticles()}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    overflow: 'hidden',
    zIndex: -1,
    pointerEvents: 'none'
  }
});

export default React.memo(AnimatedBackground); 