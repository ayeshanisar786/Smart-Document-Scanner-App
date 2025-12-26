import 'package:intl/intl.dart';

// Date Formatting Utilities
class DateFormatter {
  // Standard formats
  static final DateFormat _fullDate = DateFormat('MMMM d, yyyy');
  static final DateFormat _shortDate = DateFormat('MMM d, yyyy');
  static final DateFormat _veryShortDate = DateFormat('M/d/yy');
  static final DateFormat _time12 = DateFormat('h:mm a');
  static final DateFormat _time24 = DateFormat('HH:mm');
  static final DateFormat _dateTime = DateFormat('MMM d, yyyy h:mm a');
  static final DateFormat _dayOfWeek = DateFormat('EEEE');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _iso8601 = DateFormat('yyyy-MM-dd');

  // Format as full date (e.g., "January 15, 2024")
  static String fullDate(DateTime date) => _fullDate.format(date);

  // Format as short date (e.g., "Jan 15, 2024")
  static String shortDate(DateTime date) => _shortDate.format(date);

  // Format as very short date (e.g., "1/15/24")
  static String veryShortDate(DateTime date) => _veryShortDate.format(date);

  // Format as 12-hour time (e.g., "3:30 PM")
  static String time12Hour(DateTime date) => _time12.format(date);

  // Format as 24-hour time (e.g., "15:30")
  static String time24Hour(DateTime date) => _time24.format(date);

  // Format as date and time (e.g., "Jan 15, 2024 3:30 PM")
  static String dateTime(DateTime date) => _dateTime.format(date);

  // Format as day of week (e.g., "Monday")
  static String dayOfWeek(DateTime date) => _dayOfWeek.format(date);

  // Format as month and year (e.g., "January 2024")
  static String monthYear(DateTime date) => _monthYear.format(date);

  // Format as ISO 8601 (e.g., "2024-01-15")
  static String iso8601(DateTime date) => _iso8601.format(date);

  // Format relative to now
  static String relative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    // Future dates
    if (difference.isNegative) {
      final futureDiff = date.difference(now);
      if (futureDiff.inDays == 0) {
        return 'Later today';
      } else if (futureDiff.inDays == 1) {
        return 'Tomorrow';
      } else if (futureDiff.inDays < 7) {
        return 'In ${futureDiff.inDays} days';
      } else {
        return shortDate(date);
      }
    }

    // Past dates
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${_pluralize('minute', difference.inMinutes)} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${_pluralize('hour', difference.inHours)} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${_pluralize('week', weeks)} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${_pluralize('month', months)} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${_pluralize('year', years)} ago';
    }
  }

  // Format with context (Today, Yesterday, date)
  static String contextual(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today at ${time12Hour(date)}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday at ${time12Hour(date)}';
    } else if (now.difference(date).inDays < 7) {
      return '${dayOfWeek(date)} at ${time12Hour(date)}';
    } else if (now.year == date.year) {
      return '${shortDate(date)} at ${time12Hour(date)}';
    } else {
      return dateTime(date);
    }
  }

  // Format for document list (short contextual)
  static String forDocumentList(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return time12Hour(date);
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return dayOfWeek(date);
    } else if (now.year == date.year) {
      return DateFormat('MMM d').format(date);
    } else {
      return shortDate(date);
    }
  }

  // Format time remaining
  static String timeRemaining(DateTime futureDate) {
    final now = DateTime.now();
    final difference = futureDate.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays} ${_pluralize('day', difference.inDays)} remaining';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${_pluralize('hour', difference.inHours)} remaining';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${_pluralize('minute', difference.inMinutes)} remaining';
    } else {
      return 'Expires soon';
    }
  }

  // Format duration
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} ${_pluralize('day', duration.inDays)}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ${_pluralize('hour', duration.inHours)}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} ${_pluralize('minute', duration.inMinutes)}';
    } else {
      return '${duration.inSeconds} ${_pluralize('second', duration.inSeconds)}';
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  // Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Check if date is this year
  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  // Helper to pluralize words
  static String _pluralize(String word, int count) {
    return count == 1 ? word : '${word}s';
  }

  // Parse ISO 8601 string
  static DateTime? parseIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get age from birthdate
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Get days until date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    return targetDay.difference(today).inDays;
  }

  // Get days since date
  static int daysSince(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    return today.difference(targetDay).inDays;
  }
}
