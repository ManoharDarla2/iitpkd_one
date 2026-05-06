import 'package:flutter/material.dart';

class AppLogoTitle extends StatelessWidget {
  const AppLogoTitle({
    super.key,
    required this.title,
    this.logoSize = 36,
    this.spacing = 4,
  });

  final String title;
  final double logoSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          isDark
              ? 'assets/images/app_icon_dark.png'
              : 'assets/images/app_icon_light.png',
          height: logoSize,
        ),
        SizedBox(width: spacing),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
