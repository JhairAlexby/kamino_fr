import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/5_chat/data/chat_repository.dart';

class ChatBottomSheet extends StatefulWidget {
  final ChatRepository repository;
  final String? title;
  const ChatBottomSheet({super.key, required this.repository, this.title});

  @override
  State<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<ChatBottomSheet> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(text: '¿En qué puedo ayudarte?', fromUser: false));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, fromUser: true));
      _loading = true;
    });
    _controller.clear();
    _jumpToEnd();
    try {
      final answer = await widget.repository.ask(text);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: answer, fromUser: false));
        _loading = false;
      });
      _jumpToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo obtener la respuesta')));
    }
  }

  void _jumpToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 64,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF242A33),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title ?? 'Chat',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (_loading)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.primaryMint)),
                    ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final align = m.fromUser ? Alignment.centerRight : Alignment.centerLeft;
                  final bg = m.fromUser ? Colors.white : AppTheme.primaryMint.withOpacity(0.12);
                  final fg = m.fromUser ? AppTheme.textBlack : Colors.white;
                  return Align(
                    alignment: align,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(m.text, style: TextStyle(color: fg, fontSize: 14)),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_loading,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryMint.withOpacity(0.6), width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _loading ? null : _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryMint,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.send, color: AppTheme.textBlack),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool fromUser;
  _ChatMessage({required this.text, required this.fromUser});
}

