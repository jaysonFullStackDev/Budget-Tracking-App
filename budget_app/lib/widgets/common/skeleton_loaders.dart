// lib/widgets/common/skeleton_loaders.dart
// Shimmer-based skeleton loading placeholders for a polished loading experience.

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE0E0E0),
      highlightColor: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for the home screen balance card
class BalanceCardSkeleton extends StatelessWidget {
  const BalanceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SkeletonLoader(height: 180, borderRadius: 20),
    );
  }
}

/// Skeleton for summary cards row
class SummaryCardsSkeleton extends StatelessWidget {
  const SummaryCardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(children: const [
        Expanded(child: SkeletonLoader(height: 100, borderRadius: 16)),
        SizedBox(width: 12),
        Expanded(child: SkeletonLoader(height: 100, borderRadius: 16)),
      ]),
    );
  }
}

/// Skeleton for a single transaction tile
class TransactionTileSkeleton extends StatelessWidget {
  const TransactionTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE0E0E0),
      highlightColor: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF5F5F5),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 14, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 60, height: 10, color: Colors.white),
              ],
            ),
          ),
          Container(width: 70, height: 16, color: Colors.white),
        ]),
      ),
    );
  }
}

/// Full home screen skeleton
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: const [
      BalanceCardSkeleton(),
      SummaryCardsSkeleton(),
      SizedBox(height: 16),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          TransactionTileSkeleton(),
          TransactionTileSkeleton(),
          TransactionTileSkeleton(),
          TransactionTileSkeleton(),
        ]),
      ),
    ]);
  }
}

/// Skeleton for transaction history list
class TransactionListSkeleton extends StatelessWidget {
  final int count;
  const TransactionListSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(count, (_) => const TransactionTileSkeleton()),
      ),
    );
  }
}

/// Skeleton for budget cards
class BudgetCardSkeleton extends StatelessWidget {
  const BudgetCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(3, (_) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SkeletonLoader(height: 120, borderRadius: 16),
        )),
      ),
    );
  }
}
