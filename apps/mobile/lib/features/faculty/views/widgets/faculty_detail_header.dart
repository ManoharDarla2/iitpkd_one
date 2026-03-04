import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_detail.dart';

/// Hero header section for the faculty detail screen.
///
/// Displays a large avatar, name, designation, and department.
class FacultyDetailHeader extends StatelessWidget {
  const FacultyDetailHeader({super.key, required this.detail});

  final FacultyDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 16),
        // Avatar
        CircleAvatar(
          radius: 48,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: detail.imageUrl != null
              ? NetworkImage(detail.imageUrl!)
              : null,
          child: detail.imageUrl == null
              ? Text(
                  _initials(detail.name),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),

        // Name
        Text(
          detail.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Designation
        Text(
          detail.designation,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Department
        Text(
          detail.department,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.replaceAll('Dr. ', '').split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}
