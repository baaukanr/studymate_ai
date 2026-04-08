import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> openExternalLinkImpl(BuildContext context, String url) async {
  await Clipboard.setData(ClipboardData(text: url));
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.showSnackBar(
    SnackBar(
      content: Text('Ссылка скопирована. Вставьте её в браузер или Telegram:\n$url'),
    ),
  );
}
