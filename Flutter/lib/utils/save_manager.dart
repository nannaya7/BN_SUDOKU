import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 게임 저장/불러오기
/// Python utils/save_manager.py → shared_preferences 사용
class SaveManager {
  static const String _key = 'sudoku_save';

  /// 게임 상태 저장
  static Future<void> save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  /// 저장된 게임 불러오기. 없으면 null.
  static Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// 저장된 게임 존재 여부
  static Future<bool> exists() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }

  /// 저장 삭제
  static Future<void> delete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
