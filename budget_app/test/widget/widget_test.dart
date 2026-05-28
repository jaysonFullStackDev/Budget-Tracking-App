// test/widget/widget_test.dart
// Widget tests for reusable UI components.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracking_app/widgets/common/app_widgets.dart';
import 'package:budget_tracking_app/widgets/common/transaction_tile.dart';
import 'package:budget_tracking_app/models/transaction_model.dart';
import 'package:budget_tracking_app/utils/app_theme.dart';

// ── Helper: wrap widget in MaterialApp for testing ─────────────
Widget wrap(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  home:  Scaffold(body: child),
);

void main() {
  // ── SummaryCard Tests ──────────────────────────────────────────
  group('SummaryCard widget', () {
    testWidgets('renders title and amount', (tester) async {
      await tester.pumpWidget(wrap(
        const SummaryCard(
          title:  'Income',
          amount: '₱50,000.00',
          icon:   Icons.trending_up_rounded,
          color:  Colors.green,
        ),
      ));

      expect(find.text('Income'),      findsOneWidget);
      expect(find.text('₱50,000.00'), findsOneWidget);
    });

    testWidgets('shows correct icon', (tester) async {
      await tester.pumpWidget(wrap(
        const SummaryCard(
          title:  'Expenses',
          amount: '₱1,200.00',
          icon:   Icons.trending_down_rounded,
          color:  Colors.red,
        ),
      ));

      expect(find.byIcon(Icons.trending_down_rounded), findsOneWidget);
    });
  });

  // ── TransactionTile Tests ──────────────────────────────────────
  group('TransactionTile widget', () {
    final mockExpense = TransactionModel(
      id:              'tx1',
      userId:          'u1',
      transactionType: 'expense',
      category:        'Food',
      amount:          350.0,
      description:     'Grocery run',
      date:            DateTime(2025, 5, 10),
      createdAt:       DateTime(2025, 5, 10),
    );

    final mockIncome = TransactionModel(
      id:              'tx2',
      userId:          'u1',
      transactionType: 'income',
      category:        'Salary',
      amount:          50000.0,
      date:            DateTime(2025, 5, 1),
      createdAt:       DateTime(2025, 5, 1),
    );

    testWidgets('renders expense transaction with minus sign', (tester) async {
      await tester.pumpWidget(wrap(
        TransactionTile(transaction: mockExpense),
      ));

      expect(find.text('Food'),       findsOneWidget);
      expect(find.text('Grocery run'),findsOneWidget);
      // Amount with minus prefix
      expect(find.textContaining('- ₱350.00'), findsOneWidget);
    });

    testWidgets('renders income transaction with plus sign', (tester) async {
      await tester.pumpWidget(wrap(
        TransactionTile(transaction: mockIncome),
      ));

      expect(find.text('Salary'),               findsOneWidget);
      expect(find.textContaining('+ ₱50,000.00'), findsOneWidget);
    });

    testWidgets('shows popup menu when callbacks provided', (tester) async {
      bool editCalled   = false;
      bool deleteCalled = false;

      await tester.pumpWidget(wrap(
        TransactionTile(
          transaction: mockExpense,
          onEdit:      () => editCalled   = true,
          onDelete:    () => deleteCalled = true,
        ),
      ));

      // Open popup menu
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Edit'),   findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });

  // ── AppTextField Validation Tests ──────────────────────────────
  group('AppTextField widget', () {
    testWidgets('shows validation error for empty email', (tester) async {
      final ctrl    = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(wrap(
        Form(
          key: formKey,
          child: Column(children: [
            AppTextField(
              controller:  ctrl,
              label:       'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@'))       return 'Enter a valid email';
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () => formKey.currentState!.validate(),
              child:     const Text('Submit'),
            ),
          ]),
        ),
      ));

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('validates invalid email format', (tester) async {
      final ctrl    = TextEditingController(text: 'notanemail');
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(wrap(
        Form(
          key: formKey,
          child: Column(children: [
            AppTextField(
              controller:  ctrl,
              label:       'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@'))       return 'Enter a valid email';
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () => formKey.currentState!.validate(),
              child:     const Text('Submit'),
            ),
          ]),
        ),
      ));

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('password field hides text by default', (tester) async {
      final ctrl = TextEditingController(text: 'mypassword');

      await tester.pumpWidget(wrap(
        AppTextField(
          controller: ctrl,
          label:      'Password',
          isPassword: true,
        ),
      ));

      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.obscureText, isTrue);
    });

    testWidgets('password visibility toggles on icon tap', (tester) async {
      final ctrl = TextEditingController(text: 'mypassword');

      await tester.pumpWidget(wrap(
        AppTextField(
          controller: ctrl,
          label:      'Password',
          isPassword: true,
        ),
      ));

      // Initially obscured
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue,
      );

      // Tap the visibility icon
      await tester.tap(find.byIcon(Icons.visibility_off_rounded));
      await tester.pump();

      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse,
      );
    });
  });

  // ── EmptyState Tests ───────────────────────────────────────────
  group('EmptyState widget', () {
    testWidgets('renders title, subtitle, and icon', (tester) async {
      await tester.pumpWidget(wrap(
        const EmptyState(
          title:    'No transactions',
          subtitle: 'Tap + to add one',
          icon:     Icons.inbox_rounded,
        ),
      ));

      expect(find.text('No transactions'), findsOneWidget);
      expect(find.text('Tap + to add one'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_rounded), findsOneWidget);
    });
  });

  // ── ErrorBanner Tests ──────────────────────────────────────────
  group('ErrorBanner widget', () {
    testWidgets('renders error message', (tester) async {
      await tester.pumpWidget(wrap(
        const ErrorBanner(message: 'Something went wrong'),
      ));

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('calls onDismiss when X is tapped', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(wrap(
        ErrorBanner(
          message:   'Error!',
          onDismiss: () => dismissed = true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(dismissed, isTrue);
    });
  });

  // ── CategoryChip Tests ─────────────────────────────────────────
  group('CategoryChip widget', () {
    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(wrap(
        CategoryChip(
          category:   'Food',
          isSelected: false,
          onTap:      () => tapped = true,
        ),
      ));

      await tester.tap(find.text('Food'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('selected chip uses full color background', (tester) async {
      await tester.pumpWidget(wrap(
        CategoryChip(
          category:   'Food',
          isSelected: true,
          onTap:      () {},
        ),
      ));

      // Text color should be white when selected
      final text = tester.widget<Text>(find.text('Food'));
      expect(text.style?.color, equals(Colors.white));
    });
  });
}
