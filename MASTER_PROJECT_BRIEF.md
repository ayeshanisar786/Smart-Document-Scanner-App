# Smart Document Scanner - Complete Project Brief
## Flutter Mobile App with Security-First Architecture

**Version**: 1.0  
**Target Platform**: iOS & Android  
**Timeline**: 3-4 days MVP, 1 week production-ready  
**Architecture**: Client-Server with Firebase Backend  
**Security Level**: Production-grade, server-validated

---

## 📋 TABLE OF CONTENTS

1. [Executive Summary](#executive-summary)
2. [Project Goals & Requirements](#project-goals--requirements)
3. [Tech Stack & Architecture](#tech-stack--architecture)
4. [Security Architecture](#security-architecture)
5. [Implementation Phases](#implementation-phases)
6. [Code Structure & Examples](#code-structure--examples)
7. [Testing Strategy](#testing-strategy)
8. [Deployment Guide](#deployment-guide)
9. [Cost Analysis](#cost-analysis)
10. [Timeline & Milestones](#timeline--milestones)
11. [Success Metrics](#success-metrics)
12. [Appendix & Resources](#appendix--resources)

---

## 1. EXECUTIVE SUMMARY

### What We're Building
A mobile document scanner app that converts photos into PDFs with AI-powered enhancements. The app uses a freemium business model with 10 free scans per month and premium unlimited features.

### Key Differentiators
- **Security-First**: All business logic and validation on backend
- **AI-Powered**: OCR text extraction and auto-enhancement
- **Cross-Platform**: Single codebase for iOS & Android
- **Scalable**: Built to handle 10K+ users from day one

### Target Users
- Students scanning notes and textbooks
- Professionals managing documents
- Small businesses tracking receipts
- Anyone going paperless

### Revenue Model
- Free: 10 scans/month
- Premium: $4.99/month or $29.99/year (unlimited scans + AI features)
- Target: $2K-6K MRR by month 12

### Why This Will Succeed
✅ Clear pain point (everyone needs document scanning)  
✅ Strong freemium funnel (free users convert at 3-5%)  
✅ Low competition in well-designed scanner apps  
✅ Recurring revenue model  
✅ Easy to market and explain  

---

## 2. PROJECT GOALS & REQUIREMENTS

### Primary Goals
1. **Build MVP in 3-4 days** that can scan, save, and share documents
2. **Implement secure backend** that prevents abuse and manipulation
3. **Create premium upgrade flow** that converts free users
4. **Launch on both stores** within 1 week of completion
5. **Achieve profitability** by month 3-4

### Functional Requirements

#### Free User Features
- ✅ Anonymous authentication (no signup required)
- ✅ Scan up to 10 documents per month
- ✅ Camera capture with basic editing (rotate, crop)
- ✅ Apply filters (B&W, Grayscale, Color)
- ✅ Save as PDF locally
- ✅ Share documents via native share
- ✅ View scan counter
- ✅ Basic document list

#### Premium User Features
- ✅ Unlimited scans
- ✅ AI text extraction (OCR)
- ✅ Auto-enhancement (AI-powered)
- ✅ Cloud backup & sync
- ✅ Multi-page PDFs
- ✅ Advanced organization (folders, tags)
- ✅ Search through documents
- ✅ Export to multiple formats

#### Administrative Features (Backend)
- ✅ User management
- ✅ Subscription validation
- ✅ Rate limiting
- ✅ Analytics tracking
- ✅ Abuse prevention
- ✅ Monthly scan reset automation

### Non-Functional Requirements

#### Performance
- App startup: < 2 seconds
- Camera load: < 1 second
- Image processing: < 3 seconds
- Cloud upload: < 5 seconds per document
- 60 FPS UI animations

#### Security
- All secrets server-side only
- Encrypted data in transit (HTTPS)
- Encrypted data at rest
- User data isolation
- Server-side validation for all critical operations
- Rate limiting to prevent abuse

#### Scalability
- Support 10,000+ concurrent users
- Handle 100,000+ documents
- Auto-scaling Cloud Functions
- Firebase free tier for MVP, scales automatically

#### Reliability
- 99.9% uptime (Firebase SLA)
- Graceful error handling
- Offline mode for viewing saved documents
- Crash-free rate > 99.5%

---

## 3. TECH STACK & ARCHITECTURE

### Frontend Technology: Flutter

**Why Flutter?**
- ✅ Single codebase for iOS & Android (50% faster development)
- ✅ Native performance (compiled to native code)
- ✅ Excellent camera & image processing libraries
- ✅ Material Design & Cupertino widgets built-in
- ✅ Hot reload for rapid iteration
- ✅ Strong typing with Dart (fewer bugs)
- ✅ Growing ecosystem (Google-backed)

**Flutter Version**: 3.16.0+  
**Dart Version**: 3.2.0+

### Backend Technology: Firebase

**Why Firebase?**
- ✅ Managed infrastructure (no DevOps needed)
- ✅ Auto-scaling (handles growth automatically)
- ✅ Built-in authentication
- ✅ Real-time database (Firestore)
- ✅ File storage with CDN
- ✅ Serverless functions
- ✅ Free tier sufficient for MVP
- ✅ Official Flutter support

**Firebase Services Used**:
1. **Firebase Authentication** - Anonymous & email auth
2. **Cloud Firestore** - Document metadata & user data
3. **Firebase Storage** - PDF files & images
4. **Cloud Functions** - Server-side logic & validation
5. **Firebase Analytics** - User behavior tracking
6. **Firebase Crashlytics** - Error monitoring

### Additional Services

**RevenueCat** (In-App Purchases)
- Why: Handles iOS & Android subscriptions
- Free tier: Up to $10K/month revenue
- Features: Receipt validation, webhooks, analytics

**Google Cloud Vision API** (OCR - Premium Feature)
- Why: Accurate text extraction
- Cost: Free tier (1,000 requests/month)
- Fallback: Tesseract.js (free, local)

### Development Tools
- **IDE**: VS Code or Android Studio
- **Version Control**: Git + GitHub
- **CI/CD**: GitHub Actions (optional)
- **Testing**: Flutter Test + Firebase Emulator Suite
- **Design**: Figma or Canva

---

## 4. SECURITY ARCHITECTURE

### Security Principle: NEVER TRUST THE CLIENT

```
┌──────────────────────────────────────────────────┐
│           FLUTTER APP (UNTRUSTED ZONE)           │
│  • Display UI only                               │
│  • Collect user input                            │
│  • NO business logic                             │
│  • NO secrets/API keys                           │
│  • NO subscription validation                    │
└──────────────────────────────────────────────────┘
                      ↕️ HTTPS Only
┌──────────────────────────────────────────────────┐
│        FIREBASE BACKEND (TRUSTED ZONE)           │
│  ✅ Validate ALL requests                        │
│  ✅ Enforce scan limits                          │
│  ✅ Verify subscriptions                         │
│  ✅ Store API keys                               │
│  ✅ Execute business logic                       │
│  ✅ Rate limiting                                │
└──────────────────────────────────────────────────┘
```

### Critical Security Rules

#### 1. No Secrets in Frontend
```dart
// ❌ WRONG - API key exposed
class Config {
  static const apiKey = 'AIzaSyXXXX'; // Extractable from APK
}

// ✅ CORRECT - Cloud Function handles it
Future<String> performOcr(String imageUrl) async {
  final functions = FirebaseFunctions.instance;
  final result = await functions.httpsCallable('performOcr').call({
    'imageUrl': imageUrl,
  });
  return result.data['text'];
}
```

#### 2. Server-Side Validation
```javascript
// Cloud Function (Backend)
exports.recordScan = functions.https.onCall(async (data, context) => {
  // ✅ Server validates authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Login required');
  }

  // ✅ Server checks scan limit
  const userDoc = await admin.firestore()
    .collection('users')
    .doc(context.auth.uid)
    .get();
  
  const userData = userDoc.data();
  
  if (!userData.isPremium && userData.scansThisMonth >= 10) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Scan limit reached'
    );
  }

  // ✅ Server increments counter
  await userDoc.ref.update({
    scansThisMonth: admin.firestore.FieldValue.increment(1)
  });

  return { success: true };
});
```

#### 3. Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can ONLY read their own data
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // ONLY Cloud Functions can write
    }
    
    // Documents isolated per user
    match /users/{userId}/documents/{documentId} {
      allow read, delete: if request.auth.uid == userId;
      allow create: if request.auth.uid == userId && 
                       (isPremium(userId) || hasScansRemaining(userId));
    }
    
    // Helper functions
    function isPremium(userId) {
      let user = get(/databases/$(database)/documents/users/$(userId)).data;
      return user.isPremium == true && 
             user.subscriptionExpires > request.time;
    }
    
    function hasScansRemaining(userId) {
      let user = get(/databases/$(database)/documents/users/$(userId)).data;
      return user.scansThisMonth < 10;
    }
  }
}
```

#### 4. Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      // Users can ONLY access their own files
      allow read, write: if request.auth != null && 
                            request.auth.uid == userId &&
                            request.resource.size < 10 * 1024 * 1024; // 10MB limit
    }
  }
}
```

#### 5. Rate Limiting
```javascript
// Cloud Function rate limiter
async function checkRateLimit(userId, action, maxPerHour) {
  const now = Date.now();
  const oneHourAgo = now - (60 * 60 * 1000);
  
  const rateLimitRef = admin.firestore()
    .collection('rateLimits')
    .doc(userId)
    .collection('actions')
    .doc(action);
  
  const doc = await rateLimitRef.get();
  const attempts = (doc.data()?.attempts || []).filter(t => t > oneHourAgo);
  
  if (attempts.length >= maxPerHour) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Rate limit exceeded'
    );
  }
  
  attempts.push(now);
  await rateLimitRef.set({ attempts, lastUpdated: now });
}
```

#### 6. Subscription Validation
```javascript
// Cloud Function - validates with Apple/Google
exports.verifySubscription = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new Error('Unauthorized');

  const { receiptData, platform } = data;
  
  // ✅ Verify with Apple/Google servers (not client data)
  let isValid = false;
  if (platform === 'ios') {
    isValid = await verifyAppleReceipt(receiptData);
  } else {
    isValid = await verifyGooglePurchase(receiptData);
  }

  if (isValid) {
    // Update user's subscription in Firestore
    await admin.firestore()
      .collection('users')
      .doc(context.auth.uid)
      .update({
        isPremium: true,
        subscriptionExpires: /* date from receipt */,
      });
  }

  return { success: isValid };
});
```

### What This Security Prevents

| Attack Vector | Prevention |
|---------------|------------|
| User modifies scan count | Firestore rules block writes from client |
| User fakes premium status | Cloud Function validates with Apple/Google |
| User accesses others' documents | Firestore rules enforce user isolation |
| User spams OCR API | Rate limiter blocks excessive requests |
| User extracts API keys | Keys never stored in app, only backend |
| User bypasses payment | Server validates receipts, not client |

---

## 5. IMPLEMENTATION PHASES

### Phase 1: Project Setup (4-6 hours)

#### Step 1.1: Install Flutter & Tools
```bash
# Install Flutter SDK
# Download from: https://flutter.dev/docs/get-started/install

# Verify installation
flutter doctor

# Install dependencies
flutter pub get
```

#### Step 1.2: Create Project
```bash
# Create Flutter project
flutter create smart_scanner
cd smart_scanner

# Add to Git
git init
git add .
git commit -m "Initial commit"
```

#### Step 1.3: Update pubspec.yaml
```yaml
name: smart_scanner
description: AI-powered document scanner
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # UI & Design
  cupertino_icons: ^1.0.6
  google_fonts: ^6.1.0
  
  # Camera & Images
  camera: ^0.10.5+5
  image_picker: ^1.0.4
  image: ^4.1.3
  image_cropper: ^5.0.0
  
  # PDF
  pdf: ^3.10.7
  printing: ^5.11.1
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_functions: ^4.6.0
  firebase_analytics: ^10.8.0
  
  # State Management
  provider: ^6.1.1
  
  # Storage
  flutter_secure_storage: ^9.0.0
  path_provider: ^2.1.1
  
  # Utilities
  uuid: ^4.3.3
  intl: ^0.18.1
  dio: ^5.4.0
  
  # Payments
  purchases_flutter: ^6.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
```

#### Step 1.4: Initialize Firebase
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Create Firebase project (via console or CLI)
firebase projects:create smart-scanner

# Configure Flutter app
flutterfire configure
```

#### Step 1.5: Project Structure
```
smart_scanner/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   │
│   ├── models/
│   │   ├── document_model.dart
│   │   ├── user_model.dart
│   │   └── subscription_model.dart
│   │
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── storage_service.dart
│   │   ├── subscription_service.dart
│   │   ├── document_service.dart
│   │   └── camera_service.dart
│   │
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── document_provider.dart
│   │   └── subscription_provider.dart
│   │
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── camera_screen.dart
│   │   ├── editor_screen.dart
│   │   ├── document_detail_screen.dart
│   │   ├── premium_screen.dart
│   │   └── settings_screen.dart
│   │
│   ├── widgets/
│   │   ├── document_card.dart
│   │   ├── camera_controls.dart
│   │   ├── filter_selector.dart
│   │   └── loading_indicator.dart
│   │
│   ├── utils/
│   │   ├── constants.dart
│   │   ├── helpers.dart
│   │   └── validators.dart
│   │
│   └── theme/
│       ├── app_theme.dart
│       └── colors.dart
│
├── functions/
│   ├── index.js
│   ├── package.json
│   └── .env
│
├── firestore.rules
├── storage.rules
├── android/
├── ios/
└── pubspec.yaml
```

---

### Phase 2: Core Backend Setup (4-6 hours)

#### Step 2.1: Initialize Cloud Functions
```bash
cd smart_scanner
firebase init functions

# Select:
# - JavaScript
# - ESLint: Yes
# - Install dependencies: Yes
```

#### Step 2.2: Cloud Functions Implementation

**functions/package.json:**
```json
{
  "name": "functions",
  "scripts": {
    "serve": "firebase emulators:start --only functions",
    "shell": "firebase functions:shell",
    "start": "npm run shell",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  },
  "engines": {
    "node": "18"
  },
  "main": "index.js",
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^4.5.0",
    "axios": "^1.6.0"
  }
}
```

**functions/index.js:**
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// ═══════════════════════════════════════════════════════
// USER INITIALIZATION
// ═══════════════════════════════════════════════════════
exports.onUserCreated = functions.auth.user().onCreate(async (user) => {
  await admin.firestore().collection('users').doc(user.uid).set({
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    isPremium: false,
    scansThisMonth: 0,
    scanLimit: 10,
    lastScanReset: admin.firestore.FieldValue.serverTimestamp(),
  });
  
  console.log(`User initialized: ${user.uid}`);
});

// ═══════════════════════════════════════════════════════
// SCAN RECORDING (SERVER-SIDE VALIDATION)
// ═══════════════════════════════════════════════════════
exports.recordScan = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be authenticated'
    );
  }

  const userId = context.auth.uid;
  const userRef = admin.firestore().collection('users').doc(userId);

  try {
    return await admin.firestore().runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'User not found');
      }

      const userData = userDoc.data();
      const now = admin.firestore.Timestamp.now();

      // Check if premium (unlimited scans)
      if (userData.isPremium && userData.subscriptionExpires > now) {
        return { 
          success: true, 
          unlimited: true,
          scansRemaining: -1 
        };
      }

      // Check scan limit for free users
      if (userData.scansThisMonth >= userData.scanLimit) {
        throw new functions.https.HttpsError(
          'resource-exhausted',
          'Scan limit reached. Upgrade to Premium.'
        );
      }

      // Increment scan count
      transaction.update(userRef, {
        scansThisMonth: admin.firestore.FieldValue.increment(1),
        lastScanDate: admin.firestore.FieldValue.serverTimestamp(),
      });

      const remaining = userData.scanLimit - userData.scansThisMonth - 1;

      return {
        success: true,
        unlimited: false,
        scansRemaining: remaining,
      };
    });
  } catch (error) {
    console.error('Record scan error:', error);
    throw error;
  }
});

// ═══════════════════════════════════════════════════════
// SUBSCRIPTION VERIFICATION
// ═══════════════════════════════════════════════════════
exports.verifySubscription = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Login required');
  }

  const { receiptData, platform, productId } = data;
  const userId = context.auth.uid;

  try {
    let isValid = false;
    let expirationDate = null;

    if (platform === 'ios') {
      const appleResponse = await verifyAppleReceipt(receiptData);
      isValid = appleResponse.status === 0;
      
      if (isValid && appleResponse.latest_receipt_info) {
        const latest = appleResponse.latest_receipt_info[0];
        expirationDate = new Date(parseInt(latest.expires_date_ms));
      }
    } else if (platform === 'android') {
      const googleResponse = await verifyGooglePurchase(productId, receiptData);
      isValid = googleResponse.purchaseState === 0;
      
      if (isValid) {
        expirationDate = new Date(parseInt(googleResponse.expiryTimeMillis));
      }
    }

    if (isValid && expirationDate) {
      // Update user subscription
      await admin.firestore().collection('users').doc(userId).update({
        isPremium: true,
        subscriptionExpires: admin.firestore.Timestamp.fromDate(expirationDate),
        subscriptionPlatform: platform,
        subscriptionProductId: productId,
        subscriptionVerifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Subscription verified for user: ${userId}`);

      return { 
        success: true, 
        expiresAt: expirationDate.toISOString() 
      };
    }

    return { success: false, error: 'Invalid receipt' };
  } catch (error) {
    console.error('Subscription verification error:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Helper: Verify Apple Receipt
async function verifyAppleReceipt(receiptData) {
  const axios = require('axios');
  
  const isProduction = functions.config().app?.env === 'production';
  const url = isProduction
    ? 'https://buy.itunes.apple.com/verifyReceipt'
    : 'https://sandbox.itunes.apple.com/verifyReceipt';

  const sharedSecret = functions.config().apple?.shared_secret;

  const response = await axios.post(url, {
    'receipt-data': receiptData,
    'password': sharedSecret,
    'exclude-old-transactions': true,
  });

  return response.data;
}

// Helper: Verify Google Purchase
async function verifyGooglePurchase(productId, purchaseToken) {
  const { google } = require('googleapis');
  
  const auth = new google.auth.GoogleAuth({
    keyFile: functions.config().google?.service_account_path,
    scopes: ['https://www.googleapis.com/auth/androidpublisher'],
  });

  const androidPublisher = google.androidpublisher({
    version: 'v3',
    auth: await auth.getClient(),
  });

  const response = await androidPublisher.purchases.subscriptions.get({
    packageName: 'com.yourcompany.smartscanner',
    subscriptionId: productId,
    token: purchaseToken,
  });

  return response.data;
}

// ═══════════════════════════════════════════════════════
// OCR PROCESSING (PREMIUM FEATURE)
// ═══════════════════════════════════════════════════════
exports.performOcr = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Login required');
  }

  const userId = context.auth.uid;
  
  // Verify premium status
  const userDoc = await admin.firestore().collection('users').doc(userId).get();
  const userData = userDoc.data();
  
  const now = admin.firestore.Timestamp.now();
  const isPremium = userData.isPremium && 
                    userData.subscriptionExpires && 
                    userData.subscriptionExpires > now;

  if (!isPremium) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Premium subscription required for OCR'
    );
  }

  // Rate limiting
  await checkRateLimit(userId, 'ocr', 50); // 50 per hour

  try {
    const vision = require('@google-cloud/vision');
    const client = new vision.ImageAnnotatorClient();

    const { imageUrl } = data;
    
    const [result] = await client.textDetection(imageUrl);
    const detections = result.textAnnotations;
    const text = detections?.[0]?.description || '';

    console.log(`OCR performed for user: ${userId}`);

    return { success: true, text };
  } catch (error) {
    console.error('OCR error:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Helper: Rate Limiting
async function checkRateLimit(userId, action, maxPerHour) {
  const now = Date.now();
  const oneHourAgo = now - (60 * 60 * 1000);
  
  const rateLimitRef = admin.firestore()
    .collection('rateLimits')
    .doc(userId)
    .collection('actions')
    .doc(action);
  
  const doc = await rateLimitRef.get();
  const attempts = (doc.data()?.attempts || []).filter(t => t > oneHourAgo);
  
  if (attempts.length >= maxPerHour) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Rate limit exceeded. Try again later.'
    );
  }
  
  attempts.push(now);
  await rateLimitRef.set({ 
    attempts, 
    lastUpdated: admin.firestore.FieldValue.serverTimestamp() 
  });
}

// ═══════════════════════════════════════════════════════
// SCHEDULED FUNCTIONS
// ═══════════════════════════════════════════════════════

// Reset monthly scans (1st of every month)
exports.resetMonthlyScans = functions.pubsub
  .schedule('0 0 1 * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    const usersSnapshot = await admin.firestore()
      .collection('users')
      .get();
    
    const batch = admin.firestore().batch();
    
    usersSnapshot.docs.forEach((doc) => {
      batch.update(doc.ref, {
        scansThisMonth: 0,
        lastScanReset: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
    
    await batch.commit();
    
    console.log(`Reset scan counts for ${usersSnapshot.size} users`);
    return null;
  });

// Check expired subscriptions (daily)
exports.checkExpiredSubscriptions = functions.pubsub
  .schedule('0 0 * * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    
    const expiredSnapshot = await admin.firestore()
      .collection('users')
      .where('isPremium', '==', true)
      .where('subscriptionExpires', '<', now)
      .get();
    
    const batch = admin.firestore().batch();
    
    expiredSnapshot.docs.forEach((doc) => {
      batch.update(doc.ref, {
        isPremium: false,
      });
    });
    
    await batch.commit();
    
    console.log(`Expired ${expiredSnapshot.size} subscriptions`);
    return null;
  });
```

#### Step 2.3: Configure Firebase Secrets
```bash
# Set Apple shared secret (for iOS subscription validation)
firebase functions:config:set apple.shared_secret="YOUR_APPLE_SHARED_SECRET"

# Set environment
firebase functions:config:set app.env="development"

# Set Google service account path (for Android validation)
firebase functions:config:set google.service_account_path="path/to/service-account.json"

# View current config
firebase functions:config:get
```

#### Step 2.4: Deploy Cloud Functions
```bash
cd functions
npm install

# Deploy all functions
firebase deploy --only functions

# Or deploy specific function
firebase deploy --only functions:recordScan
```

#### Step 2.5: Security Rules

**firestore.rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isPremium(userId) {
      let userData = get(/databases/$(database)/documents/users/$(userId)).data;
      return userData.isPremium == true && 
             userData.subscriptionExpires > request.time;
    }
    
    function hasScansRemaining(userId) {
      let userData = get(/databases/$(database)/documents/users/$(userId)).data;
      return userData.scansThisMonth < userData.scanLimit;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow write: if false; // Only Cloud Functions can write
    }
    
    // User documents
    match /users/{userId}/documents/{documentId} {
      allow read, delete: if isOwner(userId);
      allow create: if isOwner(userId) && 
                       (isPremium(userId) || hasScansRemaining(userId));
      allow update: if isOwner(userId);
    }
    
    // Rate limits (Cloud Functions only)
    match /rateLimits/{userId}/{document=**} {
      allow read, write: if false; // Cloud Functions only
    }
  }
}
```

**storage.rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function validFileSize() {
      return request.resource.size < 10 * 1024 * 1024; // 10MB max
    }
    
    match /users/{userId}/{allPaths=**} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId) && validFileSize();
      allow delete: if isOwner(userId);
    }
  }
}
```

**Deploy Security Rules:**
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage

# Deploy both
firebase deploy --only firestore:rules,storage
```

---

### Phase 3: Flutter Frontend Implementation (8-12 hours)

#### Step 3.1: Main App Structure

**lib/main.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/document_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Scanner',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<AuthProvider>().initializeAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }
        
        return const HomeScreen();
      },
    );
  }
}
```

#### Step 3.2: Models

**lib/models/document_model.dart:**
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String documentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int pageCount;
  final int fileSize;
  final bool isFavorite;
  final String? ocrText;
  final List<String> tags;

  DocumentModel({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.documentUrl,
    required this.createdAt,
    required this.updatedAt,
    this.pageCount = 1,
    this.fileSize = 0,
    this.isFavorite = false,
    this.ocrText,
    this.tags = const [],
  });

  factory DocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentModel(
      id: doc.id,
      name: data['name'] ?? 'Untitled',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      documentUrl: data['documentUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      pageCount: data['pageCount'] ?? 1,
      fileSize: data['fileSize'] ?? 0,
      isFavorite: data['isFavorite'] ?? false,
      ocrText: data['ocrText'],
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'thumbnailUrl': thumbnailUrl,
      'documentUrl': documentUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'pageCount': pageCount,
      'fileSize': fileSize,
      'isFavorite': isFavorite,
      'ocrText': ocrText,
      'tags': tags,
    };
  }

  DocumentModel copyWith({
    String? name,
    bool? isFavorite,
    String? ocrText,
    List<String>? tags,
  }) {
    return DocumentModel(
      id: id,
      name: name ?? this.name,
      thumbnailUrl: thumbnailUrl,
      documentUrl: documentUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      pageCount: pageCount,
      fileSize: fileSize,
      isFavorite: isFavorite ?? this.isFavorite,
      ocrText: ocrText ?? this.ocrText,
      tags: tags ?? this.tags,
    );
  }
}
```

**lib/models/user_model.dart:**
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final bool isPremium;
  final DateTime? subscriptionExpires;
  final int scansThisMonth;
  final int scanLimit;
  final DateTime? lastScanReset;

  UserModel({
    required this.uid,
    this.isPremium = false,
    this.subscriptionExpires,
    this.scansThisMonth = 0,
    this.scanLimit = 10,
    this.lastScanReset,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      isPremium: data['isPremium'] ?? false,
      subscriptionExpires: data['subscriptionExpires'] != null
          ? (data['subscriptionExpires'] as Timestamp).toDate()
          : null,
      scansThisMonth: data['scansThisMonth'] ?? 0,
      scanLimit: data['scanLimit'] ?? 10,
      lastScanReset: data['lastScanReset'] != null
          ? (data['lastScanReset'] as Timestamp).toDate()
          : null,
    );
  }

  bool get hasScansRemaining => isPremium || scansThisMonth < scanLimit;
  int get remainingScans => isPremium ? -1 : (scanLimit - scansThisMonth).clamp(0, scanLimit);
  
  bool get isSubscriptionActive {
    if (!isPremium || subscriptionExpires == null) return false;
    return subscriptionExpires!.isAfter(DateTime.now());
  }
}
```

#### Step 3.3: Services

**lib/services/auth_service.dart:**
```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      throw Exception('Anonymous sign-in failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }
}
```

**lib/services/firestore_service.dart:**
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/document_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  // User operations
  Stream<UserModel?> getUserStream() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<UserModel?> getUser() async {
    final doc = await _firestore.collection('users').doc(_userId).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  // Document operations
  Stream<List<DocumentModel>> getDocumentsStream() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('documents')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DocumentModel.fromFirestore(doc)).toList());
  }

  Future<void> addDocument(DocumentModel document) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('documents')
        .doc(document.id)
        .set(document.toFirestore());
  }

  Future<void> updateDocument(String documentId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = Timestamp.now();
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('documents')
        .doc(documentId)
        .update(updates);
  }

  Future<void> deleteDocument(String documentId) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('documents')
        .doc(documentId)
        .delete();
  }
}
```

**lib/services/storage_service.dart:**
```dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  Future<String> uploadDocument(File file, String documentId) async {
    try {
      final ref = _storage
          .ref()
          .child('users')
          .child(_userId)
          .child('documents')
          .child('$documentId.pdf');

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'application/pdf',
          customMetadata: {
            'userId': _userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  Future<String> uploadThumbnail(File file, String documentId) async {
    try {
      final ref = _storage
          .ref()
          .child('users')
          .child(_userId)
          .child('thumbnails')
          .child('$documentId.jpg');

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Thumbnail upload failed: $e');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await _storage
          .ref()
          .child('users')
          .child(_userId)
          .child('documents')
          .child('$documentId.pdf')
          .delete();

      await _storage
          .ref()
          .child('users')
          .child(_userId)
          .child('thumbnails')
          .child('$documentId.jpg')
          .delete();
    } catch (e) {
      print('Delete error: $e');
    }
  }
}
```

#### Step 3.4: Providers (State Management)

**lib/providers/auth_provider.dart:**
```dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null;

  Future<void> initializeAuth() async {
    _authService.authStateChanges.listen((user) {
      _user = user;
      _isInitialized = true;
      notifyListeners();
    });

    // Sign in anonymously if no user
    if (_authService.currentUser == null) {
      await _authService.signInAnonymously();
    } else {
      _user = _authService.currentUser;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
```

**lib/providers/subscription_provider.dart:**
```dart
import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class SubscriptionProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  UserModel? _user;
  bool _isLoading = false;

  bool get isPremium => _user?.isSubscriptionActive ?? false;
  int get scansRemaining => _user?.remainingScans ?? 0;
  bool get isLoading => _isLoading;
  DateTime? get subscriptionExpires => _user?.subscriptionExpires;
  int get scansThisMonth => _user?.scansThisMonth ?? 0;

  void initialize() {
    _firestoreService.getUserStream().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<Map<String, dynamic>> recordScan() async {
    try {
      final recordScan = _functions.httpsCallable('recordScan');
      final result = await recordScan.call();
      return result.data as Map<String, dynamic>;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Failed to record scan');
    }
  }

  Future<bool> verifySubscription(String receiptData, String platform) async {
    _isLoading = true;
    notifyListeners();

    try {
      final verifySubscription = _functions.httpsCallable('verifySubscription');
      final result = await verifySubscription.call({
        'receiptData': receiptData,
        'platform': platform,
      });

      _isLoading = false;
      notifyListeners();

      return result.data['success'] == true;
    } on FirebaseFunctionsException catch (e) {
      _isLoading = false;
      notifyListeners();
      
      throw Exception(e.message ?? 'Subscription verification failed');
    }
  }

  Future<String?> performOcr(String imageUrl) async {
    if (!isPremium) {
      throw Exception('Premium subscription required for OCR');
    }

    try {
      final performOcr = _functions.httpsCallable('performOcr');
      final result = await performOcr.call({'imageUrl': imageUrl});

      if (result.data['success'] == true) {
        return result.data['text'];
      }
      return null;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'OCR failed');
    }
  }
}
```

#### Step 3.5: Screens

**lib/screens/home_screen.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../services/firestore_service.dart';
import '../models/document_model.dart';
import 'camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionProvider>().initialize();
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );

    if (result != null) {
      // Document saved, refresh list
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Documents'),
        elevation: 0,
        actions: [
          if (!subscriptionProvider.isPremium)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${subscriptionProvider.scansRemaining}/10',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!subscriptionProvider.isPremium) _buildPremiumBanner(context),
          Expanded(child: _buildDocumentsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCamera,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to premium screen
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade500],
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Upgrade to Premium - Unlimited Scans & AI Features',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    return StreamBuilder<List<DocumentModel>>(
      stream: _firestoreService.getDocumentsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final documents = snapshot.data ?? [];

        if (documents.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final doc = documents[index];
            return _DocumentCard(document: doc);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.document_scanner, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Documents Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to scan your first document',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentModel document;

  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.description, color: Colors.blue),
        ),
        title: Text(
          document.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${document.createdAt.day}/${document.createdAt.month}/${document.createdAt.year}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to document detail
        },
      ),
    );
  }
}
```

**lib/screens/camera_screen.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // 🔒 Check scan limit server-side BEFORE capturing
      final subscriptionProvider = context.read<SubscriptionProvider>();
      final result = await subscriptionProvider.recordScan();

      if (result['success'] == true) {
        // Allowed to scan
        final image = await _controller!.takePicture();
        
        if (mounted) {
          // TODO: Process and save image
          Navigator.pop(context, image.path);
        }
      }
    } catch (e) {
      if (e.toString().contains('Scan limit reached')) {
        _showUpgradeDialog();
      } else {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Limit Reached'),
        content: const Text(
          'You\'ve used all 10 free scans this month. Upgrade to Premium for unlimited scans!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to premium screen
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                    if (!subscriptionProvider.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${subscriptionProvider.scansRemaining}/10',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Capture button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isProcessing ? null : _takePicture,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 3),
                  ),
                  child: _isProcessing
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Step 3.6: Theme

**lib/theme/app_theme.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }
}
```

---

## 6. TESTING STRATEGY

### Unit Tests
```dart
// test/services/firestore_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('FirestoreService', () {
    test('should add document', () async {
      // Test implementation
    });

    test('should get user documents', () async {
      // Test implementation
    });
  });
}
```

### Integration Tests
```bash
# Run Flutter integration tests
flutter test integration_test/app_test.dart
```

### Firebase Emulator Testing
```bash
# Start emulators
firebase emulators:start

# Run tests against emulators
flutter test --dart-define=USE_FIREBASE_EMULATOR=true
```

---

## 7. DEPLOYMENT GUIDE

### Build Release Versions

**Android:**
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS:**
```bash
# Build for iOS (requires Mac + Xcode)
flutter build ios --release

# Or use EAS Build (no Mac required)
# Configure in eas.json
```

### Deploy Backend
```bash
# Deploy everything
firebase deploy

# Or specific services
firebase deploy --only firestore:rules
firebase deploy --only storage
firebase deploy --only functions
```

### App Store Submission

**iOS (App Store Connect):**
1. Create app in App Store Connect
2. Configure metadata (name, description, screenshots)
3. Set up in-app purchases
4. Upload build via Xcode or Transporter
5. Submit for review (typically 1-3 days)

**Android (Google Play Console):**
1. Create app in Play Console
2. Fill out store listing
3. Configure in-app products
4. Upload AAB file
5. Submit for review (typically 1-7 days)

---

## 8. COST ANALYSIS

### Development Costs
| Item | Cost |
|------|------|
| Flutter/Dart | FREE |
| Firebase Free Tier | FREE |
| VS Code/Android Studio | FREE |
| **Total Development** | **$0** |

### Launch Costs (One-Time)
| Item | Cost |
|------|------|
| Apple Developer Account | $99/year |
| Google Play Console | $25 one-time |
| **Total Launch** | **$124** |

### Monthly Operating Costs

**0-100 Users (MVP):**
| Service | Cost |
|---------|------|
| Firebase (Free Tier) | $0 |
| RevenueCat (Free Tier) | $0 |
| **Total** | **$0/month** |

**100-1000 Users:**
| Service | Cost |
|---------|------|
| Firebase Blaze | $25-50 |
| RevenueCat | $0 (< $10K MRR) |
| **Total** | **$25-50/month** |

**1000-10000 Users:**
| Service | Cost |
|---------|------|
| Firebase | $100-200 |
| Google Cloud Vision (OCR) | $50-100 |
| RevenueCat | 1% of revenue OR $0 |
| **Total** | **$150-300/month** |
| **Revenue** | **$300-1000/month** |
| **Profit** | **$0-700/month** ✅ |

### Break-Even Analysis
- **At $10/month costs**: Need 2 monthly subscribers ($4.99 x 2 = $9.98)
- **At $50/month costs**: Need 10 monthly or 2 yearly subscribers
- **At $200/month costs**: Need 40 monthly or 7 yearly subscribers

Typical conversion rate: 3-5% free to paid  
With 1000 users: 30-50 premium = $150-250/month revenue

---

## 9. TIMELINE & MILESTONES

### Week 0: Preparation (2-3 days)
- [ ] Install Flutter & tools
- [ ] Create Firebase project
- [ ] Set up Apple Developer account
- [ ] Set up Google Play Console account
- [ ] Design app icon & splash screen

### Week 1: Development (3-4 days)
**Day 1: Backend Setup**
- [ ] Initialize Firebase project
- [ ] Create Cloud Functions
- [ ] Deploy security rules
- [ ] Test Cloud Functions locally

**Day 2: Core Features**
- [ ] Implement authentication
- [ ] Build camera functionality
- [ ] Create document storage
- [ ] Implement scan limit logic

**Day 3: UI & Premium**
- [ ] Build all screens
- [ ] Implement state management
- [ ] Create premium screen
- [ ] Integrate RevenueCat

**Day 4: Testing & Polish**
- [ ] Test all features
- [ ] Fix bugs
- [ ] UI/UX improvements
- [ ] Performance optimization

### Week 2: Launch (5-7 days)
**Day 5-6: App Store Assets**
- [ ] Create screenshots (iOS & Android)
- [ ] Write app description
- [ ] Create promotional graphics
- [ ] Prepare privacy policy

**Day 7: Submission**
- [ ] Build release versions
- [ ] Deploy backend to production
- [ ] Submit to App Store
- [ ] Submit to Google Play

**Day 8-14: Review & Launch**
- [ ] Wait for app review
- [ ] Fix any review issues
- [ ] Soft launch in 1-2 countries
- [ ] Monitor for critical bugs

### Month 2: Growth
- [ ] Full international launch
- [ ] ASO optimization
- [ ] Social media presence
- [ ] Collect user feedback
- [ ] Add most-requested features

### Month 3: Optimization
- [ ] A/B test pricing
- [ ] Optimize conversion funnel
- [ ] Add advanced features
- [ ] Referral program
- [ ] Marketing campaigns

---

## 10. SUCCESS METRICS

### User Metrics
| Metric | Target (Month 3) | Target (Month 6) | Target (Month 12) |
|--------|------------------|------------------|-------------------|
| Total Downloads | 500-1000 | 5000-10000 | 20000-50000 |
| DAU (Daily Active Users) | 50-100 | 500-1000 | 2000-5000 |
| MAU (Monthly Active Users) | 200-500 | 2000-5000 | 10000-25000 |
| Day 1 Retention | 40% | 50% | 60% |
| Day 7 Retention | 20% | 25% | 30% |
| Day 30 Retention | 10% | 15% | 20% |

### Revenue Metrics
| Metric | Month 3 | Month 6 | Month 12 |
|--------|---------|---------|----------|
| Free to Premium Conversion | 2% | 3% | 5% |
| Monthly Subscribers | 10-20 | 60-150 | 500-1250 |
| Yearly Subscribers | 2-5 | 10-25 | 100-250 |
| MRR (Monthly Recurring Revenue) | $50-150 | $300-750 | $2500-6250 |
| Churn Rate | <10% | <8% | <5% |
| LTV (Customer Lifetime Value) | $15-30 | $25-50 | $50-100 |

### Product Metrics
| Metric | Target |
|--------|--------|
| App Store Rating | 4.5+ stars |
| Crash-Free Rate | 99.5%+ |
| Average Session Length | 3-5 minutes |
| Scans Per User (Free) | 5-8/month |
| Scans Per User (Premium) | 20-50/month |

### Financial Goals
- **Month 1-2**: $0-50 revenue (validation phase)
- **Month 3**: Break-even ($150-200 revenue vs $50-100 costs)
- **Month 6**: $300-750 revenue, $150-300 profit
- **Month 12**: $2500-6250 revenue, $2000-6000 profit

---

## 11. APPENDIX & RESOURCES

### Documentation Links
- **Flutter**: https://docs.flutter.dev
- **Firebase**: https://firebase.google.com/docs
- **RevenueCat**: https://www.revenuecat.com/docs
- **Google Cloud Vision**: https://cloud.google.com/vision/docs

### Community Resources
- **Flutter Community**: https://flutter.dev/community
- **r/FlutterDev**: Reddit community
- **Flutter Discord**: https://discord.gg/flutter
- **Stack Overflow**: Tag [flutter]

### Design Resources
- **Material Design**: https://m3.material.io
- **Flutter Awesome**: https://flutterawesome.com
- **Dribbble**: Design inspiration
- **Figma Community**: Free templates

### Learning Resources
- **Flutter Codelabs**: https://docs.flutter.dev/codelabs
- **Firebase YouTube**: Official tutorials
- **Fireship.io**: Quick tutorials
- **Flutter & Firebase Course**: Udemy/YouTube

### Tools
- **FlutterFire CLI**: Firebase configuration
- **Fastlane**: Automate deployments
- **Codemagic**: CI/CD for Flutter
- **Sentry**: Error tracking

### Legal Templates
- **Privacy Policy Generator**: https://www.privacypolicygenerator.info
- **Terms Generator**: https://www.termsandconditionsgenerator.com

---

## FINAL CHECKLIST

### Pre-Development
- [ ] Flutter SDK installed and verified
- [ ] Firebase project created
- [ ] Git repository initialized
- [ ] Developer accounts registered

### Development Complete
- [ ] All features implemented
- [ ] Security rules deployed
- [ ] Cloud Functions tested
- [ ] No secrets in code
- [ ] App tested on physical devices

### Pre-Launch
- [ ] App icon created (1024x1024)
- [ ] Screenshots prepared (all sizes)
- [ ] Privacy policy published
- [ ] Terms of service published
- [ ] In-app purchases configured
- [ ] Analytics implemented

### Launch Day
- [ ] Backend deployed to production
- [ ] Release builds created
- [ ] App Store submission complete
- [ ] Google Play submission complete
- [ ] Social media announcements ready

### Post-Launch (Week 1)
- [ ] Monitor crashlytics daily
- [ ] Respond to user reviews
- [ ] Fix critical bugs immediately
- [ ] Track key metrics
- [ ] Prepare updates based on feedback

---

## 🚀 YOU'RE READY TO BUILD!

This comprehensive project brief contains everything needed to build a production-ready, secure document scanner app with Flutter. The security-first architecture ensures your app is protected from day one, while the detailed implementation guide gets you from zero to launch in 1-2 weeks.

**Key Takeaways:**
- ✅ Complete security: All sensitive operations on backend
- ✅ Scalable architecture: Firebase handles growth automatically
- ✅ Clear monetization: Freemium model with proven conversion rates
- ✅ Fast development: Flutter enables rapid iteration
- ✅ Production-ready: Built to handle thousands of users

**Next Steps:**
1. Set up your development environment
2. Follow Phase 1 to initialize the project
3. Implement features phase by phase
4. Test thoroughly with emulators
5. Deploy and launch!

Good luck building your app! 🎉
