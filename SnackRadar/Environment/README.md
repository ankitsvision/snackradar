# Environment Configuration

## Firebase Setup

To run the SnackRadar app, you need to add your Firebase configuration file.

### Steps:

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Navigate to Project Settings > General
4. Scroll down to "Your apps" section
5. Click on the iOS app (or add a new iOS app if you haven't already)
6. Download the `GoogleService-Info.plist` file
7. **Important**: Place the `GoogleService-Info.plist` file in the `SnackRadar/Environment/` directory

### Bundle Identifier

Make sure your Firebase iOS app is configured with the correct bundle identifier:
```
com.snackradar.app
```

### Required Firebase Products

The following Firebase products are used in this project:
- **Authentication** - User authentication with Sign in with Apple
- **Cloud Firestore** - Real-time database
- **Cloud Storage** - File storage for images and media
- **Cloud Messaging** - Push notifications

### Security Note

The `GoogleService-Info.plist` file is automatically excluded from version control via `.gitignore` to protect your Firebase configuration. Each developer should obtain their own copy from the Firebase Console.

### Troubleshooting

If you encounter Firebase initialization errors:
1. Verify that `GoogleService-Info.plist` is in the correct location
2. Ensure the bundle identifier matches your Firebase project
3. Check that all required Firebase products are enabled in the Firebase Console
4. Clean build folder (Cmd + Shift + K) and rebuild
