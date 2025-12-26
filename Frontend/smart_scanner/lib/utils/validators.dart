// Input Validators
class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // Strong password validation
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  // Document name validation
  static String? validateDocumentName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Document name is required';
    }

    if (value.length > 100) {
      return 'Document name must be less than 100 characters';
    }

    // Check for invalid characters
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if (invalidChars.hasMatch(value)) {
      return 'Document name contains invalid characters';
    }

    return null;
  }

  // Tag validation
  static String? validateTag(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tag cannot be empty';
    }

    if (value.length > 30) {
      return 'Tag must be less than 30 characters';
    }

    // Only alphanumeric and spaces
    if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value)) {
      return 'Tag can only contain letters, numbers, and spaces';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Phone number validation (optional)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    // Remove spaces and dashes
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');

    if (cleaned.length < 10 || cleaned.length > 15) {
      return 'Please enter a valid phone number';
    }

    if (!RegExp(r'^[0-9+]+$').hasMatch(cleaned)) {
      return 'Phone number can only contain numbers and +';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // File size validation
  static String? validateFileSize(int bytes, int maxBytes) {
    if (bytes > maxBytes) {
      final maxMB = (maxBytes / (1024 * 1024)).toStringAsFixed(1);
      return 'File size exceeds $maxMB MB limit';
    }
    return null;
  }

  // Image dimensions validation
  static String? validateImageDimensions(
    int width,
    int height,
    int maxWidth,
    int maxHeight,
  ) {
    if (width > maxWidth || height > maxHeight) {
      return 'Image dimensions exceed ${maxWidth}x$maxHeight';
    }
    return null;
  }

  // Match validation (for password confirmation)
  static String? validateMatch(
    String? value,
    String? matchValue,
    String fieldName,
  ) {
    if (value != matchValue) {
      return '$fieldName does not match';
    }
    return null;
  }

  // Length validation
  static String? validateLength(
    String? value,
    int minLength,
    int maxLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }

    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (int.tryParse(value) == null && double.tryParse(value) == null) {
      return '$fieldName must be a number';
    }

    return null;
  }

  // Range validation
  static String? validateRange(
    String? value,
    num min,
    num max,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final number = num.tryParse(value);
    if (number == null) {
      return '$fieldName must be a number';
    }

    if (number < min || number > max) {
      return '$fieldName must be between $min and $max';
    }

    return null;
  }
}
