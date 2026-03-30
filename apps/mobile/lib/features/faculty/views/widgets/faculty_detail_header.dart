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

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.85),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: theme.colorScheme.surface,
            backgroundImage: detail.imageUrl != null
                ? NetworkImage(detail.imageUrl!)
                : null,
            child: detail.imageUrl == null
                ? Text(
                    _initials(detail.name),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            detail.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            detail.designation,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.9,
              ),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            detail.department,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.78,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
