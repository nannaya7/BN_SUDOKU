import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/game_session.dart';
import 'ui/app_theme.dart';
import 'ui/screens/menu_screen.dart';
import 'ui/screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 세로 방향 고정
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ZenSudokuApp());
}

class ZenSudokuApp extends StatelessWidget {
  const ZenSudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameSession(),
      child: MaterialApp(
        title: 'Sudoku',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        home: const _AppRouter(),
      ),
    );
  }
}

/// 상태에 따라 MenuScreen ↔ GameScreen 라우팅
class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<GameSession>();

    switch (session.state) {
      case GameState.menu:
      case GameState.difficulty:
        return const MenuScreen();

      case GameState.playing:
      case GameState.paused:
      case GameState.win:
      case GameState.gameOver:
        return const GameScreen();
    }
  }
}
