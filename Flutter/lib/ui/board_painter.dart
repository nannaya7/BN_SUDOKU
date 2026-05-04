import 'package:flutter/material.dart';
import '../core/sudoku_board.dart';
import 'app_theme.dart';

/// 수도쿠 보드 CustomPainter — cellSize를 외부에서 주입받아 완전 반응형
class BoardPainter extends CustomPainter {
  final SudokuBoard board;
  final int? selectedRow;
  final int? selectedCol;
  final Set<(int, int)> errorCells;
  final List<List<Set<int>>> notes;
  final double cellSize;
  final double blockGap;

  const BoardPainter({
    required this.board,
    this.selectedRow,
    this.selectedCol,
    required this.errorCells,
    required this.notes,
    required this.cellSize,
    required this.blockGap,
  });

  // (0,0) 기준 — 위젯 패딩이 외부에서 처리
  Rect _cellRect(int row, int col) {
    final bc = col ~/ 3;
    final br = row ~/ 3;
    final x = col * cellSize + bc * blockGap;
    final y = row * cellSize + br * blockGap;
    final inset = cellSize * 0.05;
    return Rect.fromLTWH(x + inset, y + inset, cellSize - inset * 2, cellSize - inset * 2);
  }

  Color _cellBg(int r, int c) {
    if (errorCells.contains((r, c))) return AppTheme.errorBg;
    final sr = selectedRow;
    final sc = selectedCol;
    if (sr == r && sc == c) return AppTheme.selectedColor;
    if (sr != null && sc != null) {
      final selVal = board.getCell(sr, sc);
      if (selVal != 0 && board.getCell(r, c) == selVal) return AppTheme.sameNumColor;
      final sameRow = r == sr;
      final sameCol = c == sc;
      final sameBox = (r ~/ 3) == (sr ~/ 3) && (c ~/ 3) == (sc ~/ 3);
      if (sameRow || sameCol || sameBox) return AppTheme.highlightColor;
    }
    if (board.isFixed(r, c)) return AppTheme.cellFixedBg;
    return AppTheme.cellColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawCells(canvas);
    _drawNumbers(canvas);
    _drawBlockLines(canvas, size);
    _drawOuterBorder(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.bgDeep;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ),
      paint,
    );
  }

  void _drawCells(Canvas canvas) {
    final paint = Paint();
    final radius = Radius.circular((cellSize * 0.15).clamp(4, 10));
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        paint.color = _cellBg(r, c);
        canvas.drawRRect(
          RRect.fromRectAndRadius(_cellRect(r, c), radius),
          paint,
        );
      }
    }
  }

  void _drawNumbers(Canvas canvas) {
    final numFontSize = (cellSize * 0.52).clamp(14.0, 36.0);
    final noteFontSize = (cellSize * 0.24).clamp(7.0, 14.0);

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final val = board.getCell(r, c);
        final rect = _cellRect(r, c);

        if (val != 0) {
          final Color numColor;
          if (errorCells.contains((r, c))) {
            numColor = AppTheme.errorColor;
          } else if (board.isFixed(r, c)) {
            numColor = AppTheme.fixedNumColor;
          } else {
            numColor = AppTheme.userNumColor;
          }
          _drawCenteredText(
            canvas,
            val.toString(),
            rect,
            TextStyle(
              fontFamily: AppTheme.fontNumber,
              fontWeight: FontWeight.w700,
              fontSize: numFontSize,
              color: numColor,
            ),
          );
        } else if (notes[r][c].isNotEmpty) {
          _drawNotes(canvas, r, c, rect, noteFontSize);
        }
      }
    }
  }

  void _drawNotes(Canvas canvas, int row, int col, Rect rect, double fontSize) {
    final noteSet = notes[row][col];
    final cw = rect.width / 3;
    final ch = rect.height / 3;
    final style = TextStyle(
      fontFamily: AppTheme.fontNumber,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      color: AppTheme.noteColor,
    );
    for (int n = 1; n <= 9; n++) {
      if (!noteSet.contains(n)) continue;
      final nc = (n - 1) % 3;
      final nr = (n - 1) ~/ 3;
      final nx = rect.left + nc * cw + cw / 2;
      final ny = rect.top + nr * ch + ch / 2;
      _drawCenteredText(
        canvas,
        n.toString(),
        Rect.fromCenter(center: Offset(nx, ny), width: cw, height: ch),
        style,
      );
    }
  }

  void _drawCenteredText(Canvas canvas, String text, Rect rect, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        rect.left + (rect.width - tp.width) / 2,
        rect.top + (rect.height - tp.height) / 2,
      ),
    );
  }

  void _drawBlockLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentColor
      ..strokeWidth = (cellSize * 0.07).clamp(2.0, 4.0);

    for (int b = 1; b <= 2; b++) {
      final v = b * 3 * cellSize + (b - 1) * blockGap + blockGap / 2;
      canvas.drawLine(Offset(v, 0), Offset(v, size.height), paint);
      canvas.drawLine(Offset(0, v), Offset(size.width, v), paint);
    }
  }

  void _drawOuterBorder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.divider
      ..strokeWidth = (cellSize * 0.09).clamp(2.0, 5.0)
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(BoardPainter old) => true;
}

/// 보드 위젯 — 화면 너비에 맞춰 자동 스케일
class SudokuBoardWidget extends StatelessWidget {
  final SudokuBoard board;
  final int? selectedRow;
  final int? selectedCol;
  final List<List<Set<int>>> notes;
  final void Function(int row, int col) onCellTap;

  static const double _blockGap = 4.0;
  static const double _hPad = 14.0;

  const SudokuBoardWidget({
    super.key,
    required this.board,
    this.selectedRow,
    this.selectedCol,
    required this.notes,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final errors = board.findErrors().toSet();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _hPad),
      child: LayoutBuilder(builder: (context, constraints) {
        final boardSize = constraints.maxWidth;
        final cellSize = (boardSize - 2 * _blockGap) / 9;

        return AspectRatio(
          aspectRatio: 1.0,
          child: GestureDetector(
            onTapDown: (d) {
              final rc = _hitTest(d.localPosition, cellSize);
              if (rc != null) onCellTap(rc.$1, rc.$2);
            },
            child: CustomPaint(
              painter: BoardPainter(
                board: board,
                selectedRow: selectedRow,
                selectedCol: selectedCol,
                errorCells: errors,
                notes: notes,
                cellSize: cellSize,
                blockGap: _blockGap,
              ),
            ),
          ),
        );
      }),
    );
  }

  (int, int)? _hitTest(Offset pos, double cs) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final bc = c ~/ 3;
        final br = r ~/ 3;
        final x = c * cs + bc * _blockGap;
        final y = r * cs + br * _blockGap;
        if (Rect.fromLTWH(x, y, cs, cs).contains(pos)) return (r, c);
      }
    }
    return null;
  }
}
