import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 난이도별 최고 기록 관리
/// Python utils/score_manager.py → shared_preferences 사용
class ScoreManager {
  static const String _key = 'sudoku_scores';

  /// 저장된 점수 맵 불러오기
  static Future<Map<String, int>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }

  static Future<void> _saveAll(Map<String, int> scores) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(scores));
  }

  /// 난이도별 최고 기록 (초). 없으면 null.
  static Future<int?> getBest(String difficulty) async {
    final scores = await _loadAll();
    return scores[difficulty];
  }

  /// 기록 갱신. 기존 기록보다 좋으면 저장 후 true, 아니면 false.
  static Future<bool> update(String difficulty, int seconds) async {
    final scores = await _loadAll();
    final best = scores[difficulty];
    if (best == null || seconds < best) {
      scores[difficulty] = seconds;
      await _saveAll(scores);
      return true;
    }
    return false;
  }

  /// 초 → "MM:SS"
  static String formatTime(int seconds) {
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  /// 전체 기록 맵
  static Future<Map<String, int>> allBests() async => _loadAll();
}
