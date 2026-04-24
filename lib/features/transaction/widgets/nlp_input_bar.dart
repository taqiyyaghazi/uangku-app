import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/transaction/models/nlp_transaction_result.dart';
import 'package:uangku/features/transaction/services/gemini_nlp_service.dart';
import 'package:uangku/features/transaction/widgets/quick_entry_sheet.dart';

class NlpExpandableFab extends ConsumerStatefulWidget {
  final Function(NlpTransactionResult) onResultParsed;
  
  const NlpExpandableFab({super.key, required this.onResultParsed});

  @override
  ConsumerState<NlpExpandableFab> createState() => _NlpExpandableFabState();
}

class _NlpExpandableFabState extends ConsumerState<NlpExpandableFab> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  
  bool _isExpanded = false;
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isProcessing = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (mounted) setState(() {});
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
        _focusNode.requestFocus();
      } else {
        _expandController.reverse();
        _focusNode.unfocus();
        _textController.clear();
      }
    });
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
      
      final List<Wallet> wallets = ref.read(walletsProvider).value ?? [];
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
        _toggleExpand(); // Collapse after success
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('I couldn\'t understand that. Please try again or enter manually.'),
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Container(
          height: 56,
          width: _isExpanded 
              ? MediaQuery.of(context).size.width - 32 
              : 56,
          decoration: BoxDecoration(
            color: _isExpanded ? colorScheme.surface : OceanFlowColors.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _isExpanded ? _buildExpandedContent() : _buildCollapsedContent(),
        );
      },
    );
  }

  Widget _buildCollapsedContent() {
    return InkWell(
      onTap: _toggleExpand,
      borderRadius: BorderRadius.circular(28),
      child: const Center(
        child: Icon(
          Icons.auto_awesome,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Row(
      children: [
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: _toggleExpand,
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            _toggleExpand();
            QuickEntrySheet.show(context);
          },
          tooltip: 'Manual Entry',
          color: OceanFlowColors.primary,
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            autofocus: true,
            decoration: InputDecoration(
              hintText: _isProcessing ? 'Processing...' : (_isListening ? 'Listening...' : 'Type transaction...'),
              border: InputBorder.none,
              hintStyle: const TextStyle(fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            onSubmitted: (_) => _processText(),
            textInputAction: TextInputAction.send,
            enabled: !_isProcessing,
          ),
        ),
        if (_speechEnabled && !_isProcessing)
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? OceanFlowColors.error : OceanFlowColors.primary,
            ),
            onPressed: _isListening ? _stopListening : _startListening,
            visualDensity: VisualDensity.compact,
          ),
        if (_isProcessing)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.send),
            color: OceanFlowColors.primary,
            onPressed: _processText,
            visualDensity: VisualDensity.compact,
          ),
        const SizedBox(width: 4),
      ],
    );
  }
}
