# Peg Plug

This repository contains two implementations of the Peg Plug app:

## [PegPlug](./PegPlug)

The original iOS implementation built with Swift and Xcode. This version is designed for iOS devices only.

## [PegPlugWeb](./PegPlugWeb)

A cross-platform reimplementation using React Native with Expo. This version supports iOS, Android, and web platforms.

## About Peg Plug

Peg Plug is a location-based deals platform where users can:

1. Find nearby merchant locations ("Pegs")
2. Spin a slot machine for rewards
3. Redeem those rewards ("Plugs") at merchant locations
4. Discover exclusive deals from local businesses

The app uses Firebase for authentication and data storage.

## Getting Started

### Prerequisites

- Node.js (v14 or newer)
- npm or yarn
- Expo CLI

### Installation

1. Clone the repository
2. Install dependencies:

```bash
npm install
# or
yarn install
```

3. Start the development server:

```bash
npm start
# or
yarn start
```

4. Use the Expo Go app on your device to scan the QR code, or run in a simulator.

## Features

- Authentication (login/signup) with Firebase
- Location-based services
- Interactive map with nearby "Pegs" (merchant locations)
- Spin card for rewards
- Active Pegs and Plugs sections
- Profile management
- Redemption history

## Technologies Used

- React Native
- Expo
- Firebase (Authentication, Firestore, Storage)
- React Navigation
- Expo Location
- React Native Maps

## Project Structure

- `/src/assets` - Images and other static assets
- `/src/components` - Reusable UI components
- `/src/navigation` - Navigation structure
- `/src/screens` - App screens
- `/src/services` - Firebase, Auth, and Location services
- `/src/theme` - Theme configuration (colors, typography, spacing)
- `/src/utils` - Utility functions 