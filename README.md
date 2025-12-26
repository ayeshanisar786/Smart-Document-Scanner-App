# Smart Document Scanner App

> AI-powered mobile document scanner with Flutter frontend and secure Firebase backend

[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-blue.svg)](https://flutter.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.16.0+-02569B.svg?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28.svg?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Overview

Smart Document Scanner is a production-ready mobile application that transforms your phone into a powerful document scanner with AI capabilities. Built with **Flutter** for cross-platform support and **Firebase** for secure, scalable backend infrastructure.

### Key Features

✅ **Free Tier (10 scans/month)**
- High-quality document scanning
- Auto edge detection
- Multiple filters (B&W, Grayscale, Color)
- PDF generation
- Local storage
- Native sharing

✅ **Premium Tier ($4.99/month or $29.99/year)**
- Unlimited scans
- AI text extraction (OCR)
- Auto-enhancement
- Cloud backup & sync
- Multi-page PDFs
- Advanced organization (folders, tags)
- Search through documents

## 🏗️ Architecture

### Security-First Design

This project implements a **zero-trust frontend** architecture where:

```
┌─────────────────────────────────────┐
│     Flutter App (UNTRUSTED)         │
│  • Display UI only                  │
│  • NO business logic                │
│  • NO API keys                      │
│  • NO validation                    │
└─────────────────────────────────────┘
              ↕️ HTTPS
┌─────────────────────────────────────┐
│  Firebase Backend (TRUSTED)         │
│  ✅ All validation                  │
│  ✅ Rate limiting                   │
│  ✅ Subscription checks             │
│  ✅ API key management              │
└─────────────────────────────────────┘
```

### Tech Stack

**Frontend:**
- Flutter 3.16.0+
- Dart 3.2.0+
- Provider (State Management)
- Camera & Image Processing
- PDF Generation

**Backend:**
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Cloud Functions (Node.js)
- Firebase Analytics
- Google Cloud Vision API (OCR)

**Payments:**
- RevenueCat (In-App Purchases)
- Apple App Store
- Google Play Store

## 📁 Project Structure

```
Smart Document Scanner-App/
├── Frontend/                      # Flutter mobile app
│   ├── lib/
│   │   ├── models/               # Data models
│   │   ├── services/             # API & backend services
│   │   ├── providers/            # State management
│   │   ├── screens/              # UI screens
│   │   ├── widgets/              # Reusable components
│   │   ├── utils/                # Helper functions
│   │   └── theme/                # App theming
│   ├── android/                  # Android platform code
│   ├── ios/                      # iOS platform code
│   └── pubspec.yaml              # Dependencies
│
├── Backend/                       # Firebase Cloud Functions
│   ├── functions/
│   │   ├── index.js              # Main functions
│   │   ├── rateLimiter.js        # Rate limiting
│   │   └── package.json          # Node dependencies
│   ├── firestore.rules           # Database security
│   └── storage.rules             # Storage security
│
├── MASTER_PROJECT_BRIEF.md        # Complete project specification
├── DEVELOPER_COMPANION_GUIDE.md   # Development reference
├── smart-scanner-flutter-secure.md # Security architecture
└── README.md                      # This file
```

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.16.0+)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Node.js](https://nodejs.org/) (18+)
- iOS: Xcode 15+ (Mac required)
- Android: Android Studio

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ayeshanisar786/Smart-Document-Scanner-App.git
   cd Smart-Document-Scanner-App
   ```

2. **Set up Flutter**
   ```bash
   flutter pub get
   flutter doctor
   ```

3. **Configure Firebase**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli

   # Login to Firebase
   firebase login

   # Configure Flutter app with Firebase
   flutterfire configure
   ```

4. **Set up Cloud Functions**
   ```bash
   cd Backend/functions
   npm install
   cd ../..
   ```

5. **Deploy Firebase backend**
   ```bash
   firebase deploy --only firestore:rules,storage,functions
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## 🔐 Security Features

### Backend Validation
- ✅ All business logic server-side
- ✅ Scan limit enforcement via Cloud Functions
- ✅ Subscription verification with Apple/Google servers
- ✅ Rate limiting on all operations
- ✅ No API keys in frontend code

### Data Protection
- ✅ Firestore security rules enforce user isolation
- ✅ Storage rules prevent unauthorized access
- ✅ HTTPS-only communication
- ✅ Encrypted data at rest (Firebase default)
- ✅ Server-side authentication checks

### Security Rules

**Firestore Rules:**
```javascript
// Users can only read their own data
match /users/{userId} {
  allow read: if request.auth.uid == userId;
  allow write: if false; // Only Cloud Functions
}

// Documents isolated per user
match /users/{userId}/documents/{docId} {
  allow read, delete: if request.auth.uid == userId;
  allow create: if isPremium(userId) || hasScansRemaining(userId);
}
```

## 💰 Monetization

### Freemium Model

| Feature | Free | Premium |
|---------|------|---------|
| Scans per month | 10 | Unlimited |
| PDF Generation | ✅ | ✅ |
| Filters | ✅ | ✅ |
| OCR Text Extraction | ❌ | ✅ |
| Cloud Backup | ❌ | ✅ |
| Multi-page PDFs | ❌ | ✅ |
| Advanced Organization | ❌ | ✅ |

### Pricing
- **Monthly**: $4.99/month
- **Yearly**: $29.99/year (50% savings)

### Revenue Projections

| Timeframe | Users | Conversion | Revenue |
|-----------|-------|------------|---------|
| Month 3 | 500 | 2% | $50-150/mo |
| Month 6 | 2,000 | 3% | $300-750/mo |
| Month 12 | 10,000 | 5% | $2,500-6,250/mo |

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Firebase emulator tests
firebase emulators:start
flutter test --dart-define=USE_FIREBASE_EMULATOR=true
```

### Security Testing
```bash
# Test Firestore rules
firebase emulators:start --only firestore
npm install -g @firebase/rules-unit-testing
```

## 📱 Building for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS (Mac required)
flutter build ios --release
```

## 🚢 Deployment

### Firebase Backend
```bash
# Deploy everything
firebase deploy

# Deploy specific services
firebase deploy --only functions
firebase deploy --only firestore:rules
firebase deploy --only storage
```

### App Stores

**iOS (App Store):**
1. Configure in App Store Connect
2. Set up in-app purchases
3. Upload build via Xcode/Transporter
4. Submit for review (1-3 days)

**Android (Google Play):**
1. Configure in Play Console
2. Set up in-app products
3. Upload AAB file
4. Submit for review (1-7 days)

## 📊 Analytics & Monitoring

### Firebase Analytics Events
- `scan_attempt` - User scans document
- `premium_upgrade` - User upgrades to premium
- `feature_used` - User uses premium feature
- `error_occurred` - App errors

### Crashlytics
- Real-time crash reporting
- Error tracking
- Performance monitoring

## 💡 Development Timeline

### Week 1: MVP Development (3-4 days)
- ✅ Day 1: Project setup + Backend security
- ✅ Day 2: Core features (camera, PDF)
- ✅ Day 3: Premium features + payments
- ✅ Day 4: Testing & polish

### Week 2: Store Preparation (5-7 days)
- ✅ App store assets
- ✅ Screenshots & description
- ✅ Privacy policy
- ✅ Submission

### Month 2+: Growth
- Optimization based on user feedback
- Marketing campaigns
- Feature expansion
- A/B testing

## 📚 Documentation

- **[MASTER_PROJECT_BRIEF.md](./MASTER_PROJECT_BRIEF.md)** - Complete project specification with implementation details
- **[DEVELOPER_COMPANION_GUIDE.md](./DEVELOPER_COMPANION_GUIDE.md)** - Quick reference, schemas, scripts, and best practices
- **[smart-scanner-flutter-secure.md](./smart-scanner-flutter-secure.md)** - Detailed security architecture

## 🤝 Contributing

This is a personal project, but contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Ayesha Nisar**
- GitHub: [@ayeshanisar786](https://github.com/ayeshanisar786)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Google Cloud Vision for OCR capabilities
- RevenueCat for payment management

## 📞 Support

For issues and questions:
- Create an [Issue](https://github.com/ayeshanisar786/Smart-Document-Scanner-App/issues)
- Email: [your-email@example.com]

## 🔮 Roadmap

### Phase 1 (Current)
- ✅ Basic scanning functionality
- ✅ Premium subscriptions
- ✅ Cloud backup
- ✅ OCR text extraction

### Phase 2 (Q2 2024)
- 📋 Batch scanning
- 📋 Dark mode
- 📋 Document templates
- 📋 Export formats (DOCX, TXT)

### Phase 3 (Q3 2024)
- 📋 Team collaboration
- 📋 Document signing
- 📋 Advanced AI features
- 📋 Web dashboard

---

**Built with ❤️ using Flutter & Firebase**

*Transform photos into professional PDFs in seconds!*
