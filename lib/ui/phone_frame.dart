import 'package:flutter/material.dart';

import 'theme.dart';

class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isPhone = width < 600;
        final isTablet = width >= 600 && width < 1024;

        if (isPhone) {
          return Container(
            color: AppColors.neutral50,
            child: child,
          );
        }

        final shellPadding = isTablet ? 16.0 : 28.0;
        final maxContentWidth = isTablet ? 820.0 : 1280.0;
        final borderRadius = isTablet ? 24.0 : 32.0;

        return Container(
          color: AppColors.background,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(shellPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Container(
                      color: AppColors.neutral50,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

