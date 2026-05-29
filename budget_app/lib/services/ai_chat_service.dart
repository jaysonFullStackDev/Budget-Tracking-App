// lib/services/ai_chat_service.dart
// AI Chat Service using Google Gemini API.
// Replace the API key with your own from https://aistudio.google.com/apikey

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';

class AiChatService {
  // TODO: Replace with your Gemini API key from https://aistudio.google.com/apikey
  static const _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '<GEMINI_API_KEY>',
  );

  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Generates a response using Gemini with financial context.
  static Future<String> generateResponse(
    String userMessage,
    List<TransactionModel> transactions,
  ) async {
    // Build financial context from transactions
    final context = _buildFinancialContext(transactions);

    final systemPrompt = '''
You are a friendly and helpful financial assistant inside a budget tracking app called BudgetTrack. 
Your name is BudgetBuddy.

Your capabilities:
- Analyze the user's spending patterns
- Give personalized saving tips
- Answer questions about their finances
- Provide budget recommendations
- Motivate them to save more
- Detect unusual spending

Rules:
- Keep responses short and conversational (2-4 sentences max unless they ask for details)
- Use emojis sparingly to be friendly
- Always be encouraging, never judgmental about spending
- If asked something unrelated to finance, politely redirect
- Use the Philippine Peso (₱) for amounts
- Reference their actual data when possible

Here is the user's current financial data:
$context
''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': '$systemPrompt\n\nUser: $userMessage'}]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 300,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? 'Sorry, I couldn\'t process that. Try asking again!';
      } else {
        // Fallback to local responses if API fails
        return _localFallback(userMessage, transactions);
      }
    } catch (e) {
      // Offline or API error — use local fallback
      return _localFallback(userMessage, transactions);
    }
  }

  /// Builds a summary of the user's financial data for AI context.
  static String _buildFinancialContext(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final monthTxns = transactions.where((t) =>
        t.date.month == now.month && t.date.year == now.year).toList();

    final income = monthTxns.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final expense = monthTxns.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);

    final categorySpend = <String, double>{};
    for (final t in monthTxns.where((t) => t.isExpense)) {
      categorySpend[t.category] = (categorySpend[t.category] ?? 0) + t.amount;
    }

    final sortedCategories = categorySpend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recentTxns = transactions.take(5).map((t) =>
      '${t.transactionType}: ₱${t.amount.toStringAsFixed(2)} on ${t.category} (${t.description})').join('\n');

    return '''
Month: ${now.month}/${now.year}
Total Income: ₱${income.toStringAsFixed(2)}
Total Expenses: ₱${expense.toStringAsFixed(2)}
Balance: ₱${(income - expense).toStringAsFixed(2)}
Total Transactions: ${monthTxns.length}

Spending by category:
${sortedCategories.map((e) => '- ${e.key}: ₱${e.value.toStringAsFixed(2)}').join('\n')}

Recent transactions:
$recentTxns
''';
  }

  /// Local fallback when Gemini API is unavailable.
  static String _localFallback(String userMessage, List<TransactionModel> transactions) {
    final msg = userMessage.toLowerCase();
    final now = DateTime.now();

    final monthTxns = transactions.where((t) =>
        t.date.month == now.month && t.date.year == now.year).toList();
    final income = monthTxns.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final expense = monthTxns.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
    final balance = income - expense;

    final categorySpend = <String, double>{};
    for (final t in monthTxns.where((t) => t.isExpense)) {
      categorySpend[t.category] = (categorySpend[t.category] ?? 0) + t.amount;
    }
    final topCategory = categorySpend.entries.isNotEmpty
        ? (categorySpend.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first
        : null;

    if (msg.contains('balance') || msg.contains('how much')) {
      return 'Your balance this month is ₱${balance.toStringAsFixed(2)}. Income: ₱${income.toStringAsFixed(2)}, Expenses: ₱${expense.toStringAsFixed(2)} 💰';
    }
    if (msg.contains('spend') || msg.contains('expense')) {
      if (topCategory != null) {
        return 'You\'ve spent ₱${expense.toStringAsFixed(2)} this month. Top category: ${topCategory.key} (₱${topCategory.value.toStringAsFixed(2)}) 📊';
      }
      return 'No expenses recorded this month yet!';
    }
    if (msg.contains('income') || msg.contains('earn')) {
      return 'Your income this month is ₱${income.toStringAsFixed(2)} 💪';
    }
    if (msg.contains('save') || msg.contains('tip')) {
      return 'Try the 50/30/20 rule: 50% needs, 30% wants, 20% savings. ${topCategory != null ? "Consider reducing ${topCategory.key} spending!" : ""} 🎯';
    }
    if (msg.contains('hello') || msg.contains('hi') || msg.contains('hey')) {
      return 'Hey! 👋 I\'m BudgetBuddy. Ask me about your spending, balance, or savings tips!';
    }

    return 'I\'m your financial assistant! Ask me about your balance, spending, or savings tips. 💬';
  }
}
