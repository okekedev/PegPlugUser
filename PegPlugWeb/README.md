# Peg Plug Web - React Native (Expo) App

A cross-platform implementation of the Peg Plug app, built with React Native and Expo.

## About the App

Peg Plug is a location-based deals and rewards app that allows users to:

- Find deals at nearby merchant locations
- "Spin" a slot machine for rewards when visiting partner locations
- Redeem rewards (called "Plugs") at merchant locations
- Track redemption history

## Features

- Location-based "Pegs" (merchant locations)
- Spin a slot machine for rewards
- Redeemable "Plugs" (rewards) at partner locations
- Discover deals from local businesses
- User authentication with Firebase
- Cross-platform support (iOS, Android, Web)

## Getting Started

### Prerequisites

- Node.js (v14 or newer)
- npm or yarn
- Expo CLI

### Installation

1. Clone the repository
2. Navigate to the PegPlugWeb directory:
   ```
   cd PegPlugWeb
   ```
3. Install dependencies:
   ```
   npm install
   ```
4. Start the development server:
   ```
   npx expo start
   ```

### Running on Different Platforms

- **Web**: `npx expo start --web`
- **iOS**: `npx expo start --ios` (requires macOS and Xcode)
- **Android**: `npx expo start --android` (requires Android Studio)

## Project Structure

- `assets/` - Static assets like images
- `src/` - Source code
  - `components/` - Reusable UI components
  - `screens/` - App screens
  - `navigation/` - Navigation configuration
  - `services/` - Services for Firebase, location, etc.
  - `theme/` - Design system (colors, typography, spacing)
  - `utils/` - Utility functions

## Technologies Used

- React Native
- Expo
- Firebase (Authentication, Firestore, Storage)
- React Navigation
- Expo Location
- React Native Maps 