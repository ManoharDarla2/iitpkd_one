import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownCard extends StatelessWidget {
  const MarkdownCard({
    super.key,
    required this.data,
    this.padding = const EdgeInsets.all(14),
  });

  final String data;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: MarkdownBody(
        data: data,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
          p: theme.textTheme.bodyMedium?.copyWith(
            height: 1.48,
            color: cs.onSurface,
          ),
          h1: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          h2: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          h3: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          listBullet: theme.textTheme.bodyMedium?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w800,
          ),
          blockquoteDecoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: cs.primary, width: 3)),
          ),
          blockquotePadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
            ),
          ),
        ),
      ),
    );
  }
}
