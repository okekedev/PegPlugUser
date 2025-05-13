import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { AuthProvider } from './src/services/AuthContext';
import { LocationProvider } from './src/services/LocationService';
import Navigation from './src/navigation';

export default function App() {
  return (
    <SafeAreaProvider>
      <StatusBar style="auto" />
      <AuthProvider>
        <LocationProvider>
          <Navigation />
        </LocationProvider>
      </AuthProvider>
    </SafeAreaProvider>
  );
} 