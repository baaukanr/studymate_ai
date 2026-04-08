import 'package:flutter/material.dart';

import '../../util/open_external_link.dart';
import '../theme.dart';

const _telegramUrl = 'https://t.me/yeraaaaaaa';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  void _openTelegram(BuildContext context) {
    openExternalLink(context, _telegramUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppColors.neutral900,
        title: const Text('Помощь'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Поддержка',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              const Text(
                'По всем вопросам работы приложения, идеям и ошибкам вы можете написать в Telegram — ответим как можно скорее.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  color: AppColors.neutral500,
                ),
              ),
              const SizedBox(height: 28),
              Material(
                color: AppColors.neutral900,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openTelegram(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Row(
                      children: const [
                        Icon(Icons.chat_bubble_outline, color: Colors.white, size: 26),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Написать в Telegram',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(Icons.open_in_new, color: Colors.white70, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                _telegramUrl,
                style: const TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
