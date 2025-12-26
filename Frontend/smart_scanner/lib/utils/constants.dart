// App Constants
class AppConstants {
  // App Info
  static const String appName = 'Smart Scanner';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered document scanner';

  // Firebase (NO API KEYS - these are configured via FlutterFire CLI)
  // API keys are handled server-side in Cloud Functions

  // Subscription/Premium
  static const int freeScanLimit = 10;
  static const double monthlyPrice = 4.99;
  static const double yearlyPrice = 29.99;
  static const String monthlyProductId = 'premium_monthly';
  static const String yearlyProductId = 'premium_yearly';
  static const String entitlementId = 'premium';

  // File Limits
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxFileSizeMB = 10;
  static const int maxImageWidth = 2048;
  static const int maxImageHeight = 2048;
  static const int thumbnailWidth = 300;
  static const int thumbnailHeight = 400;

  // Document Settings
  static const int defaultPdfQuality = 85;
  static const int highPdfQuality = 95;
  static const int lowPdfQuality = 60;

  // Timeouts
  static const Duration uploadTimeout = Duration(minutes: 5);
  static const Duration downloadTimeout = Duration(minutes: 5);
  static const Duration apiTimeout = Duration(seconds: 30);

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Pagination
  static const int documentsPerPage = 20;
  static const int searchResultsLimit = 50;

  // Cloud Functions Region
  static const String functionsRegion = 'us-central1';

  // Support
  static const String supportEmail = 'support@smartscanner.app';
  static const String privacyPolicyUrl = 'https://smartscanner.app/privacy';
  static const String termsOfServiceUrl = 'https://smartscanner.app/terms';

  // Premium Features
  static const List<String> premiumFeatures = [
    'Unlimited scans',
    'AI text extraction (OCR)',
    'Auto-enhancement',
    'Cloud backup & sync',
    'Multi-page PDFs',
    'Advanced organization',
    'Priority support',
  ];

  // Free Features
  static const List<String> freeFeatures = [
    '10 scans per month',
    'High-quality scanning',
    'Multiple filters',
    'PDF generation',
    'Local storage',
    'Share documents',
  ];

  // Image Filters
  static const List<String> imageFilters = [
    'Original',
    'Black & White',
    'Grayscale',
    'Magic Color',
    'Auto',
  ];

  // Document Tags (Predefined)
  static const List<String> defaultTags = [
    'Receipt',
    'Invoice',
    'Contract',
    'ID Card',
    'Business Card',
    'Notes',
    'Personal',
    'Work',
    'Important',
  ];

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Check your connection.';
  static const String errorAuth = 'Authentication failed. Please sign in again.';
  static const String errorPermission = 'Permission denied.';
  static const String errorNotFound = 'Item not found.';
  static const String errorFileTooLarge = 'File size exceeds 10MB limit.';
  static const String errorScanLimitReached =
      'Scan limit reached. Upgrade to Premium for unlimited scans.';
  static const String errorPremiumRequired =
      'This feature requires a Premium subscription.';

  // Success Messages
  static const String successDocumentSaved = 'Document saved successfully!';
  static const String successDocumentDeleted = 'Document deleted.';
  static const String successDocumentShared = 'Document shared!';
  static const String successPremiumActivated = 'Premium activated!';
  static const String successDocumentRenamed = 'Document renamed.';

  // Onboarding
  static const List<Map<String, String>> onboardingPages = [
    {
      'title': 'Scan Any Document',
      'description':
          'Transform any paper document into a high-quality PDF in seconds.',
      'icon': 'document_scanner',
    },
    {
      'title': 'AI-Powered Features',
      'description':
          'Extract text, auto-enhance images, and organize with smart tags.',
      'icon': 'auto_fix_high',
    },
    {
      'title': 'Secure Cloud Storage',
      'description':
          'Backup and access your documents from anywhere with Premium.',
      'icon': 'cloud_upload',
    },
  ];

  // Rating
  static const int minScansBeforeRatingPrompt = 5;
  static const int daysBeforeRatingPrompt = 3;

  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
}

// Storage Paths
class StoragePaths {
  static String userDocuments(String userId) => 'users/$userId/documents';
  static String userThumbnails(String userId) => 'users/$userId/thumbnails';
  static String userImages(String userId) => 'users/$userId/images';
  static String premiumBackup(String userId) => 'premium/$userId';

  static String documentPdf(String userId, String documentId) =>
      'users/$userId/documents/$documentId.pdf';
  static String documentThumbnail(String userId, String documentId) =>
      'users/$userId/thumbnails/$documentId.jpg';
  static String documentImage(String userId, String documentId) =>
      'users/$userId/images/$documentId.jpg';
}

// Firestore Collections
class FirestoreCollections {
  static const String users = 'users';
  static const String documents = 'documents';
  static const String rateLimits = 'rateLimits';
  static const String analytics = 'analytics';

  static String userDocuments(String userId) => 'users/$userId/documents';
  static String userRateLimits(String userId) => 'rateLimits/$userId/actions';
}

// Shared Preferences Keys
class PrefsKeys {
  static const String isFirstLaunch = 'is_first_launch';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String lastRatingPrompt = 'last_rating_prompt';
  static const String scanCount = 'scan_count';
  static const String defaultFilter = 'default_filter';
  static const String defaultQuality = 'default_quality';
  static const String autoBackup = 'auto_backup';
  static const String theme = 'theme';
  static const String language = 'language';
}

// Routes
class Routes {
  static const String home = '/';
  static const String camera = '/camera';
  static const String editor = '/editor';
  static const String documentDetail = '/document';
  static const String premium = '/premium';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String onboarding = '/onboarding';
}
