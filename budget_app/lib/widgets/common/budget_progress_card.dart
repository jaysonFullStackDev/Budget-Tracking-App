// lib/widgets/common/budget_progress_card.dart
// Displays a category budget with visual progress bar and spending info.

import 'package:flutter/material.dart';
import '../../models/budget_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final catColor = AppTheme.getCategoryColor(budget.category);
    final progress = budget.usagePercent;

    // Color shifts red when exceeded, amber when near
    final barColor = budget.isExceeded
        ? AppTheme.errorColor
        : budget.isNearLimit
            ? AppTheme.warningColor
            : catColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding:    const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:        catColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(AppConstants.getCategoryIcon(budget.category),
              color: catColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(budget.category,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              if (budget.isExceeded)
                Row(children: [
                  const Icon(Icons.warning_rounded,
                    size: 12, color: AppTheme.errorColor),
                  const SizedBox(width: 4),
                  Text('Budget exceeded!',
                    style: const TextStyle(color: AppTheme.errorColor,
                      fontSize: 11, fontWeight: FontWeight.w500)),
                ]),
            ]),
          ),
          if (onEdit != null || onDelete != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, size: 18, color: Colors.grey),
              onSelected: (v) {
                if (v == 'edit')   onEdit?.call();
                if (v == 'delete') onDelete?.call();
              },
              itemBuilder: (_) => [
                if (onEdit != null)
                  const PopupMenuItem(value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_rounded, size: 16), SizedBox(width: 8),
                      Text('Edit'),
                    ])),
                if (onDelete != null)
                  const PopupMenuItem(value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded, size: 16,
                        color: AppTheme.errorColor),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                    ])),
              ],
            ),
        ]),
        const SizedBox(height: 14),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value:           progress,
            minHeight:       10,
            backgroundColor: barColor.withOpacity(0.15),
            valueColor:      AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
        const SizedBox(height: 8),

        // Spent / Limit row
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Spent: ${CurrencyFormatter.format(budget.amountSpent)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color:      barColor,
              fontWeight: FontWeight.w600,
            )),
          Text('Limit: ${CurrencyFormatter.format(budget.budgetLimit)}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
        ]),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(progress * 100).toStringAsFixed(0)}% used',
            style: theme.textTheme.bodySmall?.copyWith(
              color:      Colors.grey[400],
              fontSize:   11,
            ),
          ),
        ),
      ]),
    );
  }
}
