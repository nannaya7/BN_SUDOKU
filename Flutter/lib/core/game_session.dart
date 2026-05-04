import 'package:flutter/foundation.dart';
import 'sudoku_board.dart';
import 'sudoku_solver.dart';
import 'sudoku_generator.dart';
import '../utils/game_timer.dart';
import '../utils/save_manager.dart';
import '../utils/score_manager.dart';

enum GameState { menu, difficulty, playing, paused, win, gameOver }

/// 히스토리 엔트리 (undo용)
class HistoryEntry {
  final int row, col, prevValue;
  final Set<int> prevNotes;
  const HistoryEntry(this.row, this.col, this.prevValue, this.prevNotes);
}

/// 게임 세션 상태 관리 (ChangeNotifier)
/// Python core/game_state.py → Dart + Provider 변환
class GameSession extends ChangeNotifier {
  static const int maxMistakes = 3;
  static const int maxHints = 3;

  GameState state = GameState.menu;
  String difficulty = 'easy';
  SudokuBoard? board;
  final GameTimer timer = GameTimer();

  int mistakes = 0;
  int hintsUsed = 0;

  // 선택된 셀
  int? selectedRow;
  int? selectedCol;

  // 메모 모드
  bool notesMode = false;

  // 9×9 메모 (각 셀에 Set<int>)
  final List<List<Set<int>>> notes =
      List.generate(9, (_) => List.generate(9, (_) => <int>{}));

  // 실행취소 히스토리
  final List<HistoryEntry> history = [];

  // 생성 중 플래그
  bool isGenerating = false;

  GameSession() {
    timer.onTick = () => notifyListeners();
  }

  // ─── 게임 시작 ───────────────────────────────────────────────

  Future<void> newGame(String diff) async {
    isGenerating = true;
    difficulty = diff;
    notifyListeners();

    // isolate에서 퍼즐 생성
    final data = await compute(generatePuzzleIsolate, diff);

    board = SudokuBoard.fromPuzzle(puzzle: data.puzzle, solution: data.solution);
    _resetSession();
    state = GameState.playing;
    timer.start();
    isGenerating = false;
    notifyListeners();
  }

  void _resetSession() {
    mistakes = 0;
    hintsUsed = 0;
    selectedRow = null;
    selectedCol = null;
    notesMode = false;
    history.clear();
    for (final row in notes) {
      for (final cell in row) {
        cell.clear();
      }
    }
    timer.reset();
  }

  // ─── 화면 전환 ───────────────────────────────────────────────

  void goToMenu() {
    if (state == GameState.playing) timer.pause();
    state = GameState.menu;
    notifyListeners();
  }

  void goToDifficulty() {
    state = GameState.difficulty;
    notifyListeners();
  }

  void resumeGame() {
    if (board == null) return;
    if (state != GameState.paused && state != GameState.menu) return;
    state = GameState.playing;
    timer.resume();
    notifyListeners();
  }

  bool hasActiveGame() =>
      board != null &&
      (state == GameState.menu ||
          state == GameState.playing ||
          state == GameState.paused);

  // ─── 셀 선택 ─────────────────────────────────────────────────

  void selectCell(int r, int c) {
    if (state != GameState.playing) return;
    selectedRow = r;
    selectedCol = c;
    notifyListeners();
  }

  void moveSelection(int dr, int dc) {
    if (state != GameState.playing) return;
    final r = ((selectedRow ?? 0) + dr + 9) % 9;
    final c = ((selectedCol ?? 0) + dc + 9) % 9;
    selectedRow = r;
    selectedCol = c;
    notifyListeners();
  }

  // ─── 숫자 입력 ───────────────────────────────────────────────

  void inputNumber(int num) {
    if (state != GameState.playing) return;
    final r = selectedRow;
    final c = selectedCol;
    if (r == null || c == null) return;
    if (board!.isFixed(r, c)) return;

    if (notesMode) {
      _saveHistory(r, c);
      if (notes[r][c].contains(num)) {
        notes[r][c].remove(num);
      } else {
        notes[r][c].add(num);
      }
      notifyListeners();
      return;
    }

    _saveHistory(r, c);
    board!.setCell(r, c, num);
    notes[r][c].clear();

    // 오류 체크
    if (num != 0 && board!.solution != null && board!.solution![r][c] != num) {
      mistakes++;
      if (mistakes >= maxMistakes) {
        state = GameState.gameOver;
        timer.pause();
        notifyListeners();
        return;
      }
    }

    // 완성 체크
    if (board!.isComplete()) {
      state = GameState.win;
      timer.pause();
      _recordScore();
      _deleteSave();
    }
    notifyListeners();
  }

  void erase() {
    if (state != GameState.playing) return;
    final r = selectedRow;
    final c = selectedCol;
    if (r == null || c == null) return;
    if (board!.isFixed(r, c)) return;
    _saveHistory(r, c);
    board!.setCell(r, c, 0);
    notes[r][c].clear();
    notifyListeners();
  }

  void hint() {
    if (state != GameState.playing) return;
    if (hintsUsed >= maxHints) return;
    final hint = SudokuSolver.getHint(board!.grid);
    if (hint == null) return;
    final (r, c, val) = hint;
    _saveHistory(r, c);
    board!.setCell(r, c, val);
    notes[r][c].clear();
    hintsUsed++;
    selectedRow = r;
    selectedCol = c;

    if (board!.isComplete()) {
      state = GameState.win;
      timer.pause();
      _recordScore();
      _deleteSave();
    }
    notifyListeners();
  }

  void undo() {
    if (state != GameState.playing) return;
    if (history.isEmpty) return;
    final entry = history.removeLast();
    board!.grid[entry.row][entry.col] = entry.prevValue;
    notes[entry.row][entry.col]
      ..clear()
      ..addAll(entry.prevNotes);
    selectedRow = entry.row;
    selectedCol = entry.col;
    notifyListeners();
  }

  void toggleNotes() {
    notesMode = !notesMode;
    notifyListeners();
  }

  void togglePause() {
    if (state == GameState.playing) {
      state = GameState.paused;
      timer.pause();
    } else if (state == GameState.paused) {
      state = GameState.playing;
      timer.resume();
    }
    notifyListeners();
  }

  // ─── 저장 / 불러오기 ──────────────────────────────────────────

  Future<void> saveGame() async {
    if (board == null) return;
    final data = toDict();
    await SaveManager.save(data);
  }

  Future<bool> loadGame() async {
    final data = await SaveManager.load();
    if (data == null) return false;
    return fromDict(data);
  }

  Future<bool> hasSavedGame() async => SaveManager.exists();

  Map<String, dynamic> toDict() {
    final notesJson = List.generate(
        9,
        (r) => List.generate(
            9, (c) => notes[r][c].toList()..sort()));
    return {
      'difficulty': difficulty,
      'board': board?.toJson(),
      'notes': notesJson,
      'mistakes': mistakes,
      'hints_used': hintsUsed,
      'elapsed': timer.elapsed,
    };
  }

  bool fromDict(Map<String, dynamic> data) {
    try {
      difficulty = data['difficulty'] ?? 'easy';
      board = SudokuBoard.fromJson(data['board']);
      mistakes = data['mistakes'] ?? 0;
      hintsUsed = data['hints_used'] ?? 0;
      timer.reset();
      timer.setElapsed((data['elapsed'] as num).toDouble());
      // 메모 복원
      final notesJson = data['notes'] as List;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          notes[r][c] = Set<int>.from((notesJson[r][c] as List).map((v) => v as int));
        }
      }
      state = GameState.playing;
      timer.resume();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── 내부 헬퍼 ───────────────────────────────────────────────

  void _saveHistory(int r, int c) {
    history.add(HistoryEntry(r, c, board!.grid[r][c], Set<int>.from(notes[r][c])));
  }

  Future<void> _recordScore() async {
    final seconds = timer.elapsed.round();
    await ScoreManager.update(difficulty, seconds);
  }

  Future<void> _deleteSave() async {
    await SaveManager.delete();
  }

  @override
  void dispose() {
    timer.dispose();
    super.dispose();
  }
}
