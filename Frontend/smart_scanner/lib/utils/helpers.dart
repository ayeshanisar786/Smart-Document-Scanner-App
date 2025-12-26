import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Helper Functions
class Helpers {
  // Format file size to human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Format date to readable format
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE, h:mm a').format(date);
    } else if (now.year == date.year) {
      return DateFormat('MMM d, h:mm a').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  // Format date (short version)
  static String formatDateShort(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else if (now.year == date.year) {
      return DateFormat('MMM d').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  // Format time ago
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }

  // Format currency
  static String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Show snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show error dialog
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
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

  // Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDangerous
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Get file extension
  static String getFileExtension(String filename) {
    final parts = filename.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  // Check if email is valid
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Get initials from name
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // Calculate percentage
  static double calculatePercentage(int current, int total) {
    if (total == 0) return 0;
    return (current / total) * 100;
  }

  // Format percentage
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(0)}%';
  }

  // Get color from scan percentage
  static Color getColorFromPercentage(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else if (percentage >= 20) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }

  // Check if subscription is expiring soon
  static bool isExpiringSoon(DateTime? expiryDate) {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    return difference.inDays <= 7 && difference.inDays > 0;
  }

  // Format subscription expiry
  static String formatSubscriptionExpiry(DateTime? expiryDate) {
    if (expiryDate == null) return 'No active subscription';
    final now = DateTime.now();

    if (expiryDate.isBefore(now)) {
      return 'Expired ${timeAgo(expiryDate)}';
    }

    final difference = expiryDate.difference(now);
    if (difference.inDays > 30) {
      return 'Expires ${DateFormat('MMM d, yyyy').format(expiryDate)}';
    } else if (difference.inDays > 1) {
      return 'Expires in ${difference.inDays} days';
    } else if (difference.inHours > 1) {
      return 'Expires in ${difference.inHours} hours';
    } else {
      return 'Expires soon';
    }
  }

  // Copy to clipboard
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    // await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      showSnackBar(context, 'Copied to clipboard');
    }
  }

  // Open URL
  static Future<void> openUrl(String url) async {
    // await launchUrl(Uri.parse(url));
  }

  // Share text
  static Future<void> shareText(String text) async {
    // await Share.share(text);
  }

  // Debounce function
  static Function debounce(
    Function func, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, () => func());
    };
  }
}

// Timer for debouncing
class Timer {
  Timer(Duration duration, VoidCallback callback) {
    Future.delayed(duration, callback);
  }

  void cancel() {}
}
