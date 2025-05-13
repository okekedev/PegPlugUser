import React, { useState, useRef, useEffect } from 'react';
import {
  StyleSheet,
  View,
  Text,
  FlatList,
  TouchableOpacity,
  Image,
  Animated,
  Dimensions,
  Platform
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { colors, typography, spacing } from '../../theme';
import AnimatedBackground from '../../components/Background/AnimatedBackground';

const { width } = Dimensions.get('window');

// Enhanced mock deals with better categorization
const MOCK_DEALS = [
  {
    id: '1',
    title: 'Coffee Shop Deal',
    description: '20% off any coffee purchase',
    location: 'Downtown Coffee',
    distance: '0.3 mi',
    expiresIn: '3 days',
    type: 'food',
    isFeatured: true,
    imageIcon: 'cafe',
  },
  {
    id: '2',
    title: 'Bakery Special',
    description: 'Buy one pastry, get one free',
    location: 'City Bakery',
    distance: '0.5 mi',
    expiresIn: '5 days',
    type: 'food',
    isFeatured: false,
    imageIcon: 'pizza',
  },
  {
    id: '3',
    title: 'Tech Discount',
    description: '15% off all accessories',
    location: 'Tech Store',
    distance: '1.2 mi',
    expiresIn: '7 days',
    type: 'shopping',
    isFeatured: true,
    imageIcon: 'phone-portrait',
  },
  {
    id: '4',
    title: 'Gym Membership',
    description: '50% off first month',
    location: 'Fitness Center',
    distance: '0.8 mi',
    expiresIn: '10 days',
    type: 'fitness',
    isFeatured: false,
    imageIcon: 'fitness',
  },
  {
    id: '5',
    title: 'Book Store Sale',
    description: 'Buy 2 books, get 1 free',
    location: 'City Books',
    distance: '1.5 mi',
    expiresIn: '2 days',
    type: 'shopping',
    isFeatured: false,
    imageIcon: 'book',
  },
  {
    id: '6',
    title: 'Restaurant Deal',
    description: 'Free appetizer with any main course',
    location: 'Gourmet Bistro',
    distance: '0.9 mi',
    expiresIn: '4 days',
    type: 'food',
    isFeatured: true,
    imageIcon: 'restaurant',
  },
  {
    id: '7',
    title: 'Hotel Discount',
    description: '25% off weekend stays',
    location: 'Luxury Hotel',
    distance: '1.7 mi',
    expiresIn: '8 days',
    type: 'travel',
    isFeatured: true,
    imageIcon: 'bed',
  },
  {
    id: '8',
    title: 'Spa Special',
    description: 'Complimentary massage upgrade',
    location: 'Wellness Spa',
    distance: '1.1 mi',
    expiresIn: '6 days',
    type: 'wellness',
    isFeatured: false,
    imageIcon: 'flower',
  },
];

const DealsScreen = ({ navigation, route }) => {
  const [selectedFilter, setSelectedFilter] = useState('all');
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const scrollY = useRef(new Animated.Value(0)).current;
  const [showWonDealToast, setShowWonDealToast] = useState(false);
  const [wonDealDetails, setWonDealDetails] = useState(null);
  
  // Check if we received a won deal from SpinDealScreen
  useEffect(() => {
    if (route.params?.dealWon && route.params?.dealDetails) {
      setWonDealDetails(route.params.dealDetails);
      setShowWonDealToast(true);
      
      // Hide toast after 5 seconds
      const timer = setTimeout(() => {
        setShowWonDealToast(false);
      }, 5000);
      
      return () => clearTimeout(timer);
    }
  }, [route.params]);
  
  // Filter options with improved organization
  const filterOptions = [
    { id: 'all', label: 'All', icon: 'grid' },
    { id: 'featured', label: 'Featured', icon: 'star' },
    { id: 'food', label: 'Food', icon: 'restaurant' },
    { id: 'shopping', label: 'Shopping', icon: 'cart' },
    { id: 'fitness', label: 'Fitness', icon: 'fitness' },
    { id: 'travel', label: 'Travel', icon: 'airplane' },
    { id: 'wellness', label: 'Wellness', icon: 'flower' },
  ];
  
  // Animate content when component mounts
  useEffect(() => {
    Animated.timing(fadeAnim, {
      toValue: 1,
      duration: 500,
      useNativeDriver: true,
    }).start();
  }, []);
  
  // Filter deals based on selection
  const filteredDeals = MOCK_DEALS.filter(deal => {
    if (selectedFilter === 'all') return true;
    if (selectedFilter === 'featured') return deal.isFeatured;
    return deal.type === selectedFilter;
  });
  
  const handleDealPress = (dealId) => {
    navigation.navigate('DealDetail', { dealId });
  };
  
  // Navigate to spin deal screen
  const handleSpinAndWin = () => {
    navigation.navigate('SpinDeal');
  };
  
  // Header shadow based on scroll position
  const headerShadow = scrollY.interpolate({
    inputRange: [0, 20],
    outputRange: [0, 0.2],
    extrapolate: 'clamp',
  });
  
  // Render individual deal card
  const renderDealItem = ({ item }) => (
    <TouchableOpacity 
      style={styles.dealCard}
      onPress={() => handleDealPress(item.id)}
      activeOpacity={0.8}
    >
      <View style={styles.dealCardContent}>
        <View style={styles.dealIconContainer}>
          <Ionicons name={item.imageIcon} size={32} color={colors.primary.red} />
        </View>
        
        <View style={styles.dealTextContainer}>
          <Text style={styles.dealTitle}>{item.title}</Text>
          <Text style={styles.dealDescription}>{item.description}</Text>
          
          <View style={styles.dealInfoContainer}>
            <View style={styles.dealInfoItem}>
              <Ionicons name="location" size={14} color={colors.secondary.blue} />
              <Text style={styles.dealInfoText}>{item.location}</Text>
            </View>
            
            <View style={styles.dealInfoItem}>
              <Ionicons name="navigate" size={14} color={colors.secondary.blue} />
              <Text style={styles.dealInfoText}>{item.distance}</Text>
            </View>
            
            <View style={styles.dealInfoItem}>
              <Ionicons name="time" size={14} color={colors.secondary.blue} />
              <Text style={styles.dealInfoText}>Expires in {item.expiresIn}</Text>
            </View>
          </View>
        </View>
        
        {item.isFeatured && (
          <View style={styles.featuredBadge}>
            <Ionicons name="star" size={14} color={colors.primary.white} />
          </View>
        )}
      </View>
    </TouchableOpacity>
  );
  
  // Render the Spin & Win banner
  const renderSpinBanner = () => (
    <TouchableOpacity
      style={styles.spinBanner}
      onPress={handleSpinAndWin}
      activeOpacity={0.9}
    >
      <View style={styles.spinBannerContent}>
        <Ionicons name="trophy" size={28} color="#FFD700" />
        <View style={styles.spinBannerTextContainer}>
          <Text style={styles.spinBannerTitle}>Spin & Win</Text>
          <Text style={styles.spinBannerSubtitle}>
            Spin twice for exclusive deals - guaranteed win!
          </Text>
        </View>
        <Ionicons name="chevron-forward" size={22} color={colors.primary.white} />
      </View>
    </TouchableOpacity>
  );
  
  // Header component for the FlatList
  const ListHeaderComponent = () => (
    <>
      {/* Spin & Win Banner */}
      {renderSpinBanner()}
      
      {/* Display won deal toast */}
      {showWonDealToast && wonDealDetails && (
        <View style={styles.dealWonToast}>
          <Ionicons name="checkmark-circle" size={24} color="#4CAF50" />
          <View style={styles.dealWonToastTextContainer}>
            <Text style={styles.dealWonToastTitle}>
              Deal Unlocked: {wonDealDetails.text}
            </Text>
            <Text style={styles.dealWonToastSubtitle}>
              {wonDealDetails.description}
            </Text>
          </View>
        </View>
      )}
    </>
  );
  
  return (
    <SafeAreaView style={styles.container}>
      {/* Subtle animated background */}
      <AnimatedBackground 
        particleCount={10}
        iconTypes={['restaurant', 'cafe', 'cart', 'gift', 'ticket']}
        includeCoins={false}
        opacity={0.1}
        speed={0.6}
      />
      
      {/* Header */}
      <Animated.View 
        style={[
          styles.header,
          {
            shadowOpacity: headerShadow,
            zIndex: 10
          }
        ]}
      >
        <Image 
          source={require('../../../assets/peglogored.png')} 
          style={styles.headerLogo}
          resizeMode="contain"
        />
        <Text style={styles.headerTitle}>Deals</Text>
      </Animated.View>
      
      {/* Filter tabs */}
      <View style={styles.filterContainer}>
        <FlatList
          horizontal
          data={filterOptions}
          keyExtractor={(item) => item.id}
          showsHorizontalScrollIndicator={false}
          renderItem={({ item }) => (
            <TouchableOpacity
              style={[
                styles.filterButton,
                selectedFilter === item.id && styles.filterButtonActive,
              ]}
              onPress={() => setSelectedFilter(item.id)}
            >
              <Ionicons 
                name={item.icon} 
                size={16} 
                color={selectedFilter === item.id ? colors.primary.white : colors.text.primary} 
              />
              <Text
                style={[
                  styles.filterText,
                  selectedFilter === item.id && styles.filterTextActive,
                ]}
              >
                {item.label}
              </Text>
            </TouchableOpacity>
          )}
          contentContainerStyle={styles.filterList}
        />
      </View>
      
      {/* Deals listing */}
      <Animated.FlatList
        data={filteredDeals}
        keyExtractor={(item) => item.id}
        renderItem={renderDealItem}
        contentContainerStyle={styles.dealsList}
        showsVerticalScrollIndicator={false}
        initialNumToRender={5}
        maxToRenderPerBatch={10}
        windowSize={10}
        onScroll={Animated.event(
          [{ nativeEvent: { contentOffset: { y: scrollY } } }],
          { useNativeDriver: false }
        )}
        scrollEventThrottle={16}
        style={{ opacity: fadeAnim }}
        ListHeaderComponent={ListHeaderComponent}
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Ionicons name="sad" size={50} color={colors.text.tertiary} />
            <Text style={styles.emptyText}>No deals found</Text>
          </View>
        }
        // Important: add extra padding at bottom to prevent overlap with tab bar
        ListFooterComponent={<View style={{ height: 100 }} />}
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.ui.background,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'center',
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
        shadowRadius: 5,
      },
      android: {
        elevation: 4,
      },
    }),
  },
  headerLogo: {
    width: 30,
    height: 30,
    marginRight: spacing.xs,
  },
  headerTitle: {
    fontSize: typography.fontSize.lg,
    fontWeight: typography.fontWeight.bold,
    color: colors.text.primary,
    letterSpacing: 0.5,
    marginLeft: spacing.xs,
    textShadow: '1px 1px 2px rgba(0, 0, 0, 0.1)',
  },
  filterContainer: {
    paddingVertical: spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: colors.ui.border,
    backgroundColor: colors.ui.background,
    zIndex: 5,
  },
  filterList: {
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
  },
  filterButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.xs,
    paddingHorizontal: spacing.md,
    borderRadius: spacing.borderRadius.pill,
    backgroundColor: colors.ui.card,
    marginRight: spacing.sm,
    ...spacing.shadow.small,
  },
  filterButtonActive: {
    backgroundColor: colors.primary.red,
  },
  filterText: {
    fontSize: typography.fontSize.sm,
    fontWeight: typography.fontWeight.medium,
    color: colors.text.primary,
    marginLeft: spacing.xs,
  },
  filterTextActive: {
    color: colors.primary.white,
  },
  dealsList: {
    padding: spacing.md,
  },
  dealCard: {
    backgroundColor: colors.ui.card,
    borderRadius: spacing.borderRadius.lg,
    marginBottom: spacing.md,
    overflow: 'hidden',
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
  dealCardContent: {
    flexDirection: 'row',
    padding: spacing.md,
  },
  dealIconContainer: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: 'rgba(255,99,99,0.1)',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.md,
  },
  dealTextContainer: {
    flex: 1,
  },
  dealTitle: {
    fontSize: typography.fontSize.md,
    fontWeight: typography.fontWeight.bold,
    color: colors.text.primary,
    marginBottom: spacing.xs,
    letterSpacing: 0.5,
  },
  dealDescription: {
    fontSize: typography.fontSize.sm,
    color: colors.text.secondary,
    marginBottom: spacing.sm,
  },
  dealInfoContainer: {
    flexDirection: 'column',
  },
  dealInfoItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.xs,
  },
  dealInfoText: {
    fontSize: typography.fontSize.xs,
    color: colors.text.tertiary,
    marginLeft: spacing.xs,
  },
  featuredBadge: {
    position: 'absolute',
    top: spacing.xs,
    right: spacing.xs,
    backgroundColor: colors.secondary.blue,
    borderRadius: 12,
    width: 24,
    height: 24,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: spacing.xl,
  },
  emptyText: {
    fontSize: typography.fontSize.md,
    color: colors.text.tertiary,
    marginTop: spacing.md,
  },
  spinBanner: {
    backgroundColor: colors.primary.red,
    borderRadius: spacing.borderRadius.lg,
    marginBottom: spacing.md,
    overflow: 'hidden',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 3 },
        shadowOpacity: 0.2,
        shadowRadius: 5,
      },
      android: {
        elevation: 4,
      },
    }),
  },
  spinBannerContent: {
    flexDirection: 'row',
    padding: spacing.md,
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  spinBannerTextContainer: {
    flex: 1,
    marginLeft: spacing.md,
  },
  spinBannerTitle: {
    fontSize: typography.fontSize.md,
    fontWeight: typography.fontWeight.bold,
    color: colors.primary.white,
    marginBottom: 2,
  },
  spinBannerSubtitle: {
    fontSize: typography.fontSize.sm,
    color: 'rgba(255, 255, 255, 0.8)',
  },
  dealWonToast: {
    backgroundColor: colors.ui.card,
    borderRadius: spacing.borderRadius.md,
    marginBottom: spacing.md,
    padding: spacing.md,
    flexDirection: 'row',
    alignItems: 'center',
    borderLeftWidth: 4,
    borderLeftColor: '#4CAF50',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 3,
      },
      android: {
        elevation: 2,
      },
    }),
  },
  dealWonToastTextContainer: {
    flex: 1,
    marginLeft: spacing.sm,
  },
  dealWonToastTitle: {
    fontSize: typography.fontSize.sm,
    fontWeight: typography.fontWeight.bold,
    color: colors.text.primary,
    marginBottom: 2,
  },
  dealWonToastSubtitle: {
    fontSize: typography.fontSize.xs,
    color: colors.text.secondary,
  },
});

export default DealsScreen; 