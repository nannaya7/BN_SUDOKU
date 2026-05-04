/// 수도쿠 보드 모델
/// Python sudoku_board.py → Dart 1:1 변환
class SudokuBoard {
  static const int size = 9;
  static const int box = 3;

  /// 현재 그리드 (0 = 빈 칸)
  final List<List<int>> grid;

  /// 고정 셀 여부 (퍼즐 초기값)
  final List<List<bool>> original;

  /// 정답 그리드
  final List<List<int>>? solution;

  SudokuBoard({
    required List<List<int>> grid,
    required List<List<bool>> original,
    this.solution,
  })  : grid = List.generate(9, (r) => List<int>.from(grid[r])),
        original = List.generate(9, (r) => List<bool>.from(original[r]));

  /// 퍼즐 + 정답으로 생성
  factory SudokuBoard.fromPuzzle({
    required List<List<int>> puzzle,
    required List<List<int>> solution,
  }) {
    final orig = List.generate(9, (r) => List.generate(9, (c) => puzzle[r][c] != 0));
    return SudokuBoard(grid: puzzle, original: orig, solution: solution);
  }

  /// 빈 보드 생성
  factory SudokuBoard.empty() {
    final g = List.generate(9, (_) => List.filled(9, 0));
    final o = List.generate(9, (_) => List.filled(9, false));
    return SudokuBoard(grid: g, original: o);
  }

  int getCell(int r, int c) => grid[r][c];

  /// 셀에 값 입력. 고정 셀이면 false 반환.
  bool setCell(int r, int c, int n) {
    if (isFixed(r, c)) return false;
    grid[r][c] = n;
    return true;
  }

  bool isFixed(int r, int c) => original[r][c];

  /// 해당 위치에 num을 놓을 수 있는지 검증 (num==0은 항상 true)
  bool isValidMove(int row, int col, int num) {
    if (num == 0) return true;
    for (int i = 0; i < 9; i++) {
      if (i != col && grid[row][i] == num) return false;
      if (i != row && grid[i][col] == num) return false;
    }
    final br = (row ~/ 3) * 3;
    final bc = (col ~/ 3) * 3;
    for (int r = br; r < br + 3; r++) {
      for (int c = bc; c < bc + 3; c++) {
        if ((r != row || c != col) && grid[r][c] == num) return false;
      }
    }
    return true;
  }

  /// 보드가 완성됐는지 확인
  bool isComplete() {
    if (solution != null) {
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (grid[r][c] != solution![r][c]) return false;
        }
      }
      return true;
    }
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) return false;
        if (!isValidMove(r, c, grid[r][c])) return false;
      }
    }
    return true;
  }

  /// 오류 셀 목록 반환 (정답과 다른 사용자 입력)
  List<(int, int)> findErrors() {
    final errors = <(int, int)>[];
    if (solution == null) return errors;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final v = grid[r][c];
        if (v != 0 && !original[r][c] && v != solution![r][c]) {
          errors.add((r, c));
        }
      }
    }
    return errors;
  }

  /// 숫자 1~9 각각이 보드에 몇 개 있는지 반환 (index 1~9 사용, 0은 미사용)
  List<int> numberCounts() {
    final counts = List<int>.filled(10, 0);
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final v = grid[r][c];
        if (v != 0) counts[v]++;
      }
    }
    return counts;
  }

  /// 현재 채워진 셀 수 (비어있지 않은 칸)
  int filledCount() {
    int count = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] != 0) count++;
      }
    }
    return count;
  }

  SudokuBoard copy() {
    return SudokuBoard(
      grid: List.generate(9, (r) => List<int>.from(grid[r])),
      original: List.generate(9, (r) => List<bool>.from(original[r])),
      solution: solution != null ? List.generate(9, (r) => List<int>.from(solution![r])) : null,
    );
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() => {
        'grid': grid.map((row) => row.toList()).toList(),
        'original': original.map((row) => row.map((b) => b ? 1 : 0).toList()).toList(),
        'solution': solution?.map((row) => row.toList()).toList(),
      };

  factory SudokuBoard.fromJson(Map<String, dynamic> json) {
    final g = (json['grid'] as List).map((r) => (r as List).map((v) => v as int).toList()).toList();
    final o = (json['original'] as List)
        .map((r) => (r as List).map((v) => (v as int) == 1).toList())
        .toList();
    final s = json['solution'] != null
        ? (json['solution'] as List).map((r) => (r as List).map((v) => v as int).toList()).toList()
        : null;
    return SudokuBoard(grid: g, original: o, solution: s);
  }
}
