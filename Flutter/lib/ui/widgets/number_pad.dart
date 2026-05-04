import 'package:flutter/material.dart';
import '../app_theme.dart';

/// 1~9 숫자 패드 — 9개 완성된 숫자는 비활성화
class NumberPad extends StatelessWidget {
  final void Function(int number) onNumberTap;
  final void Function() onErase;
  /// index 1~9: 보드에 놓인 해당 숫자의 개수
  final List<int> counts;

  const NumberPad({
    super.key,
    required this.onNumberTap,
    required this.onErase,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          for (int n = 1; n <= 9; n++) ...[
            Expanded(
              child: _NumButton(
                label: n.toString(),
                remaining: 9 - (counts.length > n ? counts[n] : 0),
                onTap: () => onNumberTap(n),
              ),
            ),
            if (n < 9) const SizedBox(width: 4),
          ],
          const SizedBox(width: 6),
          Expanded(
            child: _EraseButton(onTap: onErase),
          ),
        ],
      ),
    );
  }
}

class _NumButton extends StatefulWidget {
  final String label;
  final int remaining; // 0이면 완성 → 비활성화
  final VoidCallback onTap;

  const _NumButton({
    required this.label,
    required this.remaining,
    required this.onTap,
  });

  @override
  State<_NumButton> createState() => _NumButtonState();
}

class _NumButtonState extends State<_NumButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final done = widget.remaining <= 0;

    final bg = done
        ? AppTheme.buttonDim
        : _pressed
            ? AppTheme.buttonHover
            : AppTheme.buttonColor;

    final numColor = done ? AppTheme.textMute : AppTheme.userNumColor;
    final cntColor = done ? AppTheme.textMute.withValues(alpha: 0.5) : AppTheme.textMute;

    return GestureDetector(
      onTapDown: done ? null : (_) => setState(() => _pressed = true),
      onTapUp: done
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
      onTapCancel: done ? null : () => setState(() => _pressed = false),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: done ? AppTheme.divider.withValues(alpha: 0.4) : AppTheme.divider,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // 숫자 (중앙)
            Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontFamily: AppTheme.fontNumber,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: numColor,
                ),
              ),
            ),
            // 남은 개수 (우상단, 완성 시 숨김)
            if (!done)
              Positioned(
                top: 4,
                right: 5,
                child: Text(
                  '${widget.remaining}',
                  style: TextStyle(
                    fontFamily: AppTheme.fontNumber,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: cntColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EraseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _EraseButton({required this.onTap});

  @override
  State<_EraseButton> createState() => _EraseButtonState();
}

class _EraseButtonState extends State<_EraseButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _pressed ? AppTheme.buttonHover : AppTheme.buttonColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.divider, width: 1),
        ),
        alignment: Alignment.center,
        child: const Text(
          '⌫',
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.textSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
