import 'package:flutter/material.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_detail.dart';

/// Displays the detailed information sections of a faculty profile.
///
/// Sections include: Research Areas, Bio, Teaching, Publications,
/// Research Groups, and Additional Info. Sections with no data are hidden.
class FacultyInfoSection extends StatelessWidget {
  const FacultyInfoSection({super.key, required this.detail});

  final FacultyDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Research Areas
          if (detail.researchAreas.isNotEmpty) ...[
            _SectionTitle(
              title: 'Research Areas',
              icon: Icons.science_outlined,
              theme: theme,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: detail.researchAreas.map((area) {
                return Chip(
                  label: Text(area),
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer
                      .withValues(alpha: 0.3),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Bio
          if (detail.biosketch != null && detail.biosketch!.isNotEmpty) ...[
            _SectionTitle(
              title: 'Bio',
              icon: Icons.person_outline_rounded,
              theme: theme,
            ),
            const SizedBox(height: 8),
            Text(
              detail.biosketch!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Teaching
          if (detail.teaching.isNotEmpty) ...[
            _SectionTitle(
              title: 'Teaching',
              icon: Icons.menu_book_outlined,
              theme: theme,
            ),
            const SizedBox(height: 8),
            ...detail.teaching.map(
              (course) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        course,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Publications
          if (detail.publications.isNotEmpty) ...[
            _SectionTitle(
              title: 'Publications',
              icon: Icons.article_outlined,
              theme: theme,
            ),
            const SizedBox(height: 8),
            ...detail.publications.map(
              (pub) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        pub,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Research Groups
          if (detail.researchGroups.isNotEmpty) ...[
            _SectionTitle(
              title: 'Research Groups',
              icon: Icons.groups_outlined,
              theme: theme,
            ),
            const SizedBox(height: 8),
            ...detail.researchGroups.map(
              (group) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.hub_outlined,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        group,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Additional Information
          if (detail.additionalInformation != null &&
              detail.additionalInformation!.isNotEmpty) ...[
            _SectionTitle(
              title: 'Additional Info',
              icon: Icons.info_outline_rounded,
              theme: theme,
            ),
            const SizedBox(height: 8),
            ...detail.additionalInformation!.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        _formatKey(entry.key),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  /// Converts snake_case keys to Title Case.
  String _formatKey(String key) {
    return key
        .split('_')
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

/// Section title with an icon.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.theme,
  });

  final String title;
  final IconData icon;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.secondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
