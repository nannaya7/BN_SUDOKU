import 'package:flutter/material.dart';

/// 앱 전체 테마 및 색상 정의
/// Python ThemeManager → AppTheme static constants
class AppTheme {
  AppTheme._();

  // ─── 레이아웃 상수 ──────────────────────────────────────────
  static const double width = 420;
  static const double height = 800;
  static const double cellSize = 40;
  static const double gridOffsetX = 26;
  static const double gridOffsetY = 90;
  static const double blockGap = 4;
  static const double headerH = 52;
  static const double bottomNavH = 56;

  // ─── 색상 ────────────────────────────────────────────────────
  static const Color bgColor = Color.fromRGBO(44, 30, 26, 1);
  static const Color bgDeep = Color.fromRGBO(33, 22, 17, 1);
  static const Color panelBg = Color.fromRGBO(55, 38, 29, 1);
  static const Color cardBg = Color.fromRGBO(66, 47, 36, 1);
  static const Color cellColor = Color.fromRGBO(58, 40, 31, 1);
  static const Color cellFixedBg = Color.fromRGBO(50, 35, 26, 1);
  static const Color selectedColor = Color.fromRGBO(102, 68, 50, 1);
  static const Color highlightColor = Color.fromRGBO(68, 48, 37, 1);
  static const Color sameNumColor = Color.fromRGBO(88, 60, 44, 1);
  static const Color errorBg = Color.fromRGBO(82, 36, 31, 1);

  static const Color fixedNumColor = Color.fromRGBO(217, 185, 155, 1);
  static const Color userNumColor = Color.fromRGBO(235, 205, 175, 1);
  static const Color errorColor = Color.fromRGBO(220, 90, 70, 1);
  static const Color noteColor = Color.fromRGBO(128, 98, 80, 1);

  static const Color textColor = Color.fromRGBO(217, 185, 155, 1);
  static const Color textSoft = Color.fromRGBO(165, 133, 112, 1);
  static const Color textMute = Color.fromRGBO(110, 85, 68, 1);

  static const Color buttonColor = Color.fromRGBO(61, 43, 34, 1);
  static const Color buttonHover = Color.fromRGBO(80, 56, 44, 1);
  static const Color buttonPrimary = Color.fromRGBO(179, 92, 61, 1);
  static const Color buttonPriDeep = Color.fromRGBO(140, 70, 46, 1);
  static const Color buttonDim = Color.fromRGBO(50, 35, 27, 1);

  static const Color accentColor = Color.fromRGBO(179, 92, 61, 1);
  static const Color accentLight = Color.fromRGBO(210, 120, 85, 1);
  static const Color divider = Color.fromRGBO(70, 50, 38, 1);
  static const Color progressBg = Color.fromRGBO(55, 38, 29, 1);
  static const Color progressFg = Color.fromRGBO(179, 92, 61, 1);

  // ─── 폰트 ────────────────────────────────────────────────────
  static const String fontNumber  = 'Inter';        // 숫자 블럭 (보드, 넘버패드, 타이머)
  static const String fontKorean  = 'Pretendard';   // 한글 UI
  static const String fontEnglish = 'SpaceGrotesk'; // 영문 레이블
  static const String fontFamily  = 'SpaceGrotesk'; // 하위호환 alias

  // 숫자 — Inter
  static const TextStyle cellNumberStyle = TextStyle(
    fontFamily: fontNumber,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: userNumColor,
  );
  static const TextStyle fixedNumberStyle = TextStyle(
    fontFamily: fontNumber,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: fixedNumColor,
  );
  static const TextStyle errorNumberStyle = TextStyle(
    fontFamily: fontNumber,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: errorColor,
  );
  static const TextStyle noteNumberStyle = TextStyle(
    fontFamily: fontNumber,
    fontWeight: FontWeight.w700,
    fontSize: 9,
    color: noteColor,
  );
  static const TextStyle numPadStyle = TextStyle(
    fontFamily: fontNumber,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    color: userNumColor,
  );
  static const TextStyle timerStyle = TextStyle(
    fontFamily: fontNumber,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: textColor,
  );

  // 영문 — SpaceGrotesk
  static const TextStyle headerStyle = TextStyle(
    fontFamily: fontEnglish,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: textColor,
    letterSpacing: 2.0,
  );
  static const TextStyle englishLabelStyle = TextStyle(
    fontFamily: fontEnglish,
    fontWeight: FontWeight.w700,
    fontSize: 11,
    color: textMute,
    letterSpacing: 0.5,
  );
  static const TextStyle muteStyle = TextStyle(
    fontFamily: fontEnglish,
    fontWeight: FontWeight.w600,
    fontSize: 11,
    color: textMute,
  );

  // 한글 — Pretendard
  static const TextStyle koreanLabelStyle = TextStyle(
    fontFamily: fontKorean,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: textColor,
  );
  static const TextStyle bodyStyle = TextStyle(
    fontFamily: fontKorean,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: textColor,
  );
  static const TextStyle softStyle = TextStyle(
    fontFamily: fontKorean,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: textSoft,
  );

  // ─── MaterialApp 테마 ─────────────────────────────────────────
  static ThemeData get themeData => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bgColor,
        colorScheme: const ColorScheme.dark(
          surface: bgColor,
          primary: accentColor,
          onPrimary: fixedNumColor,
          secondary: accentLight,
          onSurface: textColor,
        ),
        fontFamily: 'System',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: textColor),
          bodySmall: TextStyle(color: textSoft),
        ),
      );

  // ─── 난이도 라벨 헬퍼 ─────────────────────────────────────────
  static String difficultyLabel(String d) {
    switch (d) {
      case 'easy':   return '쉬움';
      case 'medium': return '보통';
      case 'hard':   return '어려움';
      case 'expert': return '전문가';
      default:       return d;
    }
  }

  static String difficultySubtitle(String d) {
    switch (d) {
      case 'easy':   return '편안하게 즐기기';
      case 'medium': return '균형잡힌 도전';
      case 'hard':   return '집중력이 필요해';
      case 'expert': return '진정한 고수만';
      default:       return '';
    }
  }
}
