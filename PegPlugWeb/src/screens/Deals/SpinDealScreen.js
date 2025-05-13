import React, { useState, useEffect } from 'react';
import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  Platform,
  StatusBar,
  Image,
  ScrollView,
  Dimensions,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import EnhancedLuckyWheel from '../../components/Wheel/EnhancedLuckyWheel';
import AnimatedBackground from '../../components/Background/AnimatedBackground';
import { colors, typography, spacing } from '../../theme';

const { width } = Dimensions.get('window');

// Mock deals to win
const SPIN_DEALS = [
  {
    id: '1',
    text: '50% OFF',
    description: 'Get 50% off on any purchase',
    isJackpot: true,
    color: '#FFD700', // Gold color for the jackpot
  },
  {
    id: '2',
    text: '10% OFF',
    description: 'Get 10% off on your next order',
    isJackpot: false,
    color: '#E43E33', // Red
  },
  {
    id: '3',
    text: 'FREE ITEM',
    description: 'Get a free item with any purchase',
    isJackpot: false,
    color: '#3C76F2', // Blue
  },
  {
    id: '4',
    text: '25% OFF',
    description: 'Get 25% off on selected items',
    isJackpot: false,
    color: '#4CAF50', // Green
  },
  {
    id: '5',
    text: '$5 OFF',
    description: '$5 off on orders above $20',
    isJackpot: false,
    color: '#9C27B0', // Purple
  },
  {
    id: '6',
    text: 'FREE SHIP',
    description: 'Free shipping on your next order',
    isJackpot: false,
    color: '#FF9800', // Orange
  },
];

const SpinDealScreen = ({ navigation, route }) => {
  // State
  const [currentDeal, setCurrentDeal] = useState(null);
  const [hasWon, setHasWon] = useState(false);
  const [spinsLeft, setSpinsLeft] = useState(2);
  
  // Handle wheel spin completion
  const handleSpinComplete = (winner, index) => {
    setCurrentDeal(winner);
    
    // Set hasWon if they won a prize
    if (winner.isJackpot) {
      setHasWon(true);
    }
    
    // Decrement spins left
    setSpinsLeft(prev => Math.max(0, prev - 1));
  };
  
  // Go back to deals screen
  const handleGoBack = () => {
    navigation.goBack();
  };
  
  // Get deal from won spin
  const handleRedeemDeal = () => {
    // Here we would normally handle the redemption logic
    // For now, just navigate back to deals with a success message
    navigation.navigate('Deals', { 
      dealWon: true,
      dealDetails: currentDeal
    });
  };
  
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />
      
      {/* Animated background with appropriate icons */}
      <AnimatedBackground 
        particleCount={15}
        iconTypes={['gift', 'cash', 'pricetag', 'star']}
        includeCoins={true}
        opacity={0.15}
        speed={0.8}
      />
      
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={handleGoBack}
        >
          <Ionicons name="arrow-back" size={24} color={colors.text.primary} />
        </TouchableOpacity>
        
        <Text style={styles.headerTitle}>Spin & Win</Text>
        
        <View style={styles.headerRight} />
      </View>
      
      <ScrollView 
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Intro text */}
        <View style={styles.introContainer}>
          <Text style={styles.titleText}>Spin The Wheel</Text>
          <Text style={styles.subtitleText}>
            Spin to win amazing prizes! You have {spinsLeft} spins remaining.
          </Text>
        </View>
        
        {/* Spinning wheel */}
        <View style={styles.wheelContainer}>
          <EnhancedLuckyWheel
            segments={SPIN_DEALS}
            size={Math.min(width * 0.9, 350)}
            primaryColor={colors.primary.red}
            textColor={colors.primary.white}
            duration={5000}
            onFinish={handleSpinComplete}
          />
        </View>
        
        {/* Current deal info */}
        {currentDeal && (
          <View style={styles.dealInfoContainer}>
            <Text style={styles.dealTitle}>
              {hasWon ? 'You Won!' : 'Spun:'}
            </Text>
            
            <View style={[
              styles.dealCard,
              hasWon && styles.winningDealCard
            ]}>
              <View style={[
                styles.dealIconContainer,
                { backgroundColor: currentDeal.color + '20' }
              ]}>
                <Ionicons 
                  name={hasWon ? "trophy" : "pricetag"} 
                  size={32} 
                  color={currentDeal.color} 
                />
              </View>
              
              <View style={styles.dealTextContainer}>
                <Text style={styles.dealText}>{currentDeal.text}</Text>
                <Text style={styles.dealDescription}>
                  {currentDeal.description}
                </Text>
              </View>
            </View>
            
            {hasWon && (
              <TouchableOpacity 
                style={styles.redeemButton}
                onPress={handleRedeemDeal}
              >
                <Text style={styles.redeemButtonText}>Redeem Your Prize</Text>
                <Ionicons name="arrow-forward" size={18} color="white" />
              </TouchableOpacity>
            )}
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.ui.background,
  },
  scrollContent: {
    flexGrow: 1,
    paddingBottom: 40,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.ui.border,
    backgroundColor: colors.ui.background,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 3,
      },
      android: {
        elevation: 3,
      },
    }),
  },
  backButton: {
    padding: spacing.xs,
  },
  headerTitle: {
    fontSize: typography.fontSize.lg,
    fontWeight: typography.fontWeight.bold,
    color: colors.text.primary,
  },
  headerRight: {
    width: 32, // Same size as back button for balance
  },
  introContainer: {
    paddingHorizontal: spacing.lg,
    marginTop: spacing.md,
    marginBottom: spacing.md,
    alignItems: 'center',
  },
  titleText: {
    fontSize: typography.fontSize.xl,
    fontWeight: typography.fontWeight.bold,
    color: colors.text.primary,
    marginBottom: spacing.xs,
    textAlign: 'center',
  },
  subtitleText: {
    fontSize: typography.fontSize.sm,
    color: colors.text.secondary,
    textAlign: 'center',
    marginBottom: spacing.md,
  },
  wheelContainer: {
    alignItems: 'center',
    marginVertical: spacing.lg,
  },
  dealInfoContainer: {
    paddingHorizontal: spacing.lg,
    marginTop: spacing.md,
    alignItems: 'center',
  },
  dealTitle: {
    fontSize: typography.fontSize.lg,
    fontWeight: typography.fontWeight.bold,
    color: colors.text.primary,
    marginBottom: spacing.md,
  },
  dealCard: {
    backgroundColor: colors.ui.card,
    width: '100%',
    borderRadius: spacing.borderRadius.lg,
    padding: spacing.md,
    flexDirection: 'row',
    alignItems: 'center',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
      },
      android: {
        elevation: 3,
      },
    }),
  },
  winningDealCard: {
    borderWidth: 2,
    borderColor: '#FFD700',
    backgroundColor: 'rgba(255, 215, 0, 0.05)',
  },
  dealIconContainer: {
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.md,
  },
  dealTextContainer: {
    flex: 1,
  },
  dealText: {
    fontSize: typography.fontSize.lg,
    fontWeight: typography.fontWeight.bold,
    color: colors.text.primary,
    marginBottom: spacing.xs,
  },
  dealDescription: {
    fontSize: typography.fontSize.sm,
    color: colors.text.secondary,
  },
  redeemButton: {
    backgroundColor: colors.primary.red,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.lg,
    borderRadius: spacing.borderRadius.pill,
    marginTop: spacing.lg,
    flexDirection: 'row',
    alignItems: 'center',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.2,
        shadowRadius: 3,
      },
      android: {
        elevation: 4,
      },
    }),
  },
  redeemButtonText: {
    color: colors.primary.white,
    fontWeight: typography.fontWeight.bold,
    fontSize: typography.fontSize.md,
    marginRight: spacing.xs,
  },
});

export default SpinDealScreen; 