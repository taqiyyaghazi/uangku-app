import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/features/transaction/models/nlp_transaction_result.dart';
import 'package:uangku/features/transaction/services/gemini_scanner_service.dart';

final geminiNlpServiceProvider = Provider<GeminiNlpService>((ref) {
  return GeminiNlpService(ref.read(monitoringServiceProvider));
});

class GeminiNlpService {
  final MonitoringService _monitoring;
  late final GenerativeModel _model;

  GeminiNlpService(this._monitoring) {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      _monitoring.recordError(
        Exception('GEMINI_API_KEY is missing from .env'),
        StackTrace.current,
      );
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey ?? '',
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  Future<NlpTransactionResult?> analyzeTransactionText(
    String text,
    List<Category> categories,
    List<Wallet> wallets,
    Wallet defaultWallet,
  ) async {
    try {
      final categoryNames = categories.map((e) => e.name).toList().join(', ');
      final walletNames = wallets.map((e) => e.name).toList().join(', ');

      final prompt = '''
Analyze this text to extract a financial transaction: "$text"

Context:
User's available wallets: [$walletNames]
User's available categories: [$categoryNames]
Current date: ${DateTime.now().toIso8601String().split('T').first}

Instructions:
1. "amount": Extract the transaction amount as a number (e.g. "25rb" or "goceng" becomes 25000 or 5000).
2. "type": Determine if it's "expense", "income", or "transfer".
3. "wallet": Identify the wallet used from the available wallets.
4. "toWallet": If it's a transfer, identify the destination wallet.
5. "category": Predict the most suitable category from the available categories list.
6. "note": Extract a short description.
7. "date": Return the date in YYYY-MM-DD format if mentioned, else the current date.

Return ONLY a valid JSON object matching this structure: 
{"amount": 25000, "type": "expense", "wallet": "Gopay", "toWallet": null, "category": "Food", "note": "beli kopi", "date": "2023-10-25"}
''';

      _monitoring.log('Sending NLP text to Gemini API');

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText == null) {
        throw Exception('Received null text from Gemini');
      }

      _monitoring.log('Received NLP response from Gemini API');

      final Map<String, dynamic> jsonResponse = jsonDecode(responseText);

      return NlpTransactionResult.fromJson(
        jsonResponse,
        wallets,
        categories,
        defaultWallet,
      );
    } on GenerativeAIException catch (e) {
      if (e.message.contains('quota') ||
          e.message.contains('limit') ||
          e.message.contains('429')) {
        _monitoring.recordError(e, StackTrace.current, reason: 'Gemini Rate Limit reached');
        throw RateLimitException('Rate limit reached. Please try again later.');
      }
      rethrow;
    } catch (e, stack) {
      _monitoring.recordError(e, stack, reason: 'Failed to analyze transaction text');
      return null;
    }
  }
}
