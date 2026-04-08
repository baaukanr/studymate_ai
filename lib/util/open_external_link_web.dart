import 'dart:html' as html;

import 'package:flutter/material.dart';

Future<void> openExternalLinkImpl(BuildContext context, String url) async {
  html.window.open(url, '_blank');
}
