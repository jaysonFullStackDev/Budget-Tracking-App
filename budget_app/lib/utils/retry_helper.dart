// lib/utils/retry_helper.dart
// Retry logic with exponential backoff for failed operations.

import 'dart:async';
import 'dart:math';

class RetryHelper {
  static Future<T> withRetry<T>({
    required Future<T> Function() action,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
  }) async {
    int attempt = 0;
    while (true) {
      try {
        attempt++;
        return await action();
      } catch (e) {
        if (attempt >= maxAttempts) rethrow;
        final delay = initialDelay * pow(2, attempt - 1).toInt();
        await Future.delayed(delay);
      }
    }
  }
}
