// lib/widgets/common/transaction_tile.dart
// A single transaction row used in history and dashboard lists.

import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final color  = AppTheme.getCategoryColor(transaction.category);
    final isInc  = transaction.isIncome;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color:        theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: color, width: 3.5),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color:        color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            AppConstants.getCategoryIcon(transaction.category),
            color: color, size: 22,
          ),
        ),
        title: Text(
          transaction.category,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description.isNotEmpty)
              Text(transaction.description,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              DateHelpers.formatDate(transaction.date),
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isInc ? '+' : '-'} ${CurrencyFormatter.format(transaction.amount)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color:      isInc ? AppTheme.successColor : AppTheme.errorColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 18, color: Colors.grey),
                onSelected: (val) {
                  if (val == 'edit')   onEdit?.call();
                  if (val == 'delete') onDelete?.call();
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
            ],
          ],
        ),
      ),
    );
  }
}
