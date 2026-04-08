import 'package:flutter/material.dart';

import '../theme.dart';

/// Подпись над полем — как на макете авторизации.
class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const LabeledField({
    Key? key,
    required this.label,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
