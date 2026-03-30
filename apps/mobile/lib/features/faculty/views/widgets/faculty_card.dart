import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_member.dart';

/// A card displaying a faculty member in the list view.
///
/// Shows avatar, name, designation, and department.
/// Taps trigger navigation to the detail screen.
class FacultyCard extends StatelessWidget {
  const FacultyCard({super.key, required this.faculty, required this.onTap});

  final FacultyMember faculty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.06),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
                width: 0.8,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 26,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: faculty.imageUrl != null
                      ? NetworkImage(faculty.imageUrl!)
                      : null,
                  child: faculty.imageUrl == null
                      ? Text(
                          _initials(faculty.name),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        faculty.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        faculty.designation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _shortDepartment(faculty.department),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
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

  /// Abbreviates long department names for the chip display.
  String _shortDepartment(String dept) {
    const abbreviations = {
      'Computer Science and Engineering': 'CSE',
      'Electrical Engineering': 'EE',
      'Mechanical Engineering': 'ME',
      'Humanities and Social Sciences': 'HSS',
    };
    return abbreviations[dept] ?? dept;
  }
}
