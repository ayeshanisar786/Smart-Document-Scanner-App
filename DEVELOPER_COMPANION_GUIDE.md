# Smart Scanner - Developer's Companion Guide
## Everything Else You Need for Perfect Architecture & Rapid Development

**Companion to**: MASTER_PROJECT_BRIEF.md  
**Purpose**: Quick reference, troubleshooting, schemas, scripts, and best practices  
**Use**: Keep this open while coding

---

## 📋 TABLE OF CONTENTS

1. [5-Minute Quick Start](#5-minute-quick-start)
2. [Exact Database Schemas](#exact-database-schemas)
3. [Complete API Reference](#complete-api-reference)
4. [Environment Setup Scripts](#environment-setup-scripts)
5. [Reusable Component Library](#reusable-component-library)
6. [Code Snippets Library](#code-snippets-library)
7. [Testing Procedures](#testing-procedures)
8. [Troubleshooting Guide](#troubleshooting-guide)
9. [Performance Optimization](#performance-optimization)
10. [Deployment Scripts](#deployment-scripts)
11. [Monitoring & Analytics](#monitoring--analytics)
12. [App Store Optimization (ASO)](#app-store-optimization)
13. [Post-Launch Maintenance](#post-launch-maintenance)
14. [Common Patterns](#common-patterns)
15. [Security Checklist](#security-checklist)

---

## 1. 5-MINUTE QUICK START

### Get Running in 5 Minutes

```bash
# 1. Clone or create project (30 seconds)
flutter create smart_scanner
cd smart_scanner

# 2. Add Firebase (1 minute)
dart pub global activate flutterfire_cli
flutterfire configure

# 3. Copy dependencies (30 seconds)
# Copy pubspec.yaml from MASTER_PROJECT_BRIEF.md

# 4. Install dependencies (1 minute)
flutter pub get

# 5. Initialize Firebase Functions (1 minute)
firebase init functions
# Select JavaScript, ESLint Yes, Install Yes

# 6. Run on emulator (1 minute)
flutter run

# 🎉 DONE! App running in 5 minutes
```

### Verify Everything Works

```bash
# Check Flutter
flutter doctor

# Check Firebase
firebase projects:list

# Test Cloud Functions locally
cd functions
npm run serve

# Run app with emulator
flutter run
```

---

## 2. EXACT DATABASE SCHEMAS

### Firestore Collections Structure

```
smart_scanner (project)
│
├── users (collection)
│   └── {userId} (document)
│       ├── createdAt: Timestamp
│       ├── isPremium: boolean
│       ├── subscriptionExpires: Timestamp | null
│       ├── subscriptionPlatform: string | null ("ios" | "android")
│       ├── subscriptionProductId: string | null
│       ├── scansThisMonth: number (0-10 for free, unlimited for premium)
│       ├── scanLimit: number (10 for free, -1 for premium)
│       ├── lastScanReset: Timestamp
│       ├── lastScanDate: Timestamp | null
│       └── subscriptionVerifiedAt: Timestamp | null
│       │
│       └── documents (subcollection)
│           └── {documentId} (document)
│               ├── name: string
│               ├── thumbnailUrl: string (Firebase Storage URL)
│               ├── documentUrl: string (Firebase Storage URL)
│               ├── createdAt: Timestamp
│               ├── updatedAt: Timestamp
│               ├── pageCount: number (default: 1)
│               ├── fileSize: number (bytes)
│               ├── isFavorite: boolean
│               ├── ocrText: string | null (premium only)
│               └── tags: array<string>
│
└── rateLimits (collection)
    └── {userId} (document)
        └── actions (subcollection)
            └── {actionName} (document) - e.g., "ocr", "scan"
                ├── attempts: array<number> (timestamps)
                └── lastUpdated: Timestamp
```

### Firebase Storage Structure

```
smart_scanner.appspot.com (bucket)
│
└── users/
    └── {userId}/
        ├── documents/
        │   ├── {documentId}.pdf
        │   ├── {documentId2}.pdf
        │   └── ...
        │
        └── thumbnails/
            ├── {documentId}.jpg
            ├── {documentId2}.jpg
            └── ...
```

### Example Firestore Document

**User Document:**
```json
{
  "createdAt": "2024-01-15T10:30:00Z",
  "isPremium": false,
  "subscriptionExpires": null,
  "subscriptionPlatform": null,
  "subscriptionProductId": null,
  "scansThisMonth": 3,
  "scanLimit": 10,
  "lastScanReset": "2024-01-01T00:00:00Z",
  "lastScanDate": "2024-01-15T10:30:00Z",
  "subscriptionVerifiedAt": null
}
```

**Document Document:**
```json
{
  "name": "Receipt_Jan_2024",
  "thumbnailUrl": "https://storage.googleapis.com/smart_scanner.appspot.com/users/abc123/thumbnails/doc123.jpg",
  "documentUrl": "https://storage.googleapis.com/smart_scanner.appspot.com/users/abc123/documents/doc123.pdf",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z",
  "pageCount": 1,
  "fileSize": 524288,
  "isFavorite": false,
  "ocrText": null,
  "tags": ["receipt", "business"]
}
```

---

## 3. COMPLETE API REFERENCE

### Cloud Functions API

#### 1. recordScan
**Purpose**: Validate and record a scan attempt  
**Auth**: Required  
**Type**: Callable Function

**Request:**
```javascript
// No parameters needed, uses context.auth.uid
const result = await functions.httpsCallable('recordScan').call();
```

**Response:**
```javascript
{
  success: true,
  unlimited: false,      // true if premium user
  scansRemaining: 7      // -1 if unlimited
}
```

**Errors:**
```javascript
// Unauthenticated
{
  code: 'unauthenticated',
  message: 'Must be authenticated'
}

// Scan limit reached
{
  code: 'resource-exhausted',
  message: 'Scan limit reached. Upgrade to Premium.'
}
```

#### 2. verifySubscription
**Purpose**: Verify subscription purchase with Apple/Google  
**Auth**: Required  
**Type**: Callable Function

**Request:**
```javascript
const result = await functions.httpsCallable('verifySubscription').call({
  receiptData: 'base64_receipt_string',
  platform: 'ios', // or 'android'
  productId: 'premium_monthly'
});
```

**Response:**
```javascript
{
  success: true,
  expiresAt: '2024-02-15T10:30:00Z'
}
```

**Errors:**
```javascript
{
  success: false,
  error: 'Invalid receipt'
}
```

#### 3. performOcr
**Purpose**: Extract text from image (Premium only)  
**Auth**: Required + Premium  
**Type**: Callable Function

**Request:**
```javascript
const result = await functions.httpsCallable('performOcr').call({
  imageUrl: 'https://storage.googleapis.com/.../image.jpg'
});
```

**Response:**
```javascript
{
  success: true,
  text: 'Extracted text content here...'
}
```

**Errors:**
```javascript
// Not premium
{
  code: 'permission-denied',
  message: 'Premium subscription required for OCR'
}

// Rate limit
{
  code: 'resource-exhausted',
  message: 'Rate limit exceeded. Try again later.'
}
```

### Rate Limits

| Function | Free Users | Premium Users |
|----------|------------|---------------|
| recordScan | 10/month | Unlimited |
| performOcr | N/A | 50/hour |
| verifySubscription | Unlimited | Unlimited |

---

## 4. ENVIRONMENT SETUP SCRIPTS

### Automated Setup Script

**setup.sh:**
```bash
#!/bin/bash

echo "🚀 Smart Scanner - Automated Setup Script"
echo "=========================================="

# Check Flutter
echo "📱 Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi
echo "✅ Flutter found"

# Check Firebase CLI
echo "🔥 Checking Firebase CLI..."
if ! command -v firebase &> /dev/null; then
    echo "📦 Installing Firebase CLI..."
    npm install -g firebase-tools
fi
echo "✅ Firebase CLI ready"

# Check FlutterFire CLI
echo "🔧 Checking FlutterFire CLI..."
if ! command -v flutterfire &> /dev/null; then
    echo "📦 Installing FlutterFire CLI..."
    dart pub global activate flutterfire_cli
fi
echo "✅ FlutterFire CLI ready"

# Flutter doctor
echo "🏥 Running Flutter doctor..."
flutter doctor

# Get dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Firebase login
echo "🔐 Firebase login..."
firebase login

# Configure FlutterFire
echo "⚙️  Configuring Firebase..."
flutterfire configure

# Initialize Functions
echo "⚡ Setting up Cloud Functions..."
cd functions || exit
npm install
cd ..

echo ""
echo "✅ Setup complete! Next steps:"
echo "1. Deploy Firebase: firebase deploy"
echo "2. Run app: flutter run"
echo ""
```

**Make executable:**
```bash
chmod +x setup.sh
./setup.sh
```

### VS Code Configuration

**.vscode/launch.json:**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "smart_scanner",
      "request": "launch",
      "type": "dart"
    },
    {
      "name": "smart_scanner (profile mode)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile"
    },
    {
      "name": "smart_scanner (release mode)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "release"
    }
  ]
}
```

**.vscode/settings.json:**
```json
{
  "dart.flutterSdkPath": ".flutter",
  "editor.formatOnSave": true,
  "editor.rulers": [80],
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.rulers": [80],
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  }
}
```

### Firebase Configuration

**.firebaserc:**
```json
{
  "projects": {
    "default": "smart-scanner",
    "staging": "smart-scanner-staging",
    "production": "smart-scanner-prod"
  }
}
```

**firebase.json:**
```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "functions": {
    "source": "functions",
    "predeploy": [
      "npm --prefix \"$RESOURCE_DIR\" run lint"
    ]
  },
  "storage": {
    "rules": "storage.rules"
  },
  "emulators": {
    "functions": {
      "port": 5001
    },
    "firestore": {
      "port": 8080
    },
    "storage": {
      "port": 9199
    },
    "ui": {
      "enabled": true,
      "port": 4000
    }
  }
}
```

---

## 5. REUSABLE COMPONENT LIBRARY

### Custom Button

**lib/widgets/common/custom_button.dart:**
```dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Theme.of(context).primaryColor;

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildChild(buttonColor),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildChild(Colors.white),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}
```

### Empty State Widget

**lib/widgets/common/empty_state.dart:**
```dart
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Loading Overlay

**lib/widgets/common/loading_overlay.dart:**
```dart
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(message!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

### Error Dialog

**lib/widgets/common/error_dialog.dart:**
```dart
import 'package:flutter/material.dart';

class ErrorDialog {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. CODE SNIPPETS LIBRARY

### Firestore Queries

**Get user documents with pagination:**
```dart
Future<List<DocumentModel>> getDocumentsPaginated({
  int limit = 20,
  DocumentSnapshot? startAfter,
}) async {
  Query query = _firestore
      .collection('users')
      .doc(_userId)
      .collection('documents')
      .orderBy('createdAt', descending: true)
      .limit(limit);

  if (startAfter != null) {
    query = query.startAfterDocument(startAfter);
  }

  final snapshot = await query.get();
  return snapshot.docs
      .map((doc) => DocumentModel.fromFirestore(doc))
      .toList();
}
```

**Search documents by name:**
```dart
Future<List<DocumentModel>> searchDocuments(String searchQuery) async {
  final snapshot = await _firestore
      .collection('users')
      .doc(_userId)
      .collection('documents')
      .where('name', isGreaterThanOrEqualTo: searchQuery)
      .where('name', isLessThan: searchQuery + '\uf8ff')
      .orderBy('name')
      .limit(20)
      .get();

  return snapshot.docs
      .map((doc) => DocumentModel.fromFirestore(doc))
      .toList();
}
```

**Get favorite documents:**
```dart
Stream<List<DocumentModel>> getFavoriteDocuments() {
  return _firestore
      .collection('users')
      .doc(_userId)
      .collection('documents')
      .where('isFavorite', isEqualTo: true)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc))
          .toList());
}
```

### File Handling

**Compress image before upload:**
```dart
import 'package:image/image.dart' as img;
import 'dart:io';

Future<File> compressImage(File file, {int quality = 85}) async {
  final bytes = await file.readAsBytes();
  final image = img.decodeImage(bytes);
  
  if (image == null) throw Exception('Failed to decode image');

  // Resize if too large
  img.Image resized = image;
  if (image.width > 1920 || image.height > 1920) {
    resized = img.copyResize(
      image,
      width: image.width > image.height ? 1920 : null,
      height: image.height > image.width ? 1920 : null,
    );
  }

  // Compress
  final compressed = img.encodeJpg(resized, quality: quality);

  // Save to temp file
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
  await tempFile.writeAsBytes(compressed);

  return tempFile;
}
```

**Generate thumbnail:**
```dart
Future<File> generateThumbnail(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final image = img.decodeImage(bytes);
  
  if (image == null) throw Exception('Failed to decode image');

  // Create thumbnail (300x300)
  final thumbnail = img.copyResize(
    image,
    width: 300,
    height: 300,
    interpolation: img.Interpolation.average,
  );

  // Encode as JPEG
  final thumbnailBytes = img.encodeJpg(thumbnail, quality: 75);

  // Save
  final tempDir = await getTemporaryDirectory();
  final thumbnailFile = File('${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg');
  await thumbnailFile.writeAsBytes(thumbnailBytes);

  return thumbnailFile;
}
```

### PDF Generation

**Create PDF from image:**
```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

Future<File> createPdfFromImage(File imageFile, String fileName) async {
  final pdf = pw.Document();
  final image = pw.MemoryImage(await imageFile.readAsBytes());

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Center(
          child: pw.Image(image, fit: pw.BoxFit.contain),
        );
      },
    ),
  );

  // Save PDF
  final output = await getTemporaryDirectory();
  final file = File('${output.path}/$fileName.pdf');
  await file.writeAsBytes(await pdf.save());

  return file;
}
```

**Create multi-page PDF:**
```dart
Future<File> createMultiPagePdf(List<File> imageFiles, String fileName) async {
  final pdf = pw.Document();

  for (final imageFile in imageFiles) {
    final image = pw.MemoryImage(await imageFile.readAsBytes());
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ),
    );
  }

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/$fileName.pdf');
  await file.writeAsBytes(await pdf.save());

  return file;
}
```

### Error Handling

**Generic error handler:**
```dart
Future<T?> handleAsyncOperation<T>({
  required Future<T> Function() operation,
  required BuildContext context,
  String? errorTitle,
  bool showLoading = true,
}) async {
  if (showLoading) {
    // Show loading indicator
  }

  try {
    final result = await operation();
    return result;
  } on FirebaseException catch (e) {
    if (context.mounted) {
      ErrorDialog.show(
        context,
        title: errorTitle ?? 'Firebase Error',
        message: e.message ?? 'An error occurred',
      );
    }
    return null;
  } catch (e) {
    if (context.mounted) {
      ErrorDialog.show(
        context,
        title: errorTitle ?? 'Error',
        message: e.toString(),
      );
    }
    return null;
  } finally {
    if (showLoading) {
      // Hide loading indicator
    }
  }
}
```

---

## 7. TESTING PROCEDURES

### Unit Tests

**Test Firestore Service:**
```dart
// test/services/firestore_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(signedIn: true);
  });

  group('FirestoreService', () {
    test('should create user document', () async {
      final userId = auth.currentUser!.uid;
      
      await firestore.collection('users').doc(userId).set({
        'isPremium': false,
        'scansThisMonth': 0,
        'scanLimit': 10,
      });

      final doc = await firestore.collection('users').doc(userId).get();
      expect(doc.exists, true);
      expect(doc.data()?['isPremium'], false);
    });

    test('should add document to user collection', () async {
      final userId = auth.currentUser!.uid;
      final docId = 'test_doc_1';

      await firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .doc(docId)
          .set({
        'name': 'Test Document',
        'createdAt': DateTime.now(),
      });

      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .doc(docId)
          .get();

      expect(doc.exists, true);
      expect(doc.data()?['name'], 'Test Document');
    });
  });
}
```

### Widget Tests

**Test Home Screen:**
```dart
// test/screens/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Home screen shows empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            // Mock providers
          ],
          child: const HomeScreen(),
        ),
      ),
    );

    expect(find.text('No Documents Yet'), findsOneWidget);
  });

  testWidgets('Home screen shows document list', (tester) async {
    // Test with mock documents
  });
}
```

### Integration Tests

**test_driver/app_test.dart:**
```dart
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Smart Scanner App', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('can scan document', () async {
      // Tap scan button
      await driver.tap(find.byValueKey('scan_button'));

      // Wait for camera screen
      await driver.waitFor(find.byValueKey('camera_view'));

      // Tap capture
      await driver.tap(find.byValueKey('capture_button'));

      // Verify document saved
      await driver.waitFor(find.text('Document saved'));
    });

    test('shows upgrade prompt when limit reached', () async {
      // Simulate 10 scans
      for (int i = 0; i < 10; i++) {
        await driver.tap(find.byValueKey('scan_button'));
        await driver.tap(find.byValueKey('capture_button'));
      }

      // Try 11th scan
      await driver.tap(find.byValueKey('scan_button'));

      // Should show upgrade dialog
      await driver.waitFor(find.text('Scan Limit Reached'));
    });
  });
}
```

### Cloud Functions Testing

**functions/test/index.test.js:**
```javascript
const test = require('firebase-functions-test')();
const admin = require('firebase-admin');

describe('Cloud Functions', () => {
  let myFunctions;

  before(() => {
    myFunctions = require('../index');
  });

  after(() => {
    test.cleanup();
  });

  describe('recordScan', () => {
    it('should increment scan count', async () => {
      const userId = 'test_user_123';
      
      // Mock context
      const context = {
        auth: { uid: userId }
      };

      // Create user document
      await admin.firestore().collection('users').doc(userId).set({
        scansThisMonth: 0,
        scanLimit: 10,
        isPremium: false,
      });

      // Call function
      const result = await myFunctions.recordScan({}, context);

      expect(result.success).toBe(true);
      expect(result.scansRemaining).toBe(9);

      // Verify scan count incremented
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(userId)
        .get();
      
      expect(userDoc.data().scansThisMonth).toBe(1);
    });

    it('should reject when limit reached', async () => {
      const userId = 'test_user_456';
      
      await admin.firestore().collection('users').doc(userId).set({
        scansThisMonth: 10,
        scanLimit: 10,
        isPremium: false,
      });

      const context = { auth: { uid: userId } };

      try {
        await myFunctions.recordScan({}, context);
        fail('Should have thrown error');
      } catch (error) {
        expect(error.code).toBe('resource-exhausted');
      }
    });
  });
});
```

---

## 8. TROUBLESHOOTING GUIDE

### Common Issues & Solutions

#### Issue: "Firebase not initialized"
```
Error: [core/no-app] No Firebase App '[DEFAULT]' has been created
```

**Solution:**
```dart
// Ensure this in main.dart before runApp()
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

#### Issue: "Pod install failed" (iOS)
```
Error: CocoaPods not installed or not in valid state
```

**Solution:**
```bash
# Update CocoaPods
sudo gem install cocoapods

# Go to iOS folder
cd ios

# Clean and reinstall
rm -rf Pods Podfile.lock
pod install --repo-update

# Go back
cd ..

# Clean Flutter
flutter clean
flutter pub get
```

#### Issue: "Gradle build failed" (Android)
```
Error: Execution failed for task ':app:processDebugResources'
```

**Solution:**
```bash
# Clean Flutter
flutter clean

# Go to Android folder
cd android

# Clean Gradle
./gradlew clean

# Go back
cd ..

# Get dependencies
flutter pub get

# Try again
flutter run
```

#### Issue: "Permission denied" for Camera
```
Error: Camera permission not granted
```

**Solution:**

**Android (android/app/src/main/AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

**iOS (ios/Runner/Info.plist):**
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan documents</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to import documents</string>
```

#### Issue: Cloud Function not found
```
Error: Function not found: recordScan
```

**Solution:**
```bash
# Check if functions are deployed
firebase functions:list

# If not deployed
cd functions
npm install
cd ..
firebase deploy --only functions

# Verify deployment
firebase functions:log
```

#### Issue: Firestore permission denied
```
Error: PERMISSION_DENIED: Missing or insufficient permissions
```

**Solution:**
```bash
# Check security rules
firebase firestore:rules:get

# Deploy rules
firebase deploy --only firestore:rules

# Test rules
firebase emulators:start --only firestore
```

#### Issue: Storage upload fails
```
Error: Upload failed: Unauthorized
```

**Solution:**
```bash
# Deploy storage rules
firebase deploy --only storage

# Verify user is authenticated
# Check Firebase Auth in console
```

### Debug Mode Tips

**Enable verbose logging:**
```dart
// main.dart
void main() async {
  // Enable detailed logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const MyApp());
}
```

**Firebase emulator debugging:**
```bash
# Start with debug port
firebase emulators:start --inspect-functions

# View functions logs
firebase functions:log --only recordScan

# View Firestore operations
# Open: http://localhost:4000
```

---

## 9. PERFORMANCE OPTIMIZATION

### Image Optimization

**Compress before upload:**
```dart
Future<File> optimizeImageForUpload(File imageFile) async {
  // 1. Decode image
  final bytes = await imageFile.readAsBytes();
  final image = img.decodeImage(bytes);
  
  if (image == null) throw Exception('Invalid image');

  // 2. Resize if too large
  img.Image optimized = image;
  const maxDimension = 1920;
  
  if (image.width > maxDimension || image.height > maxDimension) {
    optimized = img.copyResize(
      image,
      width: image.width > image.height ? maxDimension : null,
      height: image.height > image.width ? maxDimension : null,
    );
  }

  // 3. Compress
  final compressed = img.encodeJpg(optimized, quality: 85);

  // 4. Save
  final output = await getTemporaryDirectory();
  final optimizedFile = File('${output.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg');
  await optimizedFile.writeAsBytes(compressed);

  return optimizedFile;
}
```

### Firestore Optimization

**Batch writes for multiple operations:**
```dart
Future<void> batchUpdateDocuments(List<String> documentIds, Map<String, dynamic> updates) async {
  final batch = _firestore.batch();

  for (final docId in documentIds) {
    final docRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('documents')
        .doc(docId);
    
    batch.update(docRef, updates);
  }

  await batch.commit();
}
```

**Use collection group queries:**
```dart
// Search across all users' documents (admin only)
Future<List<DocumentModel>> searchAllDocuments(String query) async {
  final snapshot = await _firestore
      .collectionGroup('documents')
      .where('name', isGreaterThanOrEqualTo: query)
      .limit(20)
      .get();

  return snapshot.docs
      .map((doc) => DocumentModel.fromFirestore(doc))
      .toList();
}
```

### Storage Optimization

**Use Firebase Storage CDN:**
```dart
// Add token for CDN caching
Future<String> getOptimizedDownloadUrl(String path) async {
  final ref = _storage.ref(path);
  final url = await ref.getDownloadURL();
  
  // Firebase CDN automatically caches
  return url;
}
```

**Implement progressive loading:**
```dart
// Load thumbnail first, then full image
class ProgressiveImage extends StatelessWidget {
  final String thumbnailUrl;
  final String fullImageUrl;

  const ProgressiveImage({
    required this.thumbnailUrl,
    required this.fullImageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInImage.memoryNetwork(
      placeholder: kTransparentImage,
      image: fullImageUrl,
      imageErrorBuilder: (context, error, stackTrace) {
        return Image.network(thumbnailUrl);
      },
    );
  }
}
```

### App Performance

**Lazy load screens:**
```dart
// Don't load all screens at once
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/camera':
        // Lazy load
        return MaterialPageRoute(
          builder: (_) => const CameraScreen(),
        );
      case '/premium':
        return MaterialPageRoute(
          builder: (_) => const PremiumScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
        );
    }
  }
}
```

**Use const constructors:**
```dart
// Good - const constructor
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Text('Hello'); // const widget
  }
}

// Bad - non-const
class MyWidget extends StatelessWidget {
  MyWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Text('Hello'); // rebuilds every time
  }
}
```

---

## 10. DEPLOYMENT SCRIPTS

### Automated Build Script

**build.sh:**
```bash
#!/bin/bash

echo "🏗️  Building Smart Scanner"
echo "=========================="

# Get version from pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | cut -d' ' -f2)
echo "📦 Version: $VERSION"

# Clean
echo "🧹 Cleaning..."
flutter clean
flutter pub get

# Build Android
echo "🤖 Building Android..."
flutter build apk --release
flutter build appbundle --release

# Build iOS (if on Mac)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building iOS..."
    flutter build ios --release
fi

# Create release directory
RELEASE_DIR="releases/$VERSION"
mkdir -p "$RELEASE_DIR"

# Copy builds
echo "📁 Copying builds to $RELEASE_DIR..."
cp build/app/outputs/flutter-apk/app-release.apk "$RELEASE_DIR/"
cp build/app/outputs/bundle/release/app-release.aab "$RELEASE_DIR/"

if [[ "$OSTYPE" == "darwin"* ]]; then
    cp -r build/ios/iphoneos/Runner.app "$RELEASE_DIR/"
fi

echo "✅ Build complete!"
echo "📂 Files in: $RELEASE_DIR"
ls -lh "$RELEASE_DIR"
```

### Firebase Deployment Script

**deploy.sh:**
```bash
#!/bin/bash

echo "🚀 Deploying to Firebase"
echo "========================"

# Check environment
read -p "Deploy to (staging/production): " ENV

if [ "$ENV" = "production" ]; then
    echo "⚠️  Deploying to PRODUCTION"
    read -p "Are you sure? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "❌ Deployment cancelled"
        exit 1
    fi
    firebase use production
else
    echo "📦 Deploying to STAGING"
    firebase use staging
fi

# Deploy Firestore rules
echo "📝 Deploying Firestore rules..."
firebase deploy --only firestore:rules

# Deploy Storage rules
echo "💾 Deploying Storage rules..."
firebase deploy --only storage

# Deploy Cloud Functions
echo "⚡ Deploying Cloud Functions..."
cd functions
npm install
npm run lint
cd ..
firebase deploy --only functions

echo "✅ Deployment complete!"
```

### Pre-Release Checklist Script

**pre-release-check.sh:**
```bash
#!/bin/bash

echo "✅ Pre-Release Checklist"
echo "======================="

ERRORS=0

# Check Flutter
echo -n "Flutter installed: "
if command -v flutter &> /dev/null; then
    echo "✅"
else
    echo "❌"
    ERRORS=$((ERRORS + 1))
fi

# Check tests
echo -n "Running tests: "
if flutter test; then
    echo "✅"
else
    echo "❌"
    ERRORS=$((ERRORS + 1))
fi

# Check for TODOs
echo -n "No TODOs in code: "
if ! grep -r "TODO" lib/; then
    echo "✅"
else
    echo "⚠️  TODOs found"
fi

# Check version
echo -n "Version updated: "
VERSION=$(grep 'version:' pubspec.yaml | cut -d' ' -f2)
echo "$VERSION"

# Check Firebase deployed
echo -n "Firebase functions deployed: "
if firebase functions:list &> /dev/null; then
    echo "✅"
else
    echo "❌"
    ERRORS=$((ERRORS + 1))
fi

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✅ All checks passed! Ready to release."
else
    echo "❌ $ERRORS checks failed. Please fix before releasing."
    exit 1
fi
```

---

## 11. MONITORING & ANALYTICS

### Firebase Analytics Setup

**lib/services/analytics_service.dart:**
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Screen views
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }

  // Scan events
  Future<void> logScanAttempt(bool success) async {
    await _analytics.logEvent(
      name: 'scan_attempt',
      parameters: {
        'success': success,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Premium events
  Future<void> logPremiumUpgrade(String platform, double price) async {
    await _analytics.logEvent(
      name: 'premium_upgrade',
      parameters: {
        'platform': platform,
        'price': price,
        'currency': 'USD',
      },
    );
  }

  Future<void> logPremiumCancellation() async {
    await _analytics.logEvent(name: 'premium_cancellation');
  }

  // Feature usage
  Future<void> logFeatureUsed(String featureName) async {
    await _analytics.logEvent(
      name: 'feature_used',
      parameters: {'feature': featureName},
    );
  }

  // Errors
  Future<void> logError(String errorName, String errorMessage) async {
    await _analytics.logEvent(
      name: 'error_occurred',
      parameters: {
        'error_name': errorName,
        'error_message': errorMessage,
      },
    );
  }
}
```

### Crashlytics Setup

**lib/main.dart:**
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  // Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}
```

**Log custom events:**
```dart
try {
  // Risky operation
  await performScan();
} catch (e, stack) {
  // Log to Crashlytics
  await FirebaseCrashlytics.instance.recordError(
    e,
    stack,
    reason: 'Scan operation failed',
    information: ['User ID: $userId', 'Premium: $isPremium'],
  );
}
```

### Performance Monitoring

**lib/services/performance_service.dart:**
```dart
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  final FirebasePerformance _performance = FirebasePerformance.instance;

  // Track async operations
  Future<T> trackOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final trace = _performance.newTrace(operationName);
    await trace.start();

    try {
      final result = await operation();
      trace.putAttribute('status', 'success');
      return result;
    } catch (e) {
      trace.putAttribute('status', 'error');
      trace.putAttribute('error', e.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  // Track network requests
  Future<T> trackNetworkRequest<T>(
    String url,
    Future<T> Function() request,
  ) async {
    final metric = _performance.newHttpMetric(
      url,
      HttpMethod.Post,
    );
    
    await metric.start();

    try {
      final result = await request();
      metric.responseCode = 200;
      return result;
    } catch (e) {
      metric.responseCode = 500;
      rethrow;
    } finally {
      await metric.stop();
    }
  }
}
```

**Usage:**
```dart
// Track scan operation
final result = await performanceService.trackOperation(
  'document_scan',
  () => documentService.scanDocument(image),
);

// Track OCR call
final text = await performanceService.trackNetworkRequest(
  'https://us-central1-xxx.cloudfunctions.net/performOcr',
  () => performOcr(imageUrl),
);
```

---

## 12. APP STORE OPTIMIZATION (ASO)

### App Store Metadata

**App Name (30 chars max):**
```
Smart Scanner - AI Docs
```

**Subtitle (30 chars max):**
```
PDF Scanner & OCR Text
```

**Keywords (100 chars max):**
```
pdf,scanner,document,ocr,scan,camera,text,business,receipt,mobile
```

**Description Template:**
```
Transform your phone into a powerful document scanner!

SCAN ANYTHING
• Documents, receipts, business cards
• Whiteboards, notes, ID cards
• Contracts, forms, certificates

FREE FEATURES
✓ 10 scans per month
✓ High-quality PDF creation
✓ Basic editing tools
✓ Instant sharing

PREMIUM FEATURES ($4.99/month)
✓ Unlimited scans
✓ AI text extraction (OCR)
✓ Auto-enhancement
✓ Cloud backup & sync
✓ Multi-page PDFs
✓ Advanced organization

PERFECT FOR
• Students scanning notes
• Professionals managing paperwork
• Small businesses tracking receipts
• Anyone going paperless

FEATURES
• Crystal-clear scans every time
• Automatic edge detection
• Multiple filters (B&W, color, grayscale)
• Secure cloud storage
• Cross-device sync
• Search within documents
• Share via email, messaging, cloud

Privacy-first. Secure. Fast.

Download now and get 10 free scans!
```

### Screenshot Captions

**Screenshot 1 - Home Screen:**
```
All your documents in one place
```

**Screenshot 2 - Camera:**
```
Scan documents in seconds
```

**Screenshot 3 - Editor:**
```
Perfect every scan with powerful tools
```

**Screenshot 4 - Premium:**
```
Unlock unlimited scans & AI features
```

**Screenshot 5 - Organization:**
```
Search, organize, and find anything
```

### Promotional Text (170 chars)

**iOS:**
```
🎉 LIMITED TIME: Get 50% off yearly Premium!
Scan unlimited documents with AI text extraction. Perfect for students, professionals, and businesses. Try free today!
```

**Android:**
```
📱 Transform your phone into a powerful scanner! 
✨ AI-powered • Cloud sync • Unlimited scans
⭐ Rated 4.8/5 by 50K+ users
```

---

## 13. POST-LAUNCH MAINTENANCE

### Weekly Tasks

**Monday: Review Metrics**
```bash
# Script: weekly-review.sh
echo "📊 Weekly Metrics Review"
echo "======================="

# Get Firebase Analytics data
firebase analytics:data:get --start-date 7daysAgo

# Check crash rate
firebase crashlytics:reports:list --limit 10

# Review Cloud Functions logs
firebase functions:log --lines 100

# Check costs
gcloud billing accounts list
```

**Wednesday: Update Content**
- Review and respond to app store reviews
- Update promotional text if needed
- Check competitor apps for new features

**Friday: Technical Maintenance**
- Update dependencies if needed
- Review security alerts
- Check performance metrics
- Plan next week's improvements

### Monthly Tasks

**First Week:**
- Analyze conversion funnel
- A/B test pricing or features
- Review churn rate
- Update marketing materials

**Second Week:**
- Deploy minor bug fixes
- Optimize Cloud Functions
- Review Firebase costs
- Plan new features

**Third Week:**
- Conduct user interviews
- Review feature requests
- Update roadmap
- Prepare blog post

**Fourth Week:**
- Financial review (revenue, costs, profit)
- Team retrospective
- Plan next month
- Deploy major updates

### Quarterly Tasks

- Major version release
- Marketing campaign
- Review business model
- Hire/scale team if needed
- Explore partnerships

### Version Update Template

**CHANGELOG.md:**
```markdown
# Changelog

## [1.2.0] - 2024-02-15

### Added
- Multi-page PDF support for Premium users
- Dark mode
- Batch scanning (scan multiple docs at once)

### Changed
- Improved camera performance
- Updated UI design
- Faster PDF generation

### Fixed
- Camera crash on Android 14
- OCR timeout on large images
- Storage sync issues

## [1.1.0] - 2024-01-15

### Added
- Cloud backup for Premium
- Search in documents
- Favorite documents

### Fixed
- Login issues
- Camera permission crash
```

---

## 14. COMMON PATTERNS

### Singleton Pattern for Services

```dart
class DocumentService {
  static final DocumentService _instance = DocumentService._internal();
  factory DocumentService() => _instance;
  DocumentService._internal();

  // Service methods
}

// Usage
final service = DocumentService();
```

### Repository Pattern

```dart
abstract class DocumentRepository {
  Future<List<DocumentModel>> getDocuments();
  Future<void> addDocument(DocumentModel doc);
  Future<void> updateDocument(String id, Map<String, dynamic> updates);
  Future<void> deleteDocument(String id);
}

class FirestoreDocumentRepository implements DocumentRepository {
  final FirebaseFirestore _firestore;

  FirestoreDocumentRepository(this._firestore);

  @override
  Future<List<DocumentModel>> getDocuments() async {
    // Implementation
  }
  
  // Other methods
}
```

### Loading State Pattern

```dart
enum LoadingState {
  initial,
  loading,
  loaded,
  error,
}

class DocumentProvider with ChangeNotifier {
  LoadingState _state = LoadingState.initial;
  List<DocumentModel> _documents = [];
  String? _error;

  LoadingState get state => _state;
  List<DocumentModel> get documents => _documents;
  String? get error => _error;

  Future<void> loadDocuments() async {
    _state = LoadingState.loading;
    notifyListeners();

    try {
      _documents = await _repository.getDocuments();
      _state = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    }
    
    notifyListeners();
  }
}
```

### Result Pattern (for error handling)

```dart
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result.success(this.data)
      : error = null,
        isSuccess = true;

  Result.failure(this.error)
      : data = null,
        isSuccess = false;
}

// Usage
Future<Result<DocumentModel>> scanDocument(File image) async {
  try {
    final doc = await _process(image);
    return Result.success(doc);
  } catch (e) {
    return Result.failure(e.toString());
  }
}
```

---

## 15. SECURITY CHECKLIST

### Pre-Deployment Security Audit

```bash
# Run this before EVERY deployment

echo "🔒 Security Audit Checklist"
echo "=========================="

# 1. Check for exposed secrets
echo "1. Checking for secrets in code..."
if grep -r "sk-" lib/ || grep -r "AIza" lib/ || grep -r "key" lib/; then
    echo "❌ FAIL: Possible API keys found in code!"
    exit 1
else
    echo "✅ PASS: No secrets in code"
fi

# 2. Check Firebase rules are deployed
echo "2. Checking Firebase rules..."
firebase firestore:rules:get > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ PASS: Firestore rules deployed"
else
    echo "❌ FAIL: Firestore rules not deployed!"
    exit 1
fi

# 3. Check Cloud Functions are protected
echo "3. Checking Cloud Function authentication..."
# Manual check: Ensure all functions check context.auth

# 4. Check for console.log in production
echo "4. Checking for debug code..."
if grep -r "console.log" lib/; then
    echo "⚠️  WARNING: console.log found (consider removing for production)"
else
    echo "✅ PASS: No debug logs"
fi

# 5. Check HTTPS only
echo "5. Checking network security..."
# Ensure all Firebase calls use HTTPS (automatic)

echo ""
echo "Security audit complete!"
```

### Security Best Practices Summary

✅ **DO:**
- Validate everything server-side
- Use Firestore security rules
- Rate limit all operations
- Verify receipts server-side
- Encrypt data in transit (HTTPS)
- Use Firebase Auth for authentication
- Log security events
- Monitor for abuse
- Keep dependencies updated
- Use environment variables for secrets

❌ **DON'T:**
- Store API keys in app code
- Trust client-side validation
- Expose admin functions
- Skip input validation
- Log sensitive data
- Use HTTP (only HTTPS)
- Hard-code credentials
- Ignore security warnings
- Skip security rules
- Allow unlimited requests

---

## FINAL NOTES

This Developer's Companion Guide provides:

✅ **Quick Start** - Get running in 5 minutes  
✅ **Exact Schemas** - Copy-paste database structure  
✅ **API Reference** - All Cloud Functions documented  
✅ **Scripts** - Automated setup & deployment  
✅ **Components** - Reusable UI widgets  
✅ **Snippets** - Common code patterns  
✅ **Testing** - Unit, widget, integration tests  
✅ **Troubleshooting** - Solutions to common issues  
✅ **Performance** - Optimization techniques  
✅ **Deployment** - Automated scripts  
✅ **Analytics** - Track everything  
✅ **ASO** - App store optimization  
✅ **Maintenance** - Post-launch care  
✅ **Patterns** - Best practices  
✅ **Security** - Complete checklist  

**Use this with MASTER_PROJECT_BRIEF.md for a complete, professional development experience!**

Keep this guide open while coding - it's your reference for everything not in the main brief. 🚀
