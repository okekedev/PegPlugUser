/**
 * Peg Plug App Color Palette
 * These colors are based on the Peg Plug logo theme
 */

export const colors = {
  // Main brand colors
  primary: {
    red: '#E63946',       // Primary red from logo
    black: '#1D3557',     // Primary black from logo
    white: '#F1FAEE'      // White for contrast
  },
  
  // Secondary colors
  secondary: {
    blue: '#457B9D',      // Complementary blue for UI accents
    lightBlue: '#A8DADC',  // Lighter variation of primary blue
  },
  
  // UI colors
  ui: {
    background: '#FFFFFF',  // Light background
    card: '#F8F9FA',        // Card background
    border: '#E9ECEF',      // Border color
    disabled: '#CED4DA',    // Disabled state color
  },
  
  // Text colors
  text: {
    primary: '#212529',     // Primary text color
    secondary: '#495057',   // Secondary text color
    tertiary: '#6C757D',    // Tertiary text color
    inverse: '#FFFFFF',     // Inverse text color
  },
  
  // Notification colors
  status: {
    success: '#28A745',     // Success messages
    error: '#DC3545',       // Error messages
    warning: '#FFC107',     // Warning messages
    info: '#17A2B8',        // Information messages
  },
  
  // Misc
  transparent: 'transparent',
  overlay: 'rgba(0, 0, 0, 0.5)' // Modal overlay
};

export default colors; 