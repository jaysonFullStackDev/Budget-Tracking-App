// lib/widgets/common/floating_ai_avatar.dart
// Floating draggable AI avatar that hovers on screen with a bobbing animation.

import 'package:flutter/material.dart';
import '../../screens/ai_chat_screen.dart';

class FloatingAiAvatar extends StatefulWidget {
  const FloatingAiAvatar({super.key});

  @override
  State<FloatingAiAvatar> createState() => _FloatingAiAvatarState();
}

class _FloatingAiAvatarState extends State<FloatingAiAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bobAnim;

  // Position of the floating avatar
  double _xPos = -1; // -1 means not initialized
  double _yPos = -1;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _bobAnim = Tween<double>(begin: -4, end: 4).animate(
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Initialize position to bottom-right
    if (_xPos == -1) {
      _xPos = screenWidth - 80;
      _yPos = screenHeight - 200;
    }

    return Positioned(
      left: _xPos,
      top: _yPos,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _xPos = (_xPos + details.delta.dx).clamp(0, screenWidth - 65);
            _yPos = (_yPos + details.delta.dy).clamp(0, screenHeight - 120);
          });
        },
        onTap: () {
          Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AiChatScreen()));
        },
        child: AnimatedBuilder(
          animation: _bobAnim,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _bobAnim.value),
              child: child,
            );
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFF00BFA5).withOpacity(0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/ai_avatar.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
