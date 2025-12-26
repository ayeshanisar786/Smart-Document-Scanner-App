# How to Run Smart Scanner App

## 🚀 Quick Start - Run the App

You have **4 ways** to run and see the Smart Scanner app:

---

## Option 1: macOS Desktop App (Fastest - Recommended for Testing)

**Run directly on your Mac:**

```bash
cd Frontend/smart_scanner
flutter run -d macos
```

✅ **Pros:**
- Fastest to launch
- No emulator needed
- Good for testing UI/logic
- Easy debugging

❌ **Cons:**
- Some mobile features won't work (camera, mobile sensors)
- Different UI from mobile

---

## Option 2: Chrome Web Browser

**Run in your web browser:**

```bash
cd Frontend/smart_scanner
flutter run -d chrome
```

Then open: **http://localhost:XXXX** (Flutter will show the URL)

✅ **Pros:**
- Quick to start
- Easy to debug with Chrome DevTools
- Responsive design testing

❌ **Cons:**
- Some mobile features limited
- Camera access requires HTTPS in production

---

## Option 3: iOS Simulator (Most Realistic for iPhone)

**Step 1: Launch iOS Simulator**
```bash
flutter emulators --launch apple_ios_simulator
```

**Step 2: Run the app**
```bash
cd Frontend/smart_scanner
flutter run
```

✅ **Pros:**
- Most accurate iPhone experience
- Camera simulation available
- True mobile UI/UX

---

## Option 4: Android Emulator

**Step 1: Launch Android Emulator**
```bash
flutter emulators --launch Medium_Phone_API_35
```

**Step 2: Run the app**
```bash
cd Frontend/smart_scanner
flutter run
```

✅ **Pros:**
- Most accurate Android experience
- Camera simulation available
- True mobile UI/UX

---

## 🔥 Hot Reload

While the app is running, you can make changes to the code and see them instantly:

- Press **`r`** in the terminal to hot reload
- Press **`R`** to hot restart
- Press **`q`** to quit

---

## 🎯 What You'll See

### Current App Features:
1. **Home Screen** with:
   - Document list (empty for now)
   - Premium banner
   - Scan counter (10/10 scans)
   - Floating action button (+)

2. **Navigation**:
   - Settings icon (top right)
   - Premium upgrade banner

### What Works Now:
✅ App launches successfully
✅ UI renders with Material 3 theme
✅ Provider state management initialized
✅ Firebase services ready (need configuration)

### What's Coming Next:
📋 Camera screen for scanning
📋 Document editor
📋 PDF generation
📋 Premium/subscription screen

---

## 🐛 Troubleshooting

### "No devices found"
```bash
# Check available devices
flutter devices

# Check doctor
flutter doctor
```

### iOS Simulator not working?
```bash
# Open Xcode and install simulators
open -a Simulator
```

### Android Emulator not working?
```bash
# Check Android Studio has emulators configured
flutter emulators
```

### App crashes on launch?
The app currently expects Firebase to be configured. To run without Firebase:
1. The app will show authentication errors
2. This is expected until Firebase is set up
3. UI will still render and be visible

---

## 📱 Firebase Setup (To Make It Fully Functional)

To enable all features (authentication, database, storage):

### Step 1: Install Firebase CLI
```bash
npm install -g firebase-tools
```

### Step 2: Login to Firebase
```bash
firebase login
```

### Step 3: Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click "Add Project"
3. Name it "Smart Scanner"
4. Enable Google Analytics (optional)

### Step 4: Configure FlutterFire
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure app with Firebase
cd Frontend/smart_scanner
flutterfire configure
```

This will:
- Create `firebase_options.dart`
- Configure iOS and Android
- Link your app to Firebase project

### Step 5: Enable Firebase Services

In Firebase Console (https://console.firebase.google.com):

1. **Authentication**
   - Go to Authentication → Sign-in method
   - Enable "Anonymous"
   - Enable "Email/Password" (optional)

2. **Firestore Database**
   - Go to Firestore Database
   - Create database (start in test mode for now)
   - Location: Choose closest to you

3. **Storage**
   - Go to Storage
   - Get started
   - Start in test mode

4. **Functions** (Optional for now)
   - We'll deploy these later

### Step 6: Deploy Security Rules
```bash
cd Backend
firebase deploy --only firestore:rules,storage
```

### Step 7: Uncomment Firebase in App
Edit `Frontend/smart_scanner/lib/main.dart`:

```dart
// Uncomment these lines:
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// And uncomment in main():
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Step 8: Run App Again
```bash
flutter run
```

Now the app will have:
- ✅ User authentication
- ✅ Real-time database sync
- ✅ File uploads
- ✅ All features working!

---

## 🎨 See Your Code Changes

**Current file locations:**
- **Home Screen**: `lib/screens/home_screen.dart`
- **Theme**: `lib/theme/app_theme.dart`
- **Providers**: `lib/providers/`
- **Services**: `lib/services/`
- **Utils**: `lib/utils/`

**To modify the UI:**
1. Edit any `.dart` file
2. Save the file
3. Press `r` in the terminal (hot reload)
4. See changes instantly!

---

## 📊 Firebase Console (View Your Data)

After Firebase setup:

**View your data:**
- **Firestore**: https://console.firebase.google.com → Firestore Database
- **Storage**: https://console.firebase.google.com → Storage
- **Auth Users**: https://console.firebase.google.com → Authentication
- **Functions Logs**: https://console.firebase.google.com → Functions

---

## 🚀 Recommended: Start with macOS

**Quick test run:**
```bash
cd Frontend/smart_scanner
flutter run -d macos
```

This will launch the app on your Mac in ~10 seconds and you can see:
- The home screen
- Premium banner
- Material 3 theme
- Basic navigation

**Note:** Firebase features won't work until configured, but you'll see the UI!

---

## 💡 Next Steps

1. **See the app** → Run on macOS first
2. **Configure Firebase** → Follow setup steps above
3. **Test on mobile** → Use iOS/Android simulator
4. **Build features** → Continue with camera screen

---

Need help? Check the logs in the terminal when running `flutter run`.
