import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/ai_consultation_service.dart';

class TanyaTaniScreen extends StatefulWidget {
  const TanyaTaniScreen({super.key});

  @override
  State<TanyaTaniScreen> createState() => _TanyaTaniScreenState();
}

class _TanyaTaniScreenState extends State<TanyaTaniScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIConsultationService _aiService = AIConsultationService();
  bool _isThinking = false;

  final List<String> _quickChips = [
    'Dosis pupuk 50 ru berapa?',
    'Cara atasi wereng coklat?',
    'Syarat ambil pupuk tebus?',
    'Berapa harga HET pupuk subsidi?',
    'Jadwal kloter pembagian?',
    'Kontak WA pengurus Poktan?',
  ];

  void _sendMessage([String? presetText]) async {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _isThinking = true;
    });
    _scrollToBottom();

    await _aiService.ask(text);

    if (mounted) {
      setState(() {
        _isThinking = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: GojekColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kang Sri · AI Tani', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Text('Asisten Digital Poktan Sri Mulyo', style: TextStyle(fontSize: 11, color: GojekColors.primaryDark)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Question Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _quickChips.map((chip) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(chip),
                      backgroundColor: GojekColors.background,
                      labelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: GojekColors.textPrimary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: GojekColors.border),
                      ),
                      onPressed: () => _sendMessage(chip),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _aiService.messages.length + (_isThinking ? 1 : 0),
              itemBuilder: (ctx, idx) {
                if (idx == _aiService.messages.length && _isThinking) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GojekColors.border),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: GojekColors.primary),
                          ),
                          SizedBox(width: 8),
                          Text('Kang Sri sedang meracik jawaban...', style: TextStyle(fontSize: 12, color: GojekColors.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }

                final msg = _aiService.messages[idx];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: msg.isUser ? GojekColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: msg.isUser ? null : Border.all(color: GojekColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: msg.isUser ? Colors.white : GojekColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Bar at bottom
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: GojekColors.background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: GojekColors.border),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(fontSize: 13, color: GojekColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Tanyakan sesuatu ke Kang Sri...',
                        hintStyle: TextStyle(fontSize: 12, color: GojekColors.textMuted),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: GojekColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
