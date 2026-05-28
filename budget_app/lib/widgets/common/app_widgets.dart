// lib/widgets/common/app_widgets.dart
// Reusable UI components used across multiple screens.

import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

// ── Custom Text Field ──────────────────────────────────────────
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:   widget.controller,
      obscureText:  widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      validator:    widget.validator,
      onChanged:    widget.onChanged,
      decoration: InputDecoration(
        labelText:   widget.label,
        hintText:    widget.hint,
        prefixIcon:  widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 20) : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}

// ── Loading Button ─────────────────────────────────────────────
class LoadingButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color? color;

  const LoadingButton({
    super.key,
    required this.text,
    required this.isLoading,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppTheme.primaryColor,
      ),
      child: isLoading
          ? const SizedBox(
              height: 22, width: 22,
              child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5,
              ),
            )
          : Text(text),
    );
  }
}

// ── Summary Card ───────────────────────────────────────────────
class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final Color? bgColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        bgColor ?? theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding:      const EdgeInsets.all(8),
          decoration:   BoxDecoration(
            color:        color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 12),
        Text(title,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(amount,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700, color: color,
          ),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
      ]),
    );
  }
}

// ── Category Chip ──────────────────────────────────────────────
class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getCategoryColor(category);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:        isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: color, width: 1.5),
        ),
        child: Text(
          category,
          style: TextStyle(
            color:      isSelected ? Colors.white : color,
            fontSize:   13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700)),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!,
              style: const TextStyle(color: AppTheme.primaryColor,
                fontSize: 13, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

// ── Empty State ────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[400])),
        ]),
      ),
    );
  }
}

// ── Error Banner ───────────────────────────────────────────────
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const ErrorBanner({super.key, required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin:  const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:        AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded,
          color: AppTheme.errorColor, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message,
          style: const TextStyle(color: AppTheme.errorColor, fontSize: 13))),
        if (onDismiss != null)
          GestureDetector(onTap: onDismiss,
            child: const Icon(Icons.close_rounded,
              color: AppTheme.errorColor, size: 18)),
      ]),
    );
  }
}
