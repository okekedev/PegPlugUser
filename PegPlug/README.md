# Peg Plug - iOS App

The original iOS implementation of the Peg Plug app, built with Swift and SwiftUI.

## Features

- Find nearby merchant locations ("Pegs") on a map
- Spin a slot machine for rewards when visiting merchant locations
- Redeem rewards ("Plugs") at participating businesses
- View active deals from local merchants
- User authentication and profile management
- Location-based services

## Requirements

- Xcode 14.0 or newer
- iOS 16.0+ deployment target
- Swift 5.7 or newer
- CocoaPods (for dependencies)

## Getting Started

1. Clone the repository
2. Navigate to the PegPlug directory
3. Open `Peg Plug.xcodeproj` in Xcode
4. Run the app in the iOS Simulator or on a physical device

## Project Structure

- `Peg Plug/` - Main app source code
  - `Home/` - Home screen components
  - `Profile/` - Profile screen components
  - `Deals/` - Deals screen components
  - `Slots/` - Slot machine implementation
  - `Models/` - Data models
  - `Services/` - API and Firebase services

## Dependencies

- Firebase (Authentication, Firestore, Storage)
- MapKit
- Core Location 