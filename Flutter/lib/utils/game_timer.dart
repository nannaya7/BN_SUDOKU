import 'dart:async';

/// 경과 시간 추적 타이머
/// Python utils/timer.py → Dart 변환
class GameTimer {
  double _accum = 0.0; // 누적 초
  double _start = 0.0; // _running 시작 시각 (DateTime.now().millisecondsSinceEpoch / 1000)
  bool _running = false;

  Timer? _ticker;

  /// 콜백: 매 초 tick
  void Function()? onTick;

  bool get isRunning => _running;

  void reset() {
    _ticker?.cancel();
    _ticker = null;
    _accum = 0.0;
    _start = 0.0;
    _running = false;
  }

  void start() {
    if (_running) return;
    _start = DateTime.now().millisecondsSinceEpoch / 1000.0;
    _running = true;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      onTick?.call();
    });
  }

  void pause() {
    if (!_running) return;
    _accum += DateTime.now().millisecondsSinceEpoch / 1000.0 - _start;
    _running = false;
    _ticker?.cancel();
    _ticker = null;
  }

  void resume() {
    if (_running) return;
    _start = DateTime.now().millisecondsSinceEpoch / 1000.0;
    _running = true;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      onTick?.call();
    });
  }

  /// 경과 시간 (초)
  double getElapsed() {
    if (_running) {
      return _accum + (DateTime.now().millisecondsSinceEpoch / 1000.0 - _start);
    }
    return _accum;
  }

  /// "MM:SS" 포맷
  String format() {
    final total = getElapsed().round();
    final mm = (total ~/ 60).toString().padLeft(2, '0');
    final ss = (total % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  /// 직렬화 (저장용)
  double get elapsed => getElapsed();

  void setElapsed(double seconds) {
    _accum = seconds;
    _start = 0.0;
    _running = false;
  }

  void dispose() {
    _ticker?.cancel();
  }
}
