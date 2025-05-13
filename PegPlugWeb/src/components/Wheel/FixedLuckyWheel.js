// This is a patched version of the LuckyWheel component from react-native-lucky-wheel
// that fixes the TextAngles.VERTICAL issue

import React, { forwardRef, useRef, useImperativeHandle, useState, useEffect } from 'react';
import { View, StyleSheet, Animated, Easing } from 'react-native';
import { G, Path, Text, Circle, Line } from 'react-native-svg';
import Svg from 'react-native-svg';

// Define constants used in the library
const TextAngles = {
  VERTICAL: 'vertical',
  HORIZONTAL: 'horizontal'
};

const EasingTypes = {
  IN: 'in',
  OUT: 'out',
  INOUT: 'inout'
};

/**
 * FixedLuckyWheel - A patched version of LuckyWheel that handles TextAngles internally
 */
const FixedLuckyWheel = forwardRef(({
  slices = [],
  size = 300,
  backgroundColor = '#FFF',
  textStyle = { fontSize: 14, fontWeight: 'bold', color: '#fff' },
  knobSize = 30,
  knobColor = '#FF0000',
  borderWidth = 1,
  borderColor = '#FFF',
  duration = 5,
  easing = EasingTypes.OUT,
  onSpinningEnd = () => {},
  onSpinningStart = () => {},
  textAngle = TextAngles.VERTICAL,
  spinTime = 8,
  winnnerIndex = null,
  backgroundColorOptions = { luminosity: 'dark', hue: 'random' },
  enableOuterDots = true,
  enableInnerShadow = true,
  segColors = [],
}, ref) => {
  const [spinning, setSpinning] = useState(false);
  const [winner, setWinner] = useState(null);
  const [started, setStarted] = useState(false);
  const [spinCounter, setSpinCounter] = useState(0);
  const spinAnimation = useRef(new Animated.Value(0)).current;
  
  // Expose methods via ref
  useImperativeHandle(ref, () => ({
    start: (index = null) => {
      if (spinning) return;
      
      startSpinning(index);
    },
    stop: () => {
      stopSpinning();
    },
    reset: () => {
      resetSpinning();
    }
  }));
  
  // Handle spin animation
  const startSpinning = (forcedIndex = null) => {
    if (spinning) return;
    
    setSpinning(true);
    setStarted(true);
    
    // Increment spin counter
    const newSpinCount = spinCounter + 1;
    setSpinCounter(newSpinCount);
    
    // Determine winner
    let winningIndex;
    if (forcedIndex !== null && forcedIndex >= 0 && forcedIndex < slices.length) {
      winningIndex = forcedIndex;
    } else if (winnnerIndex !== null && winnnerIndex >= 0 && winnnerIndex < slices.length) {
      winningIndex = winnnerIndex;
    } else {
      winningIndex = Math.floor(Math.random() * slices.length);
    }
    
    // Calculate segments and angles
    const numberOfSegments = slices.length;
    const anglePerSegment = 360 / numberOfSegments;
    const winningAngle = (360 - (winningIndex * anglePerSegment)) % 360;
    
    // Call start callback
    onSpinningStart();
    
    // Use different spinning behavior for first and second spin
    const isSecondSpin = newSpinCount === 2;
    
    // Animated spinning - more rotations for the second (winning) spin
    Animated.timing(spinAnimation, {
      toValue: isSecondSpin ? 
        3 + (winningAngle / 360) : // 3 full rotations for the second (winning) spin
        1 + (winningAngle / 360),  // Just 1 full rotation for the first spin
      duration: duration * 1000,
      easing: getEasingFunction(easing),
      useNativeDriver: true
    }).start(() => {
      // Spin complete
      setWinner(slices[winningIndex]);
      setSpinning(false);
      
      // Call finish callback
      onSpinningEnd(slices[winningIndex], winningIndex);
    });
  };
  
  // Stop spinning animation
  const stopSpinning = () => {
    if (!spinning) return;
    
    spinAnimation.stopAnimation();
    setSpinning(false);
  };
  
  // Reset spin state
  const resetSpinning = () => {
    spinAnimation.setValue(0);
    setStarted(false);
    setWinner(null);
    setSpinCounter(0);
  };
  
  // Get appropriate Easing function
  const getEasingFunction = (type) => {
    switch (type) {
      case EasingTypes.IN:
        return Easing.in(Easing.ease);
      case EasingTypes.OUT:
        return Easing.out(Easing.exp);
      case EasingTypes.INOUT:
        return Easing.inOut(Easing.ease);
      default:
        return Easing.out(Easing.exp);
    }
  };
  
  // Set up rotation interpolation
  const spin = spinAnimation.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg']
  });
  
  // Render wheel segments
  const renderWheel = () => {
    const numberOfSegments = slices.length;
    const anglePerSegment = 360 / numberOfSegments;
    const radius = size / 2;
    
    return (
      <Svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
        {/* Wheel */}
        <Circle
          cx={radius}
          cy={radius}
          r={radius - borderWidth}
          stroke={borderColor}
          strokeWidth={borderWidth}
          fill={backgroundColor}
        />
        
        {/* Segments */}
        {slices.map((slice, index) => {
          const angle = index * anglePerSegment;
          
          // Calculate coordinates for segment path
          const x1 = radius + (radius - borderWidth) * Math.cos((angle - 90) * Math.PI / 180);
          const y1 = radius + (radius - borderWidth) * Math.sin((angle - 90) * Math.PI / 180);
          const x2 = radius + (radius - borderWidth) * Math.cos(((angle + anglePerSegment) - 90) * Math.PI / 180);
          const y2 = radius + (radius - borderWidth) * Math.sin(((angle + anglePerSegment) - 90) * Math.PI / 180);
          
          // Get color for segment
          const segmentColor = segColors[index] || slice.color || '#' + ((1 << 24) * Math.random() | 0).toString(16);
          
          // Generate segment path
          const pathData = `M ${radius} ${radius} L ${x1} ${y1} A ${radius - borderWidth} ${radius - borderWidth} 0 0 1 ${x2} ${y2} Z`;
          
          return (
            <G key={index}>
              <Path
                d={pathData}
                fill={segmentColor}
              />
              
              {/* Text */}
              <G
                rotation={angle + (anglePerSegment / 2)}
                transformOrigin={`${radius} ${radius}`}
              >
                {textAngle === TextAngles.HORIZONTAL ? (
                  <Text
                    x={radius}
                    y={radius - (radius * 0.6)}
                    fill={textStyle.color || '#fff'}
                    fontSize={textStyle.fontSize || 14}
                    fontWeight={textStyle.fontWeight || 'bold'}
                    textAnchor="middle"
                  >
                    {slice.text}
                  </Text>
                ) : (
                  <Text
                    x={radius}
                    y={radius - (radius * 0.6)}
                    fill={textStyle.color || '#fff'}
                    fontSize={textStyle.fontSize || 14}
                    fontWeight={textStyle.fontWeight || 'bold'}
                    textAnchor="middle"
                    rotation={90}
                    origin={`${radius}, ${radius - (radius * 0.6)}`}
                    // Fix the transform-origin warning by using transformOrigin prop instead
                    transformOrigin={`${radius} ${radius - (radius * 0.6)}`}
                  >
                    {slice.text}
                  </Text>
                )}
              </G>
              
              {/* Divider Lines */}
              <Line
                x1={radius}
                y1={radius}
                x2={x1}
                y2={y1}
                stroke={borderColor}
                strokeWidth={1}
              />
            </G>
          );
        })}
        
        {/* Center Circle */}
        <Circle
          cx={radius}
          cy={radius}
          r={knobSize / 3}
          fill={knobColor}
          stroke={borderColor}
          strokeWidth={1}
        />
      </Svg>
    );
  };
  
  return (
    <View style={styles.container}>
      <Animated.View
        style={[
          styles.wheel,
          { transform: [{ rotate: spin }] }
        ]}
      >
        {renderWheel()}
      </Animated.View>
    </View>
  );
});

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  wheel: {
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default FixedLuckyWheel; 