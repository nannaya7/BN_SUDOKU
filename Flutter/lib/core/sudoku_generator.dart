import 'dart:math';
import 'sudoku_solver.dart';

/// 난이도별 빈 칸 수
const Map<String, int> difficultyHoles = {
  'easy': 35,
  'medium': 45,
  'hard': 55,
  'expert': 62,
};

/// 퍼즐 생성 결과 (compute()용 최상위 함수에서 사용)
class PuzzleData {
  final List<List<int>> puzzle;
  final List<List<int>> solution;
  const PuzzleData(this.puzzle, this.solution);
}

/// 수도쿠 퍼즐 생성기
/// Python sudoku_generator.py → Dart 변환
class SudokuGenerator {
  /// 난이도에 맞는 퍼즐과 정답 쌍을 반환
  static PuzzleData generate(String difficulty) {
    final solution = List.generate(9, (_) => List.filled(9, 0));
    _fillFull(solution);
    final puzzle = List.generate(9, (r) => List<int>.from(solution[r]));

    final holesTarget = difficultyHoles[difficulty] ?? 35;
    final rng = Random();

    // 모든 셀 좌표 셔플
    final cells = [for (int r = 0; r < 9; r++) for (int c = 0; c < 9; c++) (r, c)];
    cells.shuffle(rng);

    int holes = 0;
    for (final (r, c) in cells) {
      if (holes >= holesTarget) break;
      final backup = puzzle[r][c];
      if (backup == 0) continue;
      puzzle[r][c] = 0;
      if (SudokuSolver.hasUniqueSolution(puzzle)) {
        holes++;
      } else {
        puzzle[r][c] = backup;
      }
    }

    return PuzzleData(puzzle, solution);
  }

  static bool _fillFull(List<List<int>> grid) {
    final rng = Random();
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) {
          final nums = List.generate(9, (i) => i + 1)..shuffle(rng);
          for (final n in nums) {
            if (SudokuSolver.canPlace(grid, r, c, n)) {
              grid[r][c] = n;
              if (_fillFull(grid)) return true;
              grid[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }
}

/// compute() isolate 진입점 (최상위 함수여야 함)
PuzzleData generatePuzzleIsolate(String difficulty) {
  return SudokuGenerator.generate(difficulty);
}
