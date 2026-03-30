import 'package:flutter/material.dart';

/// Custom search text field styled to match the app's Material 3 design.
///
/// Features a search icon prefix, animated clear button suffix, and
/// rounded container matching the surface/outline system. Calls
/// [onChanged] on every keystroke (the debounce lives in the parent).
class SearchBarField extends StatelessWidget {
  const SearchBarField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.onSubmitted,
    this.focusNode,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        elevation: 1,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.08),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
              width: 0.8,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            textInputAction: TextInputAction.search,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Search campus...',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.65,
                ),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary,
              ),
              suffixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: controller.text.isNotEmpty
                    ? IconButton(
                        key: const ValueKey('clear'),
                        onPressed: onClear,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        tooltip: 'Clear',
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
