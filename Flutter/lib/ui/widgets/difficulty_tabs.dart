import 'package:flutter/material.dart';
import '../app_theme.dart';

/// 난이도 탭 선택 위젯
class DifficultyTabs extends StatelessWidget {
  final String selected;
  final void Function(String difficulty) onSelect;

  const DifficultyTabs({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const _diffs = ['easy', 'medium', 'hard', 'expert'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: _diffs.map((d) {
          final isSelected = d == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(d),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accentColor : AppTheme.buttonColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentLight
                        : AppTheme.divider,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  AppTheme.difficultyLabel(d),
                  style: TextStyle(
                    fontFamily: AppTheme.fontKorean,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppTheme.fixedNumColor : AppTheme.textSoft,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 난이도 카드 그리드 (2×2) - 메뉴 화면용
class DifficultyCardGrid extends StatelessWidget {
  final String selected;
  final void Function(String difficulty) onSelect;

  const DifficultyCardGrid({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const _diffs = ['easy', 'medium', 'hard', 'expert'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.8,
        ),
        itemCount: 4,
        itemBuilder: (ctx, i) {
          final d = _diffs[i];
          final isSelected = d == selected;
          return GestureDetector(
            onTap: () => onSelect(d),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentColor.withValues(alpha: 0.3) : AppTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.accentColor : AppTheme.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppTheme.difficultyLabel(d),
                    style: TextStyle(
                      fontFamily: AppTheme.fontKorean,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppTheme.accentLight : AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppTheme.difficultySubtitle(d),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontKorean,
                      fontSize: 11,
                      color: AppTheme.textSoft,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
