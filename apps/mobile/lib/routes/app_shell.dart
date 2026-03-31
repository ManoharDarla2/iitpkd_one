import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BumpedBottomBar(
        currentIndex: currentIndex,
        onTabTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        onCenterAction: () => context.push('/search'),
      ),
    );
  }
}

class _BumpedBottomBar extends StatelessWidget {
  const _BumpedBottomBar({
    required this.currentIndex,
    required this.onTabTap,
    required this.onCenterAction,
  });

  final int currentIndex;
  final ValueChanged<int> onTabTap;
  final VoidCallback onCenterAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const baseHeight = 72.0;
    const bumpRise = 18.0;
    const bumpWidth = 116.0;
    const actionSize = 62.0;

    return SizedBox(
      height: baseHeight + bottomInset + bumpRise,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _BumpBarPainter(
                color: cs.surface,
                shadowColor: cs.shadow.withValues(alpha: 0.12),
                bumpRise: bumpRise,
                bumpWidth: bumpWidth,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: bumpRise + 8,
                  bottom: bottomInset + 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _BottomTab(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Home',
                        selected: currentIndex == 0,
                        onTap: () => onTabTap(0),
                      ),
                    ),
                    Expanded(
                      child: _BottomTab(
                        icon: Icons.calendar_month_outlined,
                        activeIcon: Icons.calendar_month_rounded,
                        label: 'Schedule',
                        selected: currentIndex == 1,
                        onTap: () => onTabTap(1),
                      ),
                    ),
                    const SizedBox(width: 88),
                    Expanded(
                      child: _BottomTab(
                        icon: Icons.groups_outlined,
                        activeIcon: Icons.groups_rounded,
                        label: 'Collab',
                        selected: currentIndex == 2,
                        onTap: () => onTabTap(2),
                      ),
                    ),
                    Expanded(
                      child: _BottomTab(
                        icon: Icons.emoji_events_outlined,
                        activeIcon: Icons.emoji_events_rounded,
                        label: 'Competitions',
                        selected: currentIndex == 3,
                        onTap: () => onTabTap(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 4,
            child: Center(
              child: GestureDetector(
                onTap: onCenterAction,
                child: Container(
                  width: actionSize,
                  height: actionSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary,
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.32),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: cs.onPrimary,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomTab extends StatelessWidget {
  const _BottomTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = selected ? cs.primary : cs.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _BumpBarPainter extends CustomPainter {
  _BumpBarPainter({
    required this.color,
    required this.shadowColor,
    required this.bumpRise,
    required this.bumpWidth,
  });

  final Color color;
  final Color shadowColor;
  final double bumpRise;
  final double bumpWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final halfBump = bumpWidth / 2;
    final topY = bumpRise;

    final path = Path()
      ..moveTo(0, topY)
      ..lineTo(centerX - halfBump, topY)
      ..cubicTo(
        centerX - halfBump * 0.72,
        topY,
        centerX - halfBump * 0.34,
        0,
        centerX,
        0,
      )
      ..cubicTo(
        centerX + halfBump * 0.34,
        0,
        centerX + halfBump * 0.72,
        topY,
        centerX + halfBump,
        topY,
      )
      ..lineTo(size.width, topY)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawShadow(path, shadowColor, 8, true);
    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);

    final stroke = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _BumpBarPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.bumpRise != bumpRise ||
        oldDelegate.bumpWidth != bumpWidth;
  }
}
