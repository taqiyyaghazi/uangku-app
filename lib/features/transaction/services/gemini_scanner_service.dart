import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/features/transaction/models/receipt_data.dart';

final geminiScannerServiceProvider = Provider<GeminiScannerService>((ref) {
  return GeminiScannerService(ref.read(monitoringServiceProvider));
});

class GeminiScannerService {
  final MonitoringService _monitoring;
  late final GenerativeModel _model;

  GeminiScannerService(this._monitoring) {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      _monitoring.recordError(
          Exception('GEMINI_API_KEY is missing from .env'), StackTrace.current);
    }
    
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey ?? '',
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  /// Analyzes a receipt image using Gemini 1.5 Flash.
  /// 
  /// Requires the image bytes and the user's available categories for fuzzy matching.
  Future<ReceiptData?> analyzeReceipt(
      Uint8List imageBytes, List<Category> categories) async {
    try {
      final categoryNames = categories.map((e) => e.name).toList().join(', ');
      
      final prompt = '''
Extract data from this receipt. Identify the TOTAL amount, store name, and transaction date. 
Suggest the best category from this user list: [$categoryNames]. 
If no category perfectly matches, pick the closest one or default to the first one.
Return ONLY a valid JSON object matching this structure: 
{"amount": 55000, "date": "YYYY-MM-DD", "store": "Indomaret", "category": "Food"}
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      _monitoring.log('Sending receipt image to Gemini API');
      
      final response = await _model.generateContent(content);
      final text = response.text;
      
      if (text == null) {
        throw Exception('Received null text from Gemini');
      }

      _monitoring.log('Received response from Gemini API');
      
      final Map<String, dynamic> jsonResponse = jsonDecode(text);
      
      // Match category
      final categoryName = jsonResponse['category'] as String?;
      Category selectedCategory = categories.first;
      if (categoryName != null) {
        try {
          selectedCategory = categories.firstWhere(
            (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
            orElse: () => categories.first,
          );
        } catch (_) {}
      }

      return ReceiptData.fromJson(jsonResponse, selectedCategory);
    } catch (e, stack) {
      _monitoring.recordError(e, stack, reason: 'Failed to analyze receipt');
      return null;
    }
  }
}
