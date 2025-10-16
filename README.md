# SnackRadar

A SwiftUI iOS application for discovering and sharing snack recommendations.

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Firebase account with configured project

## Project Structure

```
SnackRadar/
├── App/                    # Application entry point and global state
│   ├── SnackRadarApp.swift    # Main app entry with Firebase initialization
│   ├── AppState.swift          # Shared app state (loading, errors, etc.)
│   └── AppSession.swift        # Authentication session management
├── Models/                 # Data models
├── ViewModels/            # View models (MVVM architecture)
├── Views/                 # SwiftUI views
│   └── RootView.swift         # Root navigation (auth/main routing)
├── Services/              # Business logic and API services
│   └── FirebaseService.swift  # Firebase service wrapper
├── Resources/             # Assets and design resources
│   ├── Assets.xcassets/       # Asset catalog
│   ├── Colors.swift           # Color palette
│   └── Fonts.swift            # Font utilities
└── Environment/           # Configuration files
    └── README.md              # Firebase setup instructions
```

## Setup

### 1. Firebase Configuration

Before running the app, you must add your Firebase configuration:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create or select your project
3. Add an iOS app with bundle identifier: `com.snackradar.app`
4. Download `GoogleService-Info.plist`
5. Place it in `SnackRadar/Environment/` directory

See [Environment/README.md](SnackRadar/Environment/README.md) for detailed instructions.

### 2. Firebase Products

Enable the following products in your Firebase project:
- **Authentication** (with Sign in with Apple provider)
- **Cloud Firestore**
- **Cloud Storage**
- **Cloud Messaging**

### 3. Xcode Configuration

Open the project in Xcode and configure:

#### Bundle Identifier
- Set to `com.snackradar.app` (or your preferred identifier)

#### Signing & Capabilities
Add the following capabilities:
- **Sign in with Apple**
- **Push Notifications**
- **Background Modes**
  - Remote notifications

#### Swift Package Dependencies
The project uses Swift Package Manager for Firebase SDK:
- Firebase Auth
- Firebase Firestore
- Firebase Storage
- Firebase Messaging

Dependencies are configured in `Package.swift`.

### 4. Build and Run

1. Select your development team in Signing & Capabilities
2. Choose a target device or simulator
3. Build and run (⌘R)

## Design System

### Color Palette

- **Primary Blue**: `#4A90E2` - Main brand color
- **Secondary Yellow**: `#F5A623` - Accent and highlights
- **Light Grey**: `#FAFAFA` - Background color

### Typography

- **Recoleta**: Display and heading font (with serif fallback)
- **Open Sans**: Body text font (with system fallback)

Custom fonts can be added to the project. The font utilities provide automatic fallbacks to system fonts when custom fonts are unavailable.

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** architecture pattern:

- **Models**: Data structures and entities
- **Views**: SwiftUI views (presentation layer)
- **ViewModels**: Business logic and state management
- **Services**: External integrations (Firebase, APIs)

### State Management

- **AppState**: Global app state (loading indicators, error messages)
- **AppSession**: Authentication state and user session
- Both are injected as `@EnvironmentObject` throughout the view hierarchy

## Features

### Authentication Flow
- Root view automatically routes between authentication and main experience
- Firebase Authentication integration with listener
- Sign in with Apple capability configured

### Push Notifications
- Firebase Cloud Messaging integration
- Background mode for remote notifications
- APNs environment configured in entitlements

### Navigation
- Tab-based main navigation structure
- Authentication guard on root view

## Development

### Adding New Views

1. Create view file in appropriate `Views/` subdirectory
2. Inject required environment objects: `@EnvironmentObject var appState: AppState`
3. Use design system colors and fonts from `AppColors` and `AppFonts`

### Adding New Services

1. Create service file in `Services/` directory
2. Follow singleton pattern if maintaining shared state
3. Inject `FirebaseService.shared` for Firebase operations

### Adding New Models

1. Create model file in `Models/` directory
2. Conform to `Codable` for Firebase serialization
3. Add appropriate property wrappers for Firestore

## License

Copyright © 2024 SnackRadar. All rights reserved.
