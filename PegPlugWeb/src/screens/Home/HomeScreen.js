import React, { useRef, useEffect } from 'react';
import { 
  StyleSheet, 
  View, 
  Text, 
  ScrollView, 
  TouchableOpacity,
  Image,
  Animated,
  Easing,
  Platform
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { colors, typography, spacing } from '../../theme';
import { useAuth } from '../../services/AuthContext';
import { useLocation } from '../../services/LocationService';
import AnimatedBackground from '../../components/Background/AnimatedBackground';

const HomeScreen = ({ navigation }) => {
  const { user } = useAuth();
  const { location } = useLocation();
  
  // Animation values
  const spinAnimation = useRef(new Animated.Value(0)).current;
  const fadeInAnimation = useRef(new Animated.Value(0)).current;

  // Animation effects
  useEffect(() => {
    // Start animations when component mounts
    Animated.parallel([
      // Spin animation for the spin card icon
      Animated.loop(
        Animated.timing(spinAnimation, {
          toValue: 1,
          duration: 10000,
          easing: Easing.linear,
          useNativeDriver: true,
        })
      ),
      // Fade in animation for content
      Animated.timing(fadeInAnimation, {
        toValue: 1,
        duration: 800,
        useNativeDriver: true,
      })
    ]).start();
  }, []);

  // Rotation interpolation for spin animation
  const spin = spinAnimation.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg']
  });
  
  const handleProfilePress = () => {
    navigation.navigate('Profile');
  };
  
  const handleDealsPress = () => {
    navigation.navigate('Deals');
  };
  
  const handleSpinPress = () => {
    navigation.navigate('SpinDeal');
  };
  
  const handleMapPress = () => {
    navigation.navigate('FullMap');
  };
  
  return (
    <SafeAreaView style={styles.container}>
      {/* Animated background with icons */}
      <AnimatedBackground 
        particleCount={12}
        iconTypes={['gift', 'pricetag', 'cash', 'ticket']}
        opacity={0.2}
      />
      
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          <Image 
            source={require('../../../assets/peglogored.png')} 
            style={styles.headerLogo}
            resizeMode="contain"
          />
        </View>
        
        <TouchableOpacity style={styles.profileButton} onPress={handleProfilePress}>
          <View style={styles.profileIcon}>
            <Ionicons name="person" size={20} color={colors.primary.white} />
          </View>
        </TouchableOpacity>
      </View>
      
      <ScrollView contentContainerStyle={styles.content}>
        <Animated.Text 
          style={[
            styles.welcomeText,
            { opacity: fadeInAnimation }
          ]}
        >
          Welcome back, {user?.displayName?.split(' ')[0] || 'User'}!
        </Animated.Text>
        
        {/* Main Action Button - Spin */}
        <View style={styles.spinCard}>
          <TouchableOpacity 
            style={styles.spinCardContent}
            onPress={handleSpinPress}
            activeOpacity={0.9}
          >
            <Animated.View
              style={{ 
                transform: [{ rotate: spin }],
                alignItems: 'center',
                justifyContent: 'center',
                marginBottom: spacing.sm
              }}
            >
              <Ionicons name="aperture" size={50} color={colors.primary.white} />
            </Animated.View>
            <Text style={styles.spinCardTitle}>Spin & Win</Text>
            <Text style={styles.spinCardSubtitle}>Tap to spin for rewards</Text>
          </TouchableOpacity>
        </View>
        
        {/* Quick Actions */}
        <Animated.View 
          style={[
            styles.quickActionsContainer,
            { opacity: fadeInAnimation, transform: [{ translateY: fadeInAnimation.interpolate({
              inputRange: [0, 1],
              outputRange: [20, 0]
            })}] }
          ]}
        >
          <TouchableOpacity 
            style={styles.quickActionCard}
            onPress={handleMapPress}
          >
            <Ionicons name="map" size={30} color={colors.secondary.blue} />
            <Text style={styles.quickActionText}>Find Pegs</Text>
          </TouchableOpacity>
          
          <TouchableOpacity 
            style={styles.quickActionCard}
            onPress={handleDealsPress}
          >
            <Ionicons name="pricetag" size={30} color={colors.secondary.blue} />
            <Text style={styles.quickActionText}>View Deals</Text>
          </TouchableOpacity>
        </Animated.View>
        
        {/* Placeholder for ActivePegsSection */}
        <Animated.View 
          style={[
            styles.sectionContainer,
            { opacity: fadeInAnimation, transform: [{ translateY: fadeInAnimation.interpolate({
              inputRange: [0, 1],
              outputRange: [40, 0]
            })}] }
          ]}
        >
          <Text style={styles.sectionTitle}>Pegs Near You</Text>
          <View style={styles.placeholderCard}>
            <Text style={styles.placeholderText}>This will show nearby merchant locations</Text>
          </View>
        </Animated.View>
        
        {/* Placeholder for ActivePlugsSection */}
        <Animated.View 
          style={[
            styles.sectionContainer,
            { opacity: fadeInAnimation, transform: [{ translateY: fadeInAnimation.interpolate({
              inputRange: [0, 1],
              outputRange: [60, 0]
            })}] }
          ]}
        >
          <Text style={styles.sectionTitle}>Your Active Plugs</Text>
          <View style={styles.placeholderCard}>
            <Text style={styles.placeholderText}>This will show your active rewards</Text>
          </View>
        </Animated.View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.ui.background,
    position: 'relative', // Important for positioning children
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.ui.border,
    zIndex: 2, // Keep header above animated background
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  headerLogo: {
    width: 36,
    height: 36,
  },
  profileButton: {
    width: 40,
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
  },
  profileIcon: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: colors.primary.red,
    justifyContent: 'center',
    alignItems: 'center',
    ...spacing.shadow.medium,
  },
  content: {
    padding: spacing.md,
    paddingBottom: spacing.xxl,
    zIndex: 2, // Keep content above animated background
  },
  welcomeText: {
    fontSize: typography.fontSize.xl,
    fontWeight: typography.fontWeight.bold,
    color: colors.text.primary,
    marginVertical: spacing.md,
    textShadow: '1px 1px 2px rgba(0, 0, 0, 0.1)',
  },
  spinCard: {
    backgroundColor: colors.primary.red,
    borderRadius: spacing.borderRadius.lg,
    padding: spacing.lg,
    marginVertical: spacing.md,
    overflow: 'hidden',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 8,
      },
      android: {
        elevation: 6,
      },
    }),
  },
  spinCardContent: {
    alignItems: 'center',
  },
  spinCardTitle: {
    fontSize: typography.fontSize.xxl,
    fontWeight: typography.fontWeight.bold,
    color: colors.primary.white,
    marginTop: spacing.md,
    letterSpacing: 1,
    textShadow: '1px 1px 2px rgba(0, 0, 0, 0.3)',
  },
  spinCardSubtitle: {
    fontSize: typography.fontSize.md,
    color: colors.primary.white,
    opacity: 0.9,
    marginTop: spacing.xs,
  },
  quickActionsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginVertical: spacing.md,
  },
  quickActionCard: {
    flex: 1,
    alignItems: 'center',
    backgroundColor: colors.ui.card,
    borderRadius: spacing.borderRadius.lg,
    padding: spacing.md,
    marginHorizontal: spacing.xs,
    ...spacing.shadow.small,
  },
  quickActionText: {
    fontSize: typography.fontSize.sm,
    fontWeight: typography.fontWeight.medium,
    color: colors.text.primary,
    marginTop: spacing.sm,
  },
  sectionContainer: {
    marginTop: spacing.lg,
  },
  sectionTitle: {
    fontSize: typography.fontSize.lg,
    fontWeight: typography.fontWeight.bold,
    color: colors.text.primary,
    marginBottom: spacing.sm,
    letterSpacing: 0.5,
  },
  placeholderCard: {
    backgroundColor: colors.ui.card,
    borderRadius: spacing.borderRadius.lg,
    padding: spacing.md,
    alignItems: 'center',
    justifyContent: 'center',
    height: 120,
    ...spacing.shadow.small,
  },
  placeholderText: {
    fontSize: typography.fontSize.md,
    color: colors.text.tertiary,
    textAlign: 'center',
  },
});

export default HomeScreen; 