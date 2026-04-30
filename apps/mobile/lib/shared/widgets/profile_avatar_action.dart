import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ilab_connect/core/auth/auth_provider.dart';

class ProfileAvatarAction extends ConsumerWidget {
  const ProfileAvatarAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return IconButton(
      onPressed: () => context.push('/profile'),
      icon: _ProfileAvatar(
        imageUrl: authState.user?.image,
        name: authState.user?.name,
        size: 32,
      ),
      tooltip: 'Profile',
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageUrl,
    required this.name,
    required this.size,
  });

  final String? imageUrl;
  final String? name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (imageUrl != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    final initials = _getInitials(name);
    if (initials != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: cs.primaryContainer,
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.w600,
            color: cs.onPrimaryContainer,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: cs.surfaceContainerHighest,
      child: Icon(
        Icons.person,
        size: size * 0.7,
        color: cs.onSurfaceVariant,
      ),
    );
  }

  String? _getInitials(String? name) {
    if (name == null || name.isEmpty) return null;

    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return null;

    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : null;
    }

    final first = words[0].isNotEmpty ? words[0][0] : '';
    final second = words[1].isNotEmpty ? words[1][0] : '';
    return '$first$second'.toUpperCase();
  }
}