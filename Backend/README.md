# Smart Scanner Backend - Firebase Cloud Functions

This directory contains the secure backend infrastructure for the Smart Document Scanner app.

## 🏗️ Architecture

**Security-First Design:**
- All business logic runs server-side
- User authentication required for all operations
- Scan limits enforced on the backend
- Subscription validation with Apple/Google servers
- Rate limiting on all premium features

## 📁 Structure

```
Backend/
├── firebase.json              # Firebase project configuration
├── firestore.rules            # Firestore security rules
├── storage.rules              # Cloud Storage security rules
├── firestore.indexes.json     # Firestore query indexes
└── functions/
    ├── package.json           # Node.js dependencies
    ├── index.js               # Cloud Functions implementation
    └── .gitignore             # Ignore node_modules, etc.
```

## 🔐 Security Rules

### Firestore Rules
- Users can only read/write their own data
- Scan counts managed server-side only
- Premium status cannot be manipulated by clients
- Rate limits stored securely

### Storage Rules
- Users can only access their own files
- 10MB file size limit enforced
- Premium cloud backup requires subscription

## ⚡ Cloud Functions

### User Management
- `onUserCreated` - Initialize new user with scan limits

### Scan Management
- `recordScan` - Validate and record scans (enforces limits)

### Subscriptions
- `verifySubscription` - Validate IAP with Apple/Google servers

### Premium Features
- `performOcr` - OCR text extraction (premium only)

### Scheduled Tasks
- `resetMonthlyScans` - Reset free user scans monthly
- `checkExpiredSubscriptions` - Expire old subscriptions

## 🚀 Setup Instructions

### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
```

### 2. Login to Firebase

```bash
firebase login
```

### 3. Initialize Firebase Project

```bash
cd Backend
firebase init

# Select:
# - Firestore
# - Functions
# - Storage
```

### 4. Install Function Dependencies

```bash
cd functions
npm install
```

### 5. Configure Environment Variables

```bash
# Set Apple IAP shared secret
firebase functions:config:set apple.shared_secret="YOUR_APPLE_SHARED_SECRET"

# Set environment
firebase functions:config:set app.env="development"
```

### 6. Deploy

```bash
# Deploy everything
firebase deploy

# Or deploy specific services
firebase deploy --only functions
firebase deploy --only firestore:rules
firebase deploy --only storage
```

## 🧪 Testing Locally

### Start Firebase Emulators

```bash
firebase emulators:start
```

This starts:
- Functions emulator on http://localhost:5001
- Firestore emulator on http://localhost:8080
- Storage emulator on http://localhost:9199

### Test Functions

```bash
firebase functions:shell
```

## 📊 Monitoring

### View Logs

```bash
firebase functions:log
```

### View Specific Function

```bash
firebase functions:log --only recordScan
```

## 🔒 Security Best Practices

✅ **DO:**
- Always validate user authentication
- Enforce rate limits on all operations
- Verify subscriptions with platform APIs
- Use transactions for scan counting
- Log important operations
- Handle errors gracefully

❌ **DON'T:**
- Trust client-provided data
- Expose API keys in code
- Skip input validation
- Allow direct database writes from clients
- Return sensitive error messages

## 📈 Cost Optimization

**Free Tier Limits:**
- 2M function invocations/month
- 125K function invocations/day
- 400K GB-seconds/month

**Tips:**
- Use scheduled functions sparingly
- Cache data when possible
- Implement proper rate limiting
- Monitor usage in Firebase Console

## 🛠️ Troubleshooting

### Functions not deploying?
```bash
# Check Node version (must be 18)
node --version

# Clear cache
npm cache clean --force
cd functions && rm -rf node_modules && npm install
```

### Emulators not starting?
```bash
# Kill existing processes
lsof -ti:5001,8080,9199 | xargs kill -9

# Restart
firebase emulators:start
```

## 📚 Resources

- [Firebase Functions Docs](https://firebase.google.com/docs/functions)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Cloud Storage Rules](https://firebase.google.com/docs/storage/security)

---

**Built with Firebase & Node.js**
