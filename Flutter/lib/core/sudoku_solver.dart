/// 수도쿠 솔버 (백트래킹)
/// Python sudoku_solver.py → Dart 1:1 변환
class SudokuSolver {
  /// 빈 칸 찾기 (row, col) 반환. 없으면 null.
  static (int, int)? _findEmpty(List<List<int>> grid) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) return (r, c);
      }
    }
    return null;
  }

  /// (row, col)에 num을 놓을 수 있는지 검증
  static bool canPlace(List<List<int>> grid, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] == num || grid[i][col] == num) return false;
    }
    final br = (row ~/ 3) * 3;
    final bc = (col ~/ 3) * 3;
    for (int r = br; r < br + 3; r++) {
      for (int c = bc; c < bc + 3; c++) {
        if (grid[r][c] == num) return false;
      }
    }
    return true;
  }

  /// 인플레이스 백트래킹 풀기. 풀리면 true.
  static bool solve(List<List<int>> grid) {
    final empty = _findEmpty(grid);
    if (empty == null) return true;
    final (r, c) = empty;
    for (int n = 1; n <= 9; n++) {
      if (canPlace(grid, r, c, n)) {
        grid[r][c] = n;
        if (solve(grid)) return true;
        grid[r][c] = 0;
      }
    }
    return false;
  }

  /// 해의 개수를 최대 cap까지 셈
  static int countSolutions(List<List<int>> grid, {int cap = 2}) {
    int count = 0;
    void rec() {
      if (count >= cap) return;
      final empty = _findEmpty(grid);
      if (empty == null) {
        count++;
        return;
      }
      final (r, c) = empty;
      for (int n = 1; n <= 9; n++) {
        if (count >= cap) return;
        if (canPlace(grid, r, c, n)) {
          grid[r][c] = n;
          rec();
          grid[r][c] = 0;
        }
      }
    }

    rec();
    return count;
  }

  /// 유일해 여부 확인
  static bool hasUniqueSolution(List<List<int>> grid) {
    final copy = List.generate(9, (r) => List<int>.from(grid[r]));
    return countSolutions(copy, cap: 2) == 1;
  }

  /// 힌트 1개 반환: (row, col, answer). 풀 수 없으면 null.
  static (int, int, int)? getHint(List<List<int>> grid) {
    final solved = List.generate(9, (r) => List<int>.from(grid[r]));
    if (!solve(solved)) return null;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) return (r, c, solved[r][c]);
      }
    }
    return null;
  }
}
