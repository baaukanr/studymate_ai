import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/api_base.dart';
import '../theme.dart';

/// Чат через proxy `/chat` (OpenRouter на сервере). Ключ в приложении не нужен.
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({Key? key}) : super(key: key);

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  bool _sending = false;

  final List<_ChatMsg> _messages = [
    const _ChatMsg.ai(
      'Привет! Я твой AI‑помощник. Могу объяснить сложные темы простым языком. Чем помочь?',
    ),
  ];

  final List<String> _quickActions = const [
    'Объясни тему проще',
    'Сделай конспект',
    'Создай тест',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<String> _fetchAiReply(String userText) async {
    final history = _messages.map((m) {
      return {
        'role': m.role == _Role.user ? 'user' : 'assistant',
        'content': m.text,
      };
    }).toList();

    final uri = Uri.parse('${resolveApiBaseUrl()}/chat');
    http.Response res;
    try {
      res = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': userText,
              'history': history,
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      return 'Не удалось связаться с сервером. Запустите proxy (cd server → npm start) и задайте OPENROUTER_API_KEY.';
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      try {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final err = data['error'];
        if (err is Map && err['message'] is String) {
          return (err['message'] as String).trim();
        }
      } catch (_) {}
      return 'Ошибка сервера (${res.statusCode}).';
    }

    try {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final reply = data['reply'];
      if (reply is String && reply.trim().isNotEmpty) return reply.trim();
    } catch (_) {}
    return 'Не удалось прочитать ответ.';
  }

  Future<void> _send(String text) async {
    final t = text.trim();
    if (t.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _messages.add(_ChatMsg.user(t));
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final reply = await _fetchAiReply(t);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMsg.ai(reply));
      });
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    const aiBubble = Color(0xFFF2F2F2);
    const userBubble = AppColors.neutral900;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        foregroundColor: AppColors.neutral900,
        title: const Text('AI Ассистент'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final isUser = m.role == _Role.user;

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? userBubble : aiBubble,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          m.text,
                          style: TextStyle(
                            height: 1.35,
                            fontSize: 18,
                            color: isUser ? Colors.white : AppColors.neutral900,
                            fontWeight: isUser ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Быстрые действия:',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _quickActions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final label = _quickActions[i];
                  return ActionChip(
                    label: Text(label),
                    onPressed: () {
                      if (_sending) return;
                      _send(label);
                    },
                    labelStyle: const TextStyle(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: aiBubble,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.neutral200),
                      ),
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _send,
                        decoration: const InputDecoration(
                          hintText: 'Напиши сообщение…',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: ElevatedButton(
                      onPressed: _sending ? null : () => _send(_controller.text),
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.neutral900,
                        onPrimary: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: _sending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                    ),
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

enum _Role { ai, user }

class _ChatMsg {
  final _Role role;
  final String text;

  const _ChatMsg(this.role, this.text);

  const _ChatMsg.ai(this.text) : role = _Role.ai;
  const _ChatMsg.user(this.text) : role = _Role.user;
}
