// lib/widgets/common/password_strength.dart
// Visual password strength indicator bar.

import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = _calculateStrength(password);
    final label = _getLabel(strength);
    final color = _getColor(strength);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) => Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i < strength ? color : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  int _calculateStrength(String pass) {
    int score = 0;
    if (pass.length >= 6) score++;
    if (pass.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(pass) && RegExp(r'[a-z]').hasMatch(pass)) score++;
    if (RegExp(r'[0-9]').hasMatch(pass) && RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pass)) score++;
    return score;
  }

  String _getLabel(int strength) {
    switch (strength) {
      case 0: return 'Too weak';
      case 1: return 'Weak';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Strong';
      default: return '';
    }
  }

  Color _getColor(int strength) {
    switch (strength) {
      case 0:
      case 1: return AppTheme.errorColor;
      case 2: return AppTheme.warningColor;
      case 3: return AppTheme.accentColor;
      case 4: return AppTheme.successColor;
      default: return Colors.grey;
    }
  }
}
