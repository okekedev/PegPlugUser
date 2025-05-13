import React, { createContext, useState, useContext, useEffect } from 'react';
import { 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword, 
  signOut, 
  onAuthStateChanged,
  updateProfile
} from 'firebase/auth';
import { auth } from './firebase';

// Create context
const AuthContext = createContext();

// Auth provider component
export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  useEffect(() => {
    // Subscribe to auth state changes
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setUser(user);
      setLoading(false);
    });
    
    // Simulate authentication check finished
    setTimeout(() => {
      setLoading(false);
    }, 1000);
    
    // Cleanup subscription
    return unsubscribe;
  }, []);
  
  // Register new user
  const signup = async (email, password, displayName) => {
    setError(null);
    try {
      // For demo, create a mock user instead of using Firebase
      const mockUser = {
        uid: 'mock-user-id-123',
        email: email || 'demo@example.com',
        displayName: displayName || 'Demo User',
        emailVerified: true,
      };
      
      setUser(mockUser);
      return mockUser;
    } catch (err) {
      setError(err.message);
      throw err;
    }
  };
  
  // Sign in user
  const login = async (email, password) => {
    setError(null);
    try {
      // For demo, create a mock user instead of using Firebase
      const mockUser = {
        uid: 'mock-user-id-123',
        email: email || 'demo@example.com',
        displayName: 'Demo User',
        emailVerified: true,
      };
      
      setUser(mockUser);
      return mockUser;
    } catch (err) {
      setError(err.message);
      throw err;
    }
  };
  
  // Sign out user
  const logout = async () => {
    setError(null);
    try {
      setUser(null);
    } catch (err) {
      setError(err.message);
      throw err;
    }
  };
  
  // Update user profile
  const updateUserProfile = async (data) => {
    try {
      if (user) {
        // For demo, just update the local user state
        setUser({
          ...user,
          ...data
        });
      } else {
        throw new Error('No user is signed in');
      }
    } catch (error) {
      throw error;
    }
  };
  
  const value = {
    user,
    loading,
    error,
    isAuthenticated: !!user,
    signup,
    login,
    logout,
    updateUserProfile
  };
  
  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

// Custom hook to use auth context
export const useAuth = () => {
  const context = useContext(AuthContext);
  
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  
  return context;
}; 