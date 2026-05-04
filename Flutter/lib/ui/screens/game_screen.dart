import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/game_session.dart';
import '../app_theme.dart';
import '../board_painter.dart';
import '../widgets/number_pad.dart';
import '../widgets/action_bar.dart';
import '../widgets/difficulty_tabs.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/game_popup.dart';

/// 게임 화면
/// Python game_window.py draw_game_screen() → Flutter Screen
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event, GameSession session) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowUp) session.moveSelection(-1, 0);
    if (key == LogicalKeyboardKey.arrowDown) session.moveSelection(1, 0);
    if (key == LogicalKeyboardKey.arrowLeft) session.moveSelection(0, -1);
    if (key == LogicalKeyboardKey.arrowRight) session.moveSelection(0, 1);
    if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
      session.erase();
    }
    if (key == LogicalKeyboardKey.keyH) session.hint();
    if (key == LogicalKeyboardKey.keyU) session.undo();
    if (key == LogicalKeyboardKey.keyP) session.togglePause();
    if (key == LogicalKeyboardKey.escape) session.goToMenu();

    // 숫자키 1-9
    for (int n = 1; n <= 9; n++) {
      if (key.keyId == LogicalKeyboardKey.digit1.keyId + n - 1 ||
          key.keyId == LogicalKeyboardKey.numpad1.keyId + n - 1) {
        session.inputNumber(n);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<GameSession>();
    final board = session.board;

    if (board == null || session.isGenerating) {
      return const Scaffold(
        backgroundColor: AppTheme.bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.accentColor),
              SizedBox(height: 16),
              Text('퍼즐 생성 중...', style: TextStyle(color: AppTheme.textSoft)),
            ],
          ),
        ),
      );
    }

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (e) => _handleKey(e, session),
      child: Scaffold(
        backgroundColor: AppTheme.bgColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // ─── Header (y=0..52) ─────────────────────────
                  _GameHeader(session: session),

                  // ─── Board ───────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // 보드
                          SudokuBoardWidget(
                            board: board,
                            selectedRow: session.selectedRow,
                            selectedCol: session.selectedCol,
                            notes: session.notes,
                            onCellTap: session.selectCell,
                          ),

                          const SizedBox(height: 8),

                          // ─── NumberPad (y≈478) ──────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: NumberPad(
                              onNumberTap: session.inputNumber,
                              onErase: session.erase,
                              counts: board.numberCounts(),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ─── ActionBar (y≈538) ───────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: ActionBar(
                              onUndo: session.undo,
                              onErase: session.erase,
                              onNotes: session.toggleNotes,
                              onHint: session.hint,
                              notesMode: session.notesMode,
                              hintsRemaining: GameSession.maxHints - session.hintsUsed,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ─── DifficultyTabs (y≈616) ──────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('난이도 선택', style: AppTheme.softStyle),
                                const SizedBox(height: 6),
                                DifficultyTabs(
                                  selected: session.difficulty,
                                  onSelect: (d) {
                                    session.newGame(d);
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ─── 새 게임 시작 버튼 (y≈672) ────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () => session.newGame(session.difficulty),
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
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  // ─── BottomNav (y=744..800) ──────────────────
                  BottomNav(
                    currentState: session.state,
                    onHome: session.goToMenu,
                    onPlay: () {},
                    onSettings: () {},
                  ),
                ],
              ),

              // ─── 일시정지 오버레이 ──────────────────────────────
              if (session.state == GameState.paused)
                PauseOverlay(onResume: session.resumeGame),

              // ─── WIN / GAME OVER 팝업 ───────────────────────────
              if (session.state == GameState.win || session.state == GameState.gameOver)
                GamePopup(
                  isWin: session.state == GameState.win,
                  timeStr: session.timer.format(),
                  difficulty: session.difficulty,
                  onNewGame: () => session.newGame(session.difficulty),
                  onMenu: session.goToMenu,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 서브 위젯들 ───────────────────────────────────────────────────

class _GameHeader extends StatelessWidget {
  final GameSession session;
  const _GameHeader({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.headerH,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppTheme.bgDeep,
        border: Border(bottom: BorderSide(color: AppTheme.divider, width: 1)),
      ),
      child: Row(
        children: [
          const Text('SUDOKU', style: AppTheme.headerStyle),
          const Spacer(),
          // 타이머
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(session.timer.format(), style: AppTheme.timerStyle),
          ),
          const SizedBox(width: 8),
          // 난이도 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              AppTheme.difficultyLabel(session.difficulty),
              style: const TextStyle(
                fontFamily: AppTheme.fontKorean,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentLight,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 일시정지 버튼
          GestureDetector(
            onTap: session.togglePause,
            child: Icon(
              session.state == GameState.paused
                  ? Icons.play_arrow
                  : Icons.pause,
              color: AppTheme.textSoft,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          // 실수 하트
          Row(
            children: List.generate(
              GameSession.maxMistakes,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  i < session.mistakes ? Icons.favorite_border : Icons.favorite,
                  color: i < session.mistakes
                      ? AppTheme.textMute
                      : AppTheme.errorColor,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

