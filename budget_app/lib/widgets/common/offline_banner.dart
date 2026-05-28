// lib/widgets/common/offline_banner.dart
// Shows a subtle banner when the device is offline.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/connectivity_provider.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityProvider>();

    if (connectivity.isOnline) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFECF0F1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded,
            color: isDark ? Colors.white70 : const Color(0xFF7F8C8D),
            size: 15),
          const SizedBox(width: 8),
          Text(
            'Offline mode — changes saved locally ✓',
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF7F8C8D),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
