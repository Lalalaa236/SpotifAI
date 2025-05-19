import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../apis/chatbot/chatbot_api.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBot>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<_Message> _messages = [];

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  String? _conversationId;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Slide in from right
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward(); // Start animation
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSend(String text) async {
    if (text.trim().isEmpty || _isSending) return;
    setState(() {
      _messages.add(_Message(text.trim(), true));
      _isSending = true;
    });
    _controller.clear();

    try {
      final response = await ChatBotApi.sendMessage(
        message: text.trim(),
        conversationId: _conversationId,
      );
      setState(() {
        _conversationId = response['conversation_id']?.toString();
        _messages.add(_Message(response['message'] ?? 'No response', false));
      });
    } catch (e) {
      setState(() {
        _messages.add(_Message('Error: ${e.toString()}', false));
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment:
                        msg.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color:
                            msg.isUser ? colorScheme.primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child:
                          msg.isUser
                              ? Text(
                                msg.text,
                                style: TextStyle(color: Colors.white),
                              )
                              : MarkdownBody(
                                data: msg.text,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(color: Colors.black87),
                                  strong: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  em: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  listBullet: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        hintText: 'Write your message',
                        filled: true,
                        fillColor: const Color(0xFF424242),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _handleSend,
                      enabled: !_isSending,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon:
                        _isSending
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Icon(Icons.send, color: colorScheme.primary),
                    onPressed:
                        _isSending ? null : () => _handleSend(_controller.text),
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

class _Message {
  final String text;
  final bool isUser;
  _Message(this.text, this.isUser);
}
