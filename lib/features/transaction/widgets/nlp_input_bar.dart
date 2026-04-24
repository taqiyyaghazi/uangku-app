import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/transaction/models/nlp_transaction_result.dart';
import 'package:uangku/features/transaction/services/gemini_nlp_service.dart';

class NlpInputBar extends ConsumerStatefulWidget {
  final Function(NlpTransactionResult) onResultParsed;
  
  const NlpInputBar({super.key, required this.onResultParsed});

  @override
  ConsumerState<NlpInputBar> createState() => _NlpInputBarState();
}

class _NlpInputBarState extends ConsumerState<NlpInputBar> {
  final TextEditingController _textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: (result) {
      setState(() {
        _textController.text = result.recognizedWords;
      });
    });
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _processText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _textController.clear();
      if (_isListening) {
        _stopListening();
      }
    });

    try {
      final nlpService = ref.read(geminiNlpServiceProvider);
      
      // Get wallets and categories
      final List<Wallet> wallets = ref.read(walletsProvider).value ?? [];
      // Combine all categories since we don't know the type yet
      final categoriesAsyncExpense = ref.read(categoriesByTypeProvider(TransactionType.expense));
      final categoriesAsyncIncome = ref.read(categoriesByTypeProvider(TransactionType.income));
      
      final List<Category> allCategories = [
        ...(categoriesAsyncExpense.value ?? []),
        ...(categoriesAsyncIncome.value ?? [])
      ];
      
      if (wallets.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please create a wallet first.')),
        );
        setState(() => _isProcessing = false);
        return;
      }

      final defaultWallet = wallets.first;

      final result = await nlpService.analyzeTransactionText(
        text, 
        allCategories, 
        wallets, 
        defaultWallet
      );

      if (result != null) {
        widget.onResultParsed(result);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bob bingung, tolong masukkan secara manual atau coba lagi.'),
            backgroundColor: OceanFlowColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: OceanFlowColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: _isProcessing ? 'Bob sedang berpikir...' : (_isListening ? 'Mendengarkan...' : 'Ketik "bayar kopi 25rb"...'),
                        border: InputBorder.none,
                        enabled: !_isProcessing,
                      ),
                      onSubmitted: (_) => _processText(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  if (_speechEnabled && !_isProcessing)
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? OceanFlowColors.error : OceanFlowColors.primary,
                      ),
                      onPressed: _isListening ? _stopListening : _startListening,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isProcessing
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: OceanFlowColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send),
                  onPressed: _processText,
                ),
        ],
      ),
    );
  }
}
