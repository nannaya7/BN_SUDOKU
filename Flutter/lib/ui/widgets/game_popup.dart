import 'package:flutter/material.dart';
import '../app_theme.dart';

/// 게임 결과 팝업 (WIN / GAME OVER)
class GamePopup extends StatelessWidget {
  final bool isWin;
  final String timeStr;
  final String difficulty;
  final VoidCallback onNewGame;
  final VoidCallback onMenu;

  const GamePopup({
    super.key,
    required this.isWin,
    required this.timeStr,
    required this.difficulty,
    required this.onNewGame,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.panelBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.divider, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isWin ? '🎉 퍼즐 완성!' : '😞 게임 오버',
              style: const TextStyle(
                fontFamily: AppTheme.fontKorean,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isWin) ...[
              _InfoRow(label: '시간', value: timeStr),
              _InfoRow(
                  label: '난이도', value: AppTheme.difficultyLabel(difficulty)),
            ] else ...[
              const Text(
                '실수를 3번 했습니다.\n다시 도전해보세요!',
                style: TextStyle(color: AppTheme.textSoft, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: onNewGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buttonPrimary,
                  foregroundColor: AppTheme.fixedNumColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  '새 게임 시작',
                  style: TextStyle(
                    fontFamily: AppTheme.fontKorean,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onMenu,
              child: const Text(
                '메인 메뉴',
                style: TextStyle(
                  fontFamily: AppTheme.fontKorean,
                  color: AppTheme.textSoft,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSoft, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// 일시정지 오버레이
class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;

  const PauseOverlay({super.key, required this.onResume});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '일시정지',
            style: TextStyle(
              fontFamily: AppTheme.fontKorean,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: onResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.buttonPrimary,
                foregroundColor: AppTheme.fixedNumColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                '계속하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
