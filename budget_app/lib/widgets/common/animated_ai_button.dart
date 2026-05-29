// lib/widgets/common/animated_ai_button.dart
// Animated AI button with pulsing glow effect.

import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class AnimatedAiButton extends StatefulWidget {
  final VoidCallback onTap;

  const AnimatedAiButton({super.key, required this.onTap});

  @override
  State<AnimatedAiButton> createState() => _AnimatedAiButtonState();
}

class _AnimatedAiButtonState extends State<AnimatedAiButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _glowAnim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentColor.withOpacity(_glowAnim.value),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Transform.scale(
              scale: _pulseAnim.value,
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}
