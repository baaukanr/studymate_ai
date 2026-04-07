import 'package:flutter/material.dart';

import 'theme.dart';

class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;

    const phoneW = 390.0;
    const phoneH = 844.0;

    final scale = (size.width / phoneW).clamp(0.0, 1.0);
    final scaledH = phoneH * scale;
    final needsScroll = scaledH > size.height;

    final phone = Container(
      width: phoneW,
      height: phoneH,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0B),
        borderRadius: BorderRadius.circular(44),
      ),
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Container(
          color: AppColors.neutral50,
          child: child,
        ),
      ),
    );

    final framed = Center(
      child: Transform.scale(
        scale: scale,
        child: phone,
      ),
    );

    if (!needsScroll) return framed;
    return SingleChildScrollView(child: SizedBox(height: scaledH, child: framed));
  }
}

