import React, { createContext, useState, useContext, useEffect } from 'react';
import * as Location from 'expo-location';

// Create context
const LocationContext = createContext();

// Location provider component
export const LocationProvider = ({ children }) => {
  const [location, setLocation] = useState(null);
  const [errorMsg, setErrorMsg] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isPermissionGranted, setIsPermissionGranted] = useState(null);
  const [watchId, setWatchId] = useState(null);
  const [isWatching, setIsWatching] = useState(false);

  // Request location permission
  const requestLocationPermission = async () => {
    setLoading(true);
    
    try {
      const { status } = await Location.requestForegroundPermissionsAsync();
      setIsPermissionGranted(status === 'granted');
      
      if (status !== 'granted') {
        setErrorMsg('Permission to access location was denied');
        setLoading(false);
        return false;
      }
      
      // Get current location
      const currentLocation = await Location.getCurrentPositionAsync({});
      setLocation(currentLocation);
      setLoading(false);
      return true;
    } catch (error) {
      setErrorMsg(error.message);
      setLoading(false);
      return false;
    }
  };

  // Get current location
  const getCurrentLocation = async () => {
    try {
      if (!isPermissionGranted) {
        const permissionGranted = await requestLocationPermission();
        if (!permissionGranted) return null;
      }

      const currentLocation = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.High,
      });
      
      setLocation(currentLocation);
      return currentLocation;
    } catch (error) {
      setErrorMsg('Error getting current location: ' + error.message);
      return null;
    }
  };

  // Start watching location
  const startWatchingLocation = async () => {
    try {
      if (!isPermissionGranted) {
        const permissionGranted = await requestLocationPermission();
        if (!permissionGranted) return;
      }

      // Stop any existing watch first
      if (watchId) {
        await stopWatchingLocation();
      }

      // Start watching location
      const newWatchId = await Location.watchPositionAsync(
        {
          accuracy: Location.Accuracy.Balanced,
          distanceInterval: 10, // meters
          timeInterval: 5000,   // milliseconds
        },
        (newLocation) => {
          setLocation(newLocation);
        }
      );
      
      setWatchId(newWatchId);
      setIsWatching(true);
    } catch (error) {
      setErrorMsg('Error watching location: ' + error.message);
    }
  };

  // Stop watching location
  const stopWatchingLocation = async () => {
    if (watchId) {
      await watchId.remove();
      setWatchId(null);
      setIsWatching(false);
    }
  };

  // Calculate distance between two coordinates in kilometers
  const calculateDistance = (lat1, lon1, lat2, lon2) => {
    const R = 6371; // Radius of the earth in km
    const dLat = deg2rad(lat2 - lat1);
    const dLon = deg2rad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c; // Distance in km
    return distance;
  };

  const deg2rad = (deg) => {
    return deg * (Math.PI / 180);
  };

  // Request location permission with user prompt on component mount
  const requestLocationPermissionWithPrompt = async () => {
    if (isPermissionGranted === null) {
      await requestLocationPermission();
    }
  };

  // Initialize on mount
  useEffect(() => {
    requestLocationPermission();

    // Cleanup
    return () => {
      if (watchId) {
        stopWatchingLocation();
      }
    };
  }, []);

  // Get nearby locations based on radius (in meters)
  const getNearbyLocations = async (radius = 5000) => {
    if (!location) {
      await requestLocationPermission();
      if (!location) return [];
    }
    
    // This would normally fetch from a backend API or Firestore
    // For now, let's return mock data
    return [
      {
        id: '1',
        name: 'Downtown Coffee',
        description: 'Best coffee in town',
        location: {
          latitude: location.coords.latitude + 0.01,
          longitude: location.coords.longitude - 0.01,
        },
        type: 'peg', // or 'plug'
      },
      {
        id: '2',
        name: 'City Bakery',
        description: 'Fresh pastries daily',
        location: {
          latitude: location.coords.latitude - 0.005,
          longitude: location.coords.longitude + 0.008,
        },
        type: 'peg',
      },
      {
        id: '3',
        name: 'Tech Store',
        description: 'Latest gadgets',
        location: {
          latitude: location.coords.latitude + 0.003,
          longitude: location.coords.longitude + 0.003,
        },
        type: 'plug',
      },
    ];
  };

  const value = {
    location,
    errorMsg,
    loading,
    isPermissionGranted,
    isWatching,
    getCurrentLocation,
    startWatchingLocation,
    stopWatchingLocation,
    calculateDistance,
    requestLocationPermissionWithPrompt,
    getNearbyLocations,
  };

  return (
    <LocationContext.Provider value={value}>
      {children}
    </LocationContext.Provider>
  );
};

// Custom hook to use location context
export const useLocation = () => {
  const context = useContext(LocationContext);
  
  if (!context) {
    throw new Error('useLocation must be used within a LocationProvider');
  }
  
  return context;
}; 