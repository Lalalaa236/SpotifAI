import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/chatbot/chatbot_api.dart';

import '../../utils/app_bloc.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBot>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSend(String text) async {
    if (text.trim().isEmpty || _isSending) return;
    final appCubit = context.read<AppCubit>();
    appCubit.addChatMessage(Message(text.trim(), true));
    setState(() {
      _isSending = true;
    });
    _controller.clear();

    try {
      final response = await ChatBotApi.sendMessage(
        message: text.trim(),
        conversationId: appCubit.state.conversationId,
      );
      appCubit.setConversationId(response['conversation_id']?.toString());

      List<Song>? songs;
      if (response['songs'] != null) {
        songs =
            (response['songs'] as List<dynamic>).map((e) {
              final songData = e as Map<String, dynamic>;
              final artistList = songData['artists'] as List<dynamic>? ?? [];
              final artistNames = artistList
                  .map((a) => (a as Map<String, dynamic>)['name'] as String)
                  .join(', ');

              return Song(
                id: songData['id'],
                title: songData['title'] as String,
                artist: artistNames,
                albumArt: songData['cover_image'] as String? ?? '',
                audioSource: songData['audio_url'] as String? ?? '',
                duration: '--:--', // Placeholder for duration
              );
            }).toList();
      }

      appCubit.addChatMessage(
        Message(response['message'] ?? 'No response', false, songs: songs),
      );
    } catch (e) {
      appCubit.addChatMessage(Message('Error: ${e.toString()}', false));
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
    final chatMessages = context.watch<AppCubit>().state.chatMessages;

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
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = chatMessages[index];
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
                      child: Column(
                        crossAxisAlignment:
                            msg.isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: [
                          msg.isUser
                              ? Text(
                                msg.text,
                                style: const TextStyle(color: Colors.white),
                              )
                              : MarkdownBody(
                                data: msg.text,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(color: Colors.black87),
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
                          if (msg.songs != null && msg.songs!.isNotEmpty)
                            ...msg.songs!.map(
                              (song) => Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        song.albumArt,
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.music_note,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            song.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            song.artist,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.play_arrow,
                                        color: colorScheme.primary,
                                      ),
                                      onPressed: () {
                                        context.read<AppCubit>().setFooterSongs(
                                          [song],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
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
