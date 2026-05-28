// lib/utils/input_sanitizer.dart
// Security utilities: input sanitization and rate limiting.

class InputSanitizer {
  static final RegExp _htmlTags = RegExp(r'<[^>]*>');
  static final RegExp _dangerousChars = RegExp(r'[<>";&]');

  // Strip HTML tags and dangerous characters
  static String sanitize(String input) {
    return input
        .replaceAll(_htmlTags, '')
        .replaceAll(_dangerousChars, '')
        .trim();
  }

  // Sanitize and enforce max length
  static String sanitizeWithLimit(String input, {int maxLength = 200}) {
    final cleaned = sanitize(input);
    return cleaned.length > maxLength ? cleaned.substring(0, maxLength) : cleaned;
  }

  // Validate amount is within reasonable bounds
  static const double maxAmount = 10000000; // 10 million
  static const double minAmount = 0.01;

  static bool isValidAmount(double amount) {
    return amount >= minAmount && amount <= maxAmount;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount <= 0) return 'Enter a valid amount';
    if (amount > maxAmount) return 'Amount cannot exceed 10,000,000';
    return null;
  }
}

class RateLimiter {
  final Duration cooldown;
  DateTime? _lastAction;

  RateLimiter({this.cooldown = const Duration(seconds: 2)});

  bool get canProceed {
    final now = DateTime.now();
    if (_lastAction == null || now.difference(_lastAction!) >= cooldown) {
      _lastAction = now;
      return true;
    }
    return false;
  }

  Duration get remainingCooldown {
    if (_lastAction == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_lastAction!);
    final remaining = cooldown - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
