import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({Key? key}) : super(key: key);

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  static const _openAiKeyFromEnv = String.fromEnvironment('OPENAI_API_KEY');
  static const _proxyUrlFromEnv = String.fromEnvironment('OPENAI_PROXY_URL');
  String? _openAiKeyOverride;

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

  String get _openAiKey => (_openAiKeyOverride ?? _openAiKeyFromEnv).trim();
  String get _proxyUrl => _proxyUrlFromEnv.trim();

  Future<void> _ensureKey() async {
    if (_openAiKey.isNotEmpty) return;

    final textCtrl = TextEditingController();
    final key = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Подключить AI'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Чтобы чат отвечал реальным текстом, нужен ключ OpenAI.\n'
                'Можно вставить ключ тут (для теста) или запускать через --dart-define.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'sk-...'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(textCtrl.text.trim()),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (key != null && key.isNotEmpty) {
      setState(() => _openAiKeyOverride = key);
    } else {
      setState(() {
        _messages.add(const _ChatMsg.ai(
          'Чтобы AI отвечал, запусти приложение так:\n'
          'flutter run --dart-define=OPENAI_API_KEY=sk-...\n\n'
          'Или вставь ключ в окне подключения.',
        ));
      });
      _scrollToBottom();
    }
  }

  Future<String> _fetchAiReply(String userText) async {
    final history = _messages.map((m) {
      return {
        'role': m.role == _Role.user ? 'user' : 'assistant',
        'content': m.text,
      };
    }).toList();

    // On Web: direct OpenAI call is typically blocked by CORS. Use proxy.
    final mustUseProxy = kIsWeb || _proxyUrl.isNotEmpty;
    if (mustUseProxy) {
      final url = _proxyUrl.isNotEmpty ? _proxyUrl : 'http://localhost:8787/chat';
      final uri = Uri.parse(url);
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
            .timeout(const Duration(seconds: 25));
      } catch (_) {
        return 'Не удалось соединиться с сервером AI. Запусти proxy и попробуй ещё раз.';
      }

      if (res.statusCode < 200 || res.statusCode >= 300) {
        try {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final err = data['error'];
          if (err is Map && err['message'] is String) {
            return 'Ошибка AI: ${(err['message'] as String).trim()}';
          }
        } catch (_) {}
        return 'Ошибка ответа сервера AI (${res.statusCode}).';
      }

      try {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final reply = data['reply'];
        if (reply is String && reply.trim().isNotEmpty) return reply.trim();
      } catch (_) {}
      return 'Не удалось прочитать ответ AI.';
    }

    // Mobile/desktop: direct call (still not recommended for production).
    if (_openAiKey.isEmpty) return 'Ключ OpenAI не задан.';

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': <Map<String, String>>[
        {
          'role': 'system',
          'content':
              'Ты StudyMate AI — дружелюбный помощник студенту. Отвечай по-русски, коротко, ясно и по делу. '
                  'Если вопрос про математику — дай простое объяснение и мини-пример.',
        },
        ...history,
        {'role': 'user', 'content': userText},
      ],
      'temperature': 0.6,
    });

    http.Response res;
    try {
      res = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_openAiKey',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 25));
    } catch (_) {
      return 'Не удалось соединиться с AI. Проверь интернет и попробуй ещё раз.';
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      try {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final err = data['error'];
        if (err is Map && err['message'] is String) {
          return 'Ошибка AI: ${(err['message'] as String).trim()}';
        }
      } catch (_) {}
      return 'Ошибка ответа AI (${res.statusCode}). Попробуй позже.';
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final choices = data['choices'];
    if (choices is List && choices.isNotEmpty) {
      final msg = choices[0]['message'];
      final content = msg is Map ? msg['content'] : null;
      if (content is String && content.trim().isNotEmpty) return content.trim();
    }
    return 'Не удалось прочитать ответ AI.';
  }

  Future<void> _send(String text) async {
    final t = text.trim();
    if (t.isEmpty || _sending) return;

    // If using proxy (web), key is not required in the app.
    if (!(kIsWeb || _proxyUrl.isNotEmpty)) {
      await _ensureKey();
      if (!mounted) return;
      if (_openAiKey.isEmpty) return;
    }

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
        title: const Text('AI Ассистент'),
        actions: [
          IconButton(
            tooltip: 'Подключить ключ',
            onPressed: _sending
                ? null
                : () {
                    if (kIsWeb || _proxyUrl.isNotEmpty) {
                      setState(() {
                        _messages.add(const _ChatMsg.ai(
                          'На Web чат работает через proxy.\n'
                          'Запусти сервер в папке studymate_ai/server и обнови страницу.',
                        ));
                      });
                      _scrollToBottom();
                      return;
                    }
                    _ensureKey();
                  },
            icon: const Icon(Icons.vpn_key),
          ),
        ],
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

            // Быстрые действия
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

            // Ввод
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

