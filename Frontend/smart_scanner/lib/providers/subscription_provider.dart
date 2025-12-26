import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class SubscriptionProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isPremium => _user?.isPremium ?? false;
  int get scansRemaining => _user?.remainingScans ?? 0;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get subscriptionExpires => _user?.subscriptionExpires;
  int get scansThisMonth => _user?.scansThisMonth ?? 0;
  int get scanLimit => _user?.scanLimit ?? 10;

  // Initialize and listen to user data
  void initialize() {
    _firestoreService.getUserStream().listen((user) {
      _user = user;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Failed to load user data: $error';
      print('User stream error: $error');
      notifyListeners();
    });
  }

  // Record a scan (calls Cloud Function for server-side validation)
  Future<bool> recordScan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final recordScan = _functions.httpsCallable('recordScan');
      final result = await recordScan.call();

      if (result.data['success'] == true) {
        // User data will be updated via the stream
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Failed to record scan';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseFunctionsException catch (e) {
      _errorMessage = _handleFunctionsError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify subscription (calls Cloud Function)
  Future<bool> verifySubscription(String receiptData, String platform,
      {String? productId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final verifySubscription = _functions.httpsCallable('verifySubscription');
      final result = await verifySubscription.call({
        'receiptData': receiptData,
        'platform': platform,
        'productId': productId,
      });

      if (result.data['success'] == true) {
        // User data will be updated via the stream
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = result.data['error'] ?? 'Verification failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseFunctionsException catch (e) {
      _errorMessage = _handleFunctionsError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Verification error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Perform OCR (premium feature, calls Cloud Function)
  Future<String?> performOcr(String imageUrl) async {
    if (!isPremium) {
      _errorMessage = 'Premium subscription required for OCR';
      notifyListeners();
      throw Exception('Premium subscription required for OCR');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final performOcr = _functions.httpsCallable('performOcr');
      final result = await performOcr.call({'imageUrl': imageUrl});

      if (result.data['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return result.data['text'];
      }

      _errorMessage = 'OCR failed';
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseFunctionsException catch (e) {
      _errorMessage = _handleFunctionsError(e);
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'OCR error: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Check if user has scans remaining
  bool get canScan {
    if (_user == null) return false;
    return isPremium || scansRemaining > 0;
  }

  // Get days until subscription expires
  int? get daysUntilExpiry {
    if (subscriptionExpires == null) return null;
    final now = DateTime.now();
    if (subscriptionExpires!.isBefore(now)) return 0;
    return subscriptionExpires!.difference(now).inDays;
  }

  // Check if subscription is about to expire (within 7 days)
  bool get isExpiringSoon {
    final days = daysUntilExpiry;
    if (days == null) return false;
    return days <= 7 && days > 0;
  }

  // Handle Cloud Functions errors
  String _handleFunctionsError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'Please sign in to continue';
      case 'permission-denied':
        return 'Premium subscription required';
      case 'resource-exhausted':
        return e.message ?? 'Limit reached. Please try again later.';
      case 'not-found':
        return 'User not found';
      case 'internal':
        return 'Server error. Please try again.';
      default:
        return e.message ?? 'An error occurred';
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refresh() async {
    try {
      final user = await _firestoreService.getUser();
      _user = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to refresh: $e';
      notifyListeners();
    }
  }
}
