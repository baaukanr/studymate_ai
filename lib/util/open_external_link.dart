import 'package:flutter/material.dart';

import 'open_external_link_stub.dart'
    if (dart.library.html) 'open_external_link_web.dart';

/// Открытие URL без url_launcher: на web — новое окно; на mobile — копирование + SnackBar.
Future<void> openExternalLink(BuildContext context, String url) {
  return openExternalLinkImpl(context, url);
}
