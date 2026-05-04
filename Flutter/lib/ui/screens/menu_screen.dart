import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_session.dart';
import '../../utils/score_manager.dart';
import '../app_theme.dart';
import '../widgets/difficulty_tabs.dart';
import '../widgets/bottom_nav.dart';

/// 메인 메뉴 화면
/// Python game_window.py draw_menu_screen() → Flutter Screen
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Map<String, int> _bestScores = {};
  bool _hasSave = false;
  String _selectedDifficulty = 'easy';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final scores = await ScoreManager.allBests();
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    final session = context.read<GameSession>();
    final hasSave = await session.hasSavedGame();
    if (mounted) {
      setState(() {
        _bestScores = scores;
        _hasSave = hasSave;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<GameSession>();
    final hasActive = session.hasActiveGame();

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────────────
            _MenuHeader(),

            // ─── 스크롤 영역 ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ─── IN PROGRESS 카드 ─────────────────────
                    if (hasActive) ...[
                      _InProgressCard(session: session),
                      const SizedBox(height: 16),
                    ],

                    // ─── 난이도 선택 ──────────────────────────
                    const Text(
                      '난이도 선택',
                      style: TextStyle(
                        fontFamily: AppTheme.fontKorean,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMute,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ─── 난이도 카드 그리드 ───────────────────
                    DifficultyCardGrid(
                      selected: _selectedDifficulty,
                      onSelect: (d) =>
                          setState(() => _selectedDifficulty = d),
                    ),

                    const SizedBox(height: 14),

                    // ─── 새 게임 시작 버튼 ────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => session.newGame(_selectedDifficulty),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.buttonPrimary,
                          foregroundColor: AppTheme.fixedNumColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          '새 게임 시작',
                          style: TextStyle(
                              fontFamily: AppTheme.fontKorean,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ─── 저장된 게임 불러오기 ──────────────────
                    if (!hasActive && _hasSave)
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () async {
                            await session.loadGame();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.divider),
                            foregroundColor: AppTheme.textSoft,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('저장된 게임 불러오기',
                              style: TextStyle(
                                  fontFamily: AppTheme.fontKorean,
                                  fontSize: 14)),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ─── 최고 기록 ─────────────────────────────
                    if (_bestScores.isNotEmpty) ...[
                      const Text(
                        '최고 기록',
                        style: TextStyle(
                          fontFamily: AppTheme.fontKorean,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMute,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _BestScoreTable(scores: _bestScores),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // ─── BottomNav ────────────────────────────────────────
            BottomNav(
              currentState: session.state,
              onHome: () {},
              onPlay: () {
                if (session.hasActiveGame()) session.resumeGame();
              },
              onSettings: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.headerH,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppTheme.bgDeep,
        border: Border(bottom: BorderSide(color: AppTheme.divider, width: 1)),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          const Text('SUDOKU', style: AppTheme.headerStyle),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'v0.2.101',
              style: TextStyle(fontSize: 10, color: AppTheme.textMute),
            ),
          ),
        ],
      ),
    );
  }
}

class _InProgressCard extends StatelessWidget {
  final GameSession session;
  const _InProgressCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final filled = session.board?.filledCount() ?? 0;
    final progress = filled / 81.0;

    return Container(
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  AppTheme.difficultyLabel(session.difficulty),
                  style: const TextStyle(
                      fontFamily: AppTheme.fontKorean,
                      fontSize: 10,
                      color: AppTheme.accentLight,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              const Text('이어하기',
                  style: TextStyle(
                      fontFamily: AppTheme.fontKorean,
                      fontSize: 13,
                      color: AppTheme.textSoft)),
              const Spacer(),
              Text(session.timer.format(), style: AppTheme.timerStyle),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: AppTheme.progressBg,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.progressFg),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.read<GameSession>().resumeGame(),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.accentLight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('계속하기 →',
                  style: TextStyle(
                      fontFamily: AppTheme.fontKorean,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BestScoreTable extends StatelessWidget {
  final Map<String, int> scores;
  const _BestScoreTable({required this.scores});

  @override
  Widget build(BuildContext context) {
    const diffs = ['easy', 'medium', 'hard', 'expert'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider, width: 1),
      ),
      child: Column(
        children: diffs.map((d) {
          final best = scores[d];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Text(AppTheme.difficultyLabel(d),
                    style: const TextStyle(
                        fontFamily: AppTheme.fontKorean,
                        fontSize: 12,
                        color: AppTheme.textSoft)),
                const Spacer(),
                Text(
                  best != null ? ScoreManager.formatTime(best) : '--:--',
                  style: TextStyle(
                    fontFamily: AppTheme.fontNumber,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: best != null ? AppTheme.accentLight : AppTheme.textMute,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
