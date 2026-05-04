import 'package:flutter/material.dart';
import '../../core/game_session.dart';
import '../app_theme.dart';

/// 하단 네비게이션 바
class BottomNav extends StatelessWidget {
  final GameState currentState;
  final VoidCallback onHome;
  final VoidCallback onPlay;
  final VoidCallback onSettings;

  const BottomNav({
    super.key,
    required this.currentState,
    required this.onHome,
    required this.onPlay,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.bottomNavH,
      decoration: const BoxDecoration(
        color: AppTheme.bgDeep,
        border: Border(
          top: BorderSide(color: AppTheme.divider, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            label: '홈',
            active: currentState == GameState.menu,
            onTap: onHome,
          ),
          _NavItem(
            icon: Icons.grid_view_outlined,
            label: '게임',
            active: currentState == GameState.playing || currentState == GameState.paused,
            onTap: onPlay,
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: '설정',
            active: false,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.accentColor : AppTheme.textMute;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontKorean,
                fontSize: 10,
                color: color,
                fontWeight: active ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
