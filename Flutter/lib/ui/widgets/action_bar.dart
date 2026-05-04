import 'package:flutter/material.dart';
import '../app_theme.dart';

/// 게임 액션 바: UNDO / ERASE / NOTES / HINT
/// 각 버튼: 아이콘(Canvas) + 한글 레이블 + 영문 레이블
class ActionBar extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onErase;
  final VoidCallback onNotes;
  final VoidCallback onHint;
  final bool notesMode;
  final int hintsRemaining;

  const ActionBar({
    super.key,
    required this.onUndo,
    required this.onErase,
    required this.onNotes,
    required this.onHint,
    required this.notesMode,
    required this.hintsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: _ActionIcon.undo,
            label: '되돌리기',
            onTap: onUndo,
            active: false,
          ),
          _ActionButton(
            icon: _ActionIcon.erase,
            label: '지우기',
            onTap: onErase,
            active: false,
          ),
          _ActionButton(
            icon: _ActionIcon.notes,
            label: '메모',
            onTap: onNotes,
            active: notesMode,
          ),
          _ActionButton(
            icon: _ActionIcon.hint,
            label: hintsRemaining > 0 ? '힌트 $hintsRemaining' : '힌트',
            onTap: hintsRemaining > 0 ? onHint : null,
            active: false,
            dimmed: hintsRemaining <= 0,
          ),
        ],
      ),
    );
  }
}

enum _ActionIcon { undo, erase, notes, hint }

class _ActionButton extends StatefulWidget {
  final _ActionIcon icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;
  final bool dimmed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.active,
    this.dimmed = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final iconColor = widget.dimmed
        ? AppTheme.textMute
        : widget.active
            ? AppTheme.accentLight
            : AppTheme.textSoft;

    final bg = _pressed && enabled
        ? AppTheme.buttonHover
        : widget.active
            ? AppTheme.buttonColor
            : Colors.transparent;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: Container(
        width: 80,
        height: 50,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: widget.active
              ? Border.all(color: AppTheme.accentColor.withValues(alpha: 0.5), width: 1)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(20, 16),
              painter: _IconPainter(widget.icon, iconColor),
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: AppTheme.fontKorean,
                fontSize: 10,
                color: iconColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconPainter extends CustomPainter {
  final _ActionIcon icon;
  final Color color;
  const _IconPainter(this.icon, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (icon) {
      case _ActionIcon.undo:
        _drawUndo(canvas, size, paint, fillPaint);
      case _ActionIcon.erase:
        _drawErase(canvas, size, paint, fillPaint);
      case _ActionIcon.notes:
        _drawNotes(canvas, size, paint, fillPaint);
      case _ActionIcon.hint:
        _drawHint(canvas, size, paint, fillPaint);
    }
  }

  void _drawUndo(Canvas canvas, Size s, Paint p, Paint fp) {
    // 반원 호
    final rect = Rect.fromCenter(
        center: Offset(s.width / 2, s.height * 0.55),
        width: s.width * 0.75,
        height: s.height * 0.75);
    canvas.drawArc(rect, 3.14 * 0.1, 3.14 * 1.6, false, p);
    // 화살표 머리
    final tip = Offset(s.width * 0.18, s.height * 0.25);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx + 6, tip.dy - 4)
      ..lineTo(tip.dx + 3, tip.dy + 4)
      ..close();
    canvas.drawPath(path, fp);
  }

  void _drawErase(Canvas canvas, Size s, Paint p, Paint fp) {
    // 사각형
    canvas.drawRect(Rect.fromLTWH(2, 2, s.width - 4, s.height - 4), p);
    // 세로선
    canvas.drawLine(Offset(s.width / 2, 2), Offset(s.width / 2, s.height - 2), p);
  }

  void _drawNotes(Canvas canvas, Size s, Paint p, Paint fp) {
    // 연필 폴리곤
    final path = Path()
      ..moveTo(s.width * 0.3, s.height * 0.9)
      ..lineTo(s.width * 0.1, s.height * 0.7)
      ..lineTo(s.width * 0.7, s.height * 0.1)
      ..lineTo(s.width * 0.9, s.height * 0.3)
      ..close();
    canvas.drawPath(path, p);
    canvas.drawLine(
        Offset(s.width * 0.1, s.height * 0.7),
        Offset(s.width * 0.3, s.height * 0.9),
        p..strokeWidth = 2);
  }

  void _drawHint(Canvas canvas, Size s, Paint p, Paint fp) {
    // 원 (전구 머리)
    canvas.drawCircle(Offset(s.width / 2, s.height * 0.4), s.width * 0.3, p);
    // 사각형 (전구 받침)
    canvas.drawRect(
        Rect.fromLTWH(s.width * 0.35, s.height * 0.72, s.width * 0.3, s.height * 0.22),
        p);
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.color != color || old.icon != icon;
}
