import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_contact.dart';

/// Displays the contact information (email, phone) for a faculty member.
///
/// Icons use the primary color. Rows are tappable for future deep-linking
/// (mailto:, tel:).
class FacultyContactRow extends StatelessWidget {
  const FacultyContactRow({super.key, required this.contact});

  final FacultyContact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (contact.email == null && contact.phoneNumber == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (contact.email != null)
          _ContactTile(
            icon: Icons.email_outlined,
            text: contact.email!,
            theme: theme,
          ),
        if (contact.phoneNumber != null)
          _ContactTile(
            icon: Icons.phone_outlined,
            text: contact.phoneNumber!,
            theme: theme,
          ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.text,
    required this.theme,
  });

  final IconData icon;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
