const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// ============================================
// USER INITIALIZATION
// ============================================
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

// ============================================
// SCAN RECORDING (SERVER-SIDE VALIDATION)
// ============================================
exports.recordScan = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated',
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
          scansRemaining: -1,
        };
      }

      // Check scan limit for free users
      if (userData.scansThisMonth >= userData.scanLimit) {
        throw new functions.https.HttpsError(
            'resource-exhausted',
            'Scan limit reached. Upgrade to Premium.',
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

// ============================================
// SUBSCRIPTION VERIFICATION
// ============================================
exports.verifySubscription = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Login required');
  }

  const {receiptData, platform, productId} = data;
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
        expiresAt: expirationDate.toISOString(),
      };
    }

    return {success: false, error: 'Invalid receipt'};
  } catch (error) {
    console.error('Subscription verification error:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Helper: Verify Apple Receipt
async function verifyAppleReceipt(receiptData) {
  const axios = require('axios');

  const isProduction = functions.config().app?.env === 'production';
  const url = isProduction ?
    'https://buy.itunes.apple.com/verifyReceipt' :
    'https://sandbox.itunes.apple.com/verifyReceipt';

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
  const {google} = require('googleapis');

  const auth = new google.auth.GoogleAuth({
    keyFile: functions.config().google?.service_account_path,
    scopes: ['https://www.googleapis.com/auth/androidpublisher'],
  });

  const androidPublisher = google.androidpublisher({
    version: 'v3',
    auth: await auth.getClient(),
  });

  const response = await androidPublisher.purchases.subscriptions.get({
    packageName: 'com.smartscanner.smart_scanner',
    subscriptionId: productId,
    token: purchaseToken,
  });

  return response.data;
}

// ============================================
// OCR PROCESSING (PREMIUM FEATURE)
// ============================================
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
        'Premium subscription required for OCR',
    );
  }

  // Rate limiting
  await checkRateLimit(userId, 'ocr', 50); // 50 per hour

  try {
    // TODO: Integrate Google Cloud Vision API
    // const vision = require('@google-cloud/vision');
    // const client = new vision.ImageAnnotatorClient();
    // const [result] = await client.textDetection(data.imageUrl);

    console.log(`OCR performed for user: ${userId}`);

    return {success: true, text: 'OCR text will be here'};
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
  const attempts = (doc.data()?.attempts || []).filter((t) => t > oneHourAgo);

  if (attempts.length >= maxPerHour) {
    throw new functions.https.HttpsError(
        'resource-exhausted',
        'Rate limit exceeded. Try again later.',
    );
  }

  attempts.push(now);
  await rateLimitRef.set({
    attempts,
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
  });
}

// ============================================
// SCHEDULED FUNCTIONS
// ============================================

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
