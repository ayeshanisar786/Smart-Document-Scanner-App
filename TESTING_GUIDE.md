# Testing Guide - Smart Document Scanner

## Quick Start (Follow in Order)

### Step 1: Update Flutter (CRITICAL)

Your current Flutter version (3.24.5) is outdated and causing build errors. Update it:

```bash
# Update Flutter to latest stable
flutter upgrade

# Verify version (should be 3.27+)
flutter --version

# Clean and get dependencies
cd Frontend/smart_scanner
flutter clean
flutter pub get
```

**Why this is needed**: Your current version has shader compilation bugs and package compatibility issues.

---

### Step 2: Configure Firebase

The app requires Firebase to function. Follow these steps:

#### 2.1 Install Firebase CLI

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login
```

#### 2.2 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it "smart-document-scanner" (or your choice)
4. Disable Google Analytics (optional for testing)
5. Click "Create Project"

#### 2.3 Enable Firebase Services

In the Firebase Console, enable these services:

1. **Authentication**
   - Go to Authentication > Sign-in method
   - Enable "Anonymous"
   - Enable "Email/Password"

2. **Firestore Database**
   - Go to Firestore Database
   - Click "Create database"
   - Start in "production mode" (we'll deploy security rules)
   - Choose a location (e.g., us-central1)

3. **Storage**
   - Go to Storage
   - Click "Get started"
   - Use default security rules (we'll deploy custom ones)

4. **Cloud Functions**
   - Functions will be enabled when we deploy

#### 2.4 Configure Flutter with Firebase

```bash
cd Frontend/smart_scanner

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Make sure it's in your PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Configure Firebase for your Flutter app
flutterfire configure
```

Follow the prompts:
- Select your Firebase project
- Select platforms: iOS, Android, macOS, Web
- This will create `lib/firebase_options.dart`

#### 2.5 Uncomment Firebase Initialization

Edit `lib/main.dart`:

```dart
// Change from:
// await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
// );

// To:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

#### 2.6 Deploy Backend (Security Rules & Functions)

```bash
cd ../../Backend

# Initialize Firebase in Backend folder
firebase init

# Select:
# - Firestore (rules only)
# - Storage (rules only)
# - Functions (existing code)

# Use existing files when prompted

# Deploy everything
firebase deploy
```

---

### Step 3: Test on iOS Simulator (Recommended)

The iOS Simulator is the best option for testing since Web/macOS have issues with your Flutter version.

```bash
cd Frontend/smart_scanner

# Run on iPhone 16 Plus simulator
flutter run -d 90B307C0-0D2C-4A99-9503-D4EFAAE124A4

# Or simply:
flutter run
```

The app will:
1. Launch in the iOS Simulator
2. Automatically sign in anonymously
3. Show the home screen with empty document list
4. Allow you to tap the + button to open camera

**Note**: iOS Simulator doesn't have a real camera, so you'll see a black screen in camera mode. For full camera testing, you need a physical device.

---

### Step 4: Test on Physical Device (Full Camera Testing)

To test the camera feature, you need a real iPhone or Android device:

#### For iPhone:

1. Connect your iPhone via USB
2. Trust the computer on your iPhone
3. Run:
```bash
flutter devices  # Find your device ID
flutter run -d <your-device-id>
```

#### For Android:

1. Enable Developer Mode on your Android phone:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings > Developer Options
   - Enable "USB Debugging"

2. Connect via USB and run:
```bash
flutter devices  # Find your device ID
flutter run -d <your-device-id>
```

---

## Testing Features

Once the app is running, test these features:

### 1. Home Screen
- ✅ See "My Documents" title
- ✅ See scan counter (0/10)
- ✅ See premium banner
- ✅ Tap premium banner → Navigate to Premium screen

### 2. Camera Screen
- ✅ Tap + button → Open camera
- ✅ See document alignment grid
- ✅ Toggle flash (off/auto/on)
- ✅ See "X scans remaining" text
- ✅ Capture image

### 3. Editor Screen
- ✅ See captured image
- ✅ Apply filters: Original, Grayscale, B&W, Auto
- ✅ Rotate image
- ✅ Tap OCR (should show "Premium Feature" dialog)
- ✅ Tap Save → Document saved

### 4. Premium Screen
- ✅ Toggle Monthly ($4.99) / Yearly ($29.99)
- ✅ See "Save 50%" badge on yearly
- ✅ See feature list with checkmarks
- ✅ Tap Subscribe button (shows "In-app purchase integration required")

### 5. Document List
- ✅ After saving, see document in home screen list
- ✅ See thumbnail and creation date
- ✅ Scan counter increases (1/10)

---

## Troubleshooting

### Issue: "No firebase_options.dart file"

**Solution**: Run `flutterfire configure` in Frontend/smart_scanner folder

### Issue: "Firebase not initialized"

**Solution**: Uncomment Firebase initialization in `lib/main.dart`

### Issue: "Permission denied" on iOS

**Solution**: The camera permission is already configured in `ios/Runner/Info.plist`

### Issue: "Shader compilation failed" on Chrome

**Solution**: Use iOS Simulator instead. This is a known Flutter 3.24.5 bug on Web.

### Issue: Build fails with package errors

**Solution**: Update Flutter with `flutter upgrade`, then `flutter clean && flutter pub get`

### Issue: Camera shows black screen

**Solution**: iOS Simulator doesn't support camera. Use a physical device for camera testing.

---

## Alternative: Test with Mock Data (Without Firebase)

If you want to test the UI without setting up Firebase:

1. Comment out all Firebase initialization in `lib/main.dart`
2. Comment out Firebase imports in providers
3. Use mock data in providers
4. This allows UI testing but features won't work

---

## Next Steps After Testing

1. **Add RevenueCat** for real in-app purchases
2. **Test on Physical Device** for camera functionality
3. **Add Settings Screen** (currently TODO)
4. **Add Document Detail Screen** (currently TODO)
5. **Implement Search** functionality
6. **Add Dark Mode** theme

---

## Support

- **Flutter Issues**: See `TROUBLESHOOTING.md`
- **Run Instructions**: See `HOW_TO_RUN.md`
- **Project Overview**: See `README.md`

---

## Current App Status

✅ **Complete Features**:
- Authentication (Anonymous, Email/Password)
- Camera with alignment grid
- Image filters and rotation
- PDF generation
- Firebase Storage upload
- Premium/Free tier management
- Scan limit enforcement
- Beautiful Material 3 UI

⚠️ **Known Limitations**:
- iOS Simulator has no camera (need physical device)
- In-app purchase shows placeholder message (need RevenueCat)
- OCR returns placeholder (need Google Cloud Vision API)

🚧 **TODO**:
- Settings screen
- Document detail screen
- Search functionality
- Multi-page PDF scanning
- Document sharing

---

**You're ready to test!** Start with Step 1 (Update Flutter), then Step 2 (Configure Firebase), then Step 3 (Run on iOS Simulator).
