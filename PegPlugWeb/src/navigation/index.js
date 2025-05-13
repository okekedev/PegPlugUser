import React, { useState, useRef, useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../services/AuthContext';
import { colors, typography, spacing } from '../theme';
import { View, Text, StyleSheet, TouchableOpacity, Alert, Image, Animated, Easing, Platform } from 'react-native';
import AnimatedBackground from '../components/Background/AnimatedBackground';
import * as Haptics from 'expo-haptics';

// Import screens
import HomeScreen from '../screens/Home/HomeScreen';
import ProfileScreen from '../screens/Profile/ProfileScreen';
import DealsScreen from '../screens/Deals/DealsScreen';
import SlotMachineScreen from '../screens/SlotMachine/SlotMachineScreen';
import SpinDealScreen from '../screens/Deals/SpinDealScreen';

// Auth screens
const LoginScreen = ({ navigation }) => {
  const { login } = useAuth();
  const [isLoggingIn, setIsLoggingIn] = useState(false);
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(30)).current;
  
  useEffect(() => {
    // Animate elements when screen mounts
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 800,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 800,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      })
    ]).start();
  }, []);
  
  const handleLogin = async () => {
    try {
      setIsLoggingIn(true);
      
      // Provide haptic feedback
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
      
      // Log in with demo credentials
      await login('demo@example.com', 'password123');
    } catch (error) {
      console.error('Login error:', error);
      Alert.alert('Login Failed', 'Could not log in. Please try again.');
    } finally {
      setIsLoggingIn(false);
    }
  };
  
  return (
    <View style={styles.authContainer}>
      {/* Green dollar bills floating around */}
      <AnimatedBackground 
        particleCount={40}  /* Increased for more bills */
        iconTypes={['cash']} /* Only using cash/money icons */
        includeCoins={true}
        opacity={0.85} /* Higher opacity to make them more visible */
        speed={1.2}  /* Faster animation */
        startPosition="random" /* Random positioning for movement in all directions */
      />
      
      <Animated.View 
        style={[
          styles.logoContainer, 
          { opacity: fadeAnim, transform: [{ translateY: slideAnim }] }
        ]}
      >
        <Image 
          source={require('../../assets/peglogored.png')} 
          style={styles.logo}
          resizeMode="contain"
        />
        <Text style={styles.tagline}>Your Passport to Local Rewards</Text>
      </Animated.View>
      
      <Animated.View 
        style={[
          styles.authFormContainer,
          { opacity: fadeAnim, transform: [{ translateY: slideAnim }] }
        ]}
      >
        <Text style={styles.authTitle}>Welcome Back</Text>
        
        <View style={styles.buttonContainer}>
          <TouchableOpacity 
            style={[styles.authButton, isLoggingIn && styles.authButtonDisabled]}
            onPress={handleLogin}
            disabled={isLoggingIn}
          >
            <Ionicons name="log-in-outline" size={20} color={colors.primary.white} />
            <Text style={styles.authButtonText}>
              {isLoggingIn ? 'Logging in...' : 'Log In'}
            </Text>
          </TouchableOpacity>
          
          <TouchableOpacity 
            style={styles.authAltButton}
            onPress={() => navigation.navigate('Signup')}
            disabled={isLoggingIn}
          >
            <Text style={styles.authAltButtonText}>Create Account</Text>
          </TouchableOpacity>
        </View>
      </Animated.View>
    </View>
  );
};

const SignupScreen = ({ navigation }) => {
  const { signup } = useAuth();
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(30)).current;
  
  useEffect(() => {
    // Animate elements when screen mounts
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 800,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 800,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      })
    ]).start();
  }, []);
  
  return (
    <View style={styles.authContainer}>
      {/* Green dollar bills floating around */}
      <AnimatedBackground 
        particleCount={40}  /* Increased for more bills */
        iconTypes={['cash']} /* Only using cash/money icons */
        includeCoins={true}
        opacity={0.85} /* Higher opacity to make them more visible */
        speed={1.2}  /* Faster animation */
        startPosition="random" /* Random positioning for movement in all directions */
      />
      
      <Animated.View 
        style={[
          styles.logoContainer, 
          { opacity: fadeAnim, transform: [{ translateY: slideAnim }] }
        ]}
      >
        <Image 
          source={require('../../assets/peglogored.png')} 
          style={styles.logo}
          resizeMode="contain"
        />
        <Text style={styles.tagline}>Your Passport to Local Rewards</Text>
      </Animated.View>
      
      <Animated.View 
        style={[
          styles.authFormContainer,
          { opacity: fadeAnim, transform: [{ translateY: slideAnim }] }
        ]}
      >
        <Text style={styles.authTitle}>Join Peg Plug</Text>
        
        <View style={styles.buttonContainer}>
          <TouchableOpacity 
            style={styles.authButton}
            onPress={() => {/* Do nothing for now */}}
          >
            <Ionicons name="person-add-outline" size={20} color={colors.primary.white} />
            <Text style={styles.authButtonText}>Create Account</Text>
          </TouchableOpacity>
          
          <TouchableOpacity 
            style={styles.authAltButton}
            onPress={() => navigation.navigate('Login')}
          >
            <Text style={styles.authAltButtonText}>Back to Login</Text>
          </TouchableOpacity>
        </View>
      </Animated.View>
    </View>
  );
};

// Placeholder screen for Redemptions
const RedemptionsScreen = () => (
  <View style={styles.placeholderContainer}>
    <Ionicons name="receipt" size={50} color={colors.text.tertiary} />
    <Text style={styles.placeholderText}>Redemptions Coming Soon</Text>
  </View>
);

// Placeholder screen for Map
const FullMapScreen = () => (
  <View style={styles.placeholderContainer}>
    <Ionicons name="map" size={50} color={colors.text.tertiary} />
    <Text style={styles.placeholderText}>Map View Coming Soon</Text>
  </View>
);

// Deal Detail Screen
const DealDetailScreen = ({ route }) => {
  const { dealId } = route.params || {};
  
  return (
    <View style={styles.placeholderContainer}>
      <Text style={styles.titleText}>Deal Details</Text>
      <Text style={styles.subtitleText}>Deal ID: {dealId}</Text>
      <Text style={styles.placeholderText}>Deal details coming soon</Text>
    </View>
  );
};

// Create navigators
const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

// Home stack navigator
const HomeStack = () => {
  return (
    <Stack.Navigator>
      <Stack.Screen 
        name="HomeScreen" 
        component={HomeScreen} 
        options={{ headerShown: false }}
      />
      <Stack.Screen 
        name="SpinDeal" 
        component={SpinDealScreen} 
        options={{ 
          headerShown: false,
        }}
      />
      <Stack.Screen 
        name="SlotMachine" 
        component={SlotMachineScreen} 
        options={{ 
          title: 'Spin & Win',
          headerTintColor: colors.primary.white,
          headerStyle: {
            backgroundColor: colors.primary.red,
          },
        }}
      />
      <Stack.Screen 
        name="FullMap" 
        component={FullMapScreen} 
        options={{ 
          title: 'Pegs Near Me',
          headerTintColor: colors.primary.white,
          headerStyle: {
            backgroundColor: colors.primary.red,
          },
        }}
      />
      <Stack.Screen 
        name="DealDetail" 
        component={DealDetailScreen} 
        options={{ 
          title: 'Deal Details',
          headerTintColor: colors.primary.white,
          headerStyle: {
            backgroundColor: colors.secondary.blue,
          },
        }}
      />
    </Stack.Navigator>
  );
};

// Deals stack navigator
const DealsStack = () => {
  return (
    <Stack.Navigator>
      <Stack.Screen 
        name="DealsScreen" 
        component={DealsScreen} 
        options={{ headerShown: false }}
      />
      <Stack.Screen 
        name="SpinDeal" 
        component={SpinDealScreen} 
        options={{ 
          headerShown: false,
        }}
      />
      <Stack.Screen 
        name="DealDetail" 
        component={DealDetailScreen} 
        options={{ 
          title: 'Deal Details',
          headerTintColor: colors.primary.white,
          headerStyle: {
            backgroundColor: colors.secondary.blue,
          },
        }}
      />
    </Stack.Navigator>
  );
};

// Tab navigator for main app
const AppTabNavigator = () => {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarIcon: ({ focused, color, size }) => {
          let iconName;
          
          if (route.name === 'Home') {
            iconName = focused ? 'home' : 'home-outline';
          } else if (route.name === 'Deals') {
            iconName = focused ? 'pricetag' : 'pricetag-outline';
          } else if (route.name === 'Redemptions') {
            iconName = focused ? 'receipt' : 'receipt-outline';
          } else if (route.name === 'Profile') {
            iconName = focused ? 'person' : 'person-outline';
          }
          
          return <Ionicons name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: colors.primary.red,
        tabBarInactiveTintColor: 'gray',
        tabBarStyle: {
          paddingBottom: 5,
          paddingTop: 5,
        },
      })}
    >
      <Tab.Screen name="Home" component={HomeStack} />
      <Tab.Screen name="Deals" component={DealsStack} />
      <Tab.Screen name="Redemptions" component={RedemptionsScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
};

// Login/Register stack
const AuthStack = () => {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Login" component={LoginScreen} />
      <Stack.Screen name="Signup" component={SignupScreen} />
    </Stack.Navigator>
  );
};

// Main navigation container
const Navigation = () => {
  const { user, loading } = useAuth();
  
  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <Text>Loading...</Text>
      </View>
    );
  }
  
  return (
    <NavigationContainer>
      {user ? <AppTabNavigator /> : <AuthStack />}
    </NavigationContainer>
  );
};

const styles = StyleSheet.create({
  authContainer: {
    flex: 1,
    backgroundColor: colors.ui.background,
    paddingHorizontal: spacing.lg,
    justifyContent: 'center',
    position: 'relative',
    zIndex: 1,
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: spacing.xl,
    zIndex: 5,
  },
  logo: {
    width: 120,
    height: 120,
    marginBottom: spacing.md,
  },
  tagline: {
    fontSize: typography.fontSize.md,
    color: colors.text.secondary,
    fontWeight: typography.fontWeight.medium,
    textAlign: 'center',
    letterSpacing: 0.5,
    marginTop: spacing.xs,
    textShadow: '1px 1px 2px rgba(0, 0, 0, 0.1)',
  },
  authFormContainer: {
    backgroundColor: colors.ui.card,
    borderRadius: spacing.borderRadius.lg,
    padding: spacing.lg,
    width: '100%',
    zIndex: 5,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.1,
        shadowRadius: 10,
      },
      android: {
        elevation: 4,
      },
    }),
  },
  authTitle: {
    fontSize: typography.fontSize.xl,
    fontWeight: typography.fontWeight.bold,
    color: colors.text.primary,
    marginBottom: spacing.md,
    textAlign: 'center',
    letterSpacing: 0.5,
  },
  authSubtitle: {
    fontSize: typography.fontSize.lg,
    fontWeight: typography.fontWeight.bold,
    color: colors.text.primary,
    marginBottom: spacing.md,
    letterSpacing: 0.5,
  },
  buttonContainer: {
    marginTop: spacing.md,
  },
  infoText: {
    fontSize: typography.fontSize.sm,
    color: colors.text.tertiary,
    textAlign: 'center',
    marginBottom: spacing.md,
  },
  authButton: {
    backgroundColor: colors.primary.red,
    paddingVertical: spacing.md,
    borderRadius: spacing.borderRadius.lg,
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: spacing.sm,
    flexDirection: 'row',
    ...spacing.shadow.small,
  },
  authButtonDisabled: {
    backgroundColor: colors.ui.disabled,
  },
  authButtonText: {
    color: colors.primary.white,
    fontSize: typography.fontSize.md,
    fontWeight: typography.fontWeight.bold,
    letterSpacing: 0.5,
    marginLeft: spacing.xs,
  },
  authAltButton: {
    paddingVertical: spacing.md,
    alignItems: 'center',
  },
  authAltButtonText: {
    color: colors.secondary.blue,
    fontSize: typography.fontSize.md,
    fontWeight: typography.fontWeight.medium,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  placeholderContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  titleText: {
    fontSize: 22,
    fontWeight: 'bold',
    marginBottom: 10,
    color: colors.text.primary,
  },
  subtitleText: {
    fontSize: 16,
    marginBottom: 20,
    color: colors.text.secondary,
  },
  placeholderText: {
    fontSize: 16,
    color: colors.text.tertiary,
    textAlign: 'center',
    marginTop: 20,
  },
});

export default Navigation; 