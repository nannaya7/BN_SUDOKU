================================================================
  Python 수도쿠 게임 - Pygame 그래픽 버전 Claude Code 가이드
  (Flutter 포팅을 위한 테스트 프로그램 설계)
================================================================

■ 변경 요약
----------------------------------------------------------------
Pygame 그래픽 UI
game_window.py / board_renderer.py / ui_components.py / theme_manager.py


■ 프로젝트 구조
----------------------------------------------------------------
sudoku/
├── main.py
├── requirements.txt
├── README.md
├── assets/
│   ├── fonts/              # .ttf 폰트 파일 (선택)
│   └── sounds/             # .wav 효과음 (선택)
├── core/                   # 변경 없음 - Flutter 재사용 가능
│   ├── __init__.py
│   ├── sudoku_board.py
│   ├── sudoku_generator.py
│   ├── sudoku_solver.py
│   └── game_state.py
├── ui/                     # 전체 교체 (Pygame용)
│   ├── __init__.py
│   ├── game_window.py      # 메인 루프 & 이벤트
│   ├── board_renderer.py   # 보드 그리기
│   ├── ui_components.py    # 버튼, 팝업, 메뉴
│   └── theme_manager.py    # 색상 & 폰트 설정
└── utils/
    ├── __init__.py
    ├── save_manager.py
    ├── score_manager.py
    ├── sound_manager.py
    └── timer.py


■ 아키텍처 레이어 설명
----------------------------------------------------------------
[Core Layer - 변경 없음]
  → Flutter 포팅 시 그대로 Dart로 변환
  → sudoku_board / sudoku_generator / sudoku_solver / game_state

[Pygame UI Layer - 신규 설계]
  → game_window / board_renderer / ui_components / theme_manager

[Utils Layer]
  → save_manager / score_manager / sound_manager / timer


■ 1단계: Core 생성 (기존과 동일)
----------------------------------------------------------------
core/ 폴더의 다음 파일들을 만들어줘:
sudoku_board.py, sudoku_generator.py, sudoku_solver.py, game_state.py

[sudoku_board.py]
- SudokuBoard 클래스
- 9x9 그리드 관리
- is_valid_move(row, col, num) 메서드
- is_complete() 메서드
- get_cell(), set_cell() 메서드
- 원본(고정) 셀과 사용자 입력 셀 구분

[sudoku_generator.py]
- SudokuGenerator 클래스
- generate(difficulty) 메서드 (easy/medium/hard)
- difficulty별 빈칸 수: easy=35, medium=45, hard=55
- 백트래킹으로 완성된 보드 생성 후 셀 제거

[sudoku_solver.py]
- SudokuSolver 클래스
- solve(board) 메서드 (백트래킹)
- has_unique_solution(board) 메서드
- get_hint(board) 메서드 (힌트 1개 반환)

[game_state.py]
- GameState Enum: MENU, DIFFICULTY, PLAYING, PAUSED, WIN, GAME_OVER
- GameSession 클래스: board, timer, mistakes, hints_used 관리
- mistakes가 3이면 GAME_OVER


■ 2단계: Theme Manager
----------------------------------------------------------------
-. folder : /Theme
-. Theme_Color.png
-. Theme_opening_screen.png
-. Theme_play_screen.png


■ 3단계: Board Renderer
----------------------------------------------------------------
ui/board_renderer.py 만들어줘:

BoardRenderer 클래스 (ThemeManager 주입):

- draw_board(surface, board, selected_cell, error_cells)
  - 9x9 셀 배경 그리기 (선택/하이라이트/오류 색상 구분)
  - 셀 안에 숫자 렌더링 (고정/사용자/오류 색상 구분)
  - 얇은 셀 구분선 (1px)
  - 굵은 3x3 박스 구분선 (3px)
  - 바깥 테두리 (4px)

- draw_candidates(surface, board)
  - 후보 숫자를 셀 안에 작은 글씨 3x3 격자로 표시

- 선택된 셀과 같은 숫자인 셀들 자동 하이라이트


■ 4단계: UI Components
----------------------------------------------------------------
ui/ui_components.py 만들어줘:

[Button 클래스]
- __init__(x, y, width, height, text, color)
- draw(surface, font)
- is_clicked(mouse_pos)
- hover 효과 (마우스 올리면 약간 밝아짐)

[NumberPad 클래스]
- 1~9 숫자 버튼 + 지우기 버튼
- 화면 하단에 가로로 배치
- draw(surface), get_clicked_number(mouse_pos)

[Popup 클래스]
- show_message(surface, title, message): 게임 클리어/오버 팝업
- show_pause(surface): 일시정지 오버레이 (반투명)

[StatusBar 클래스]
- 상단에 시간 / 난이도 / 실수횟수(하트) / 힌트남은수 표시
- draw(surface, session)


■ 5단계: Game Window (메인 루프)
----------------------------------------------------------------
ui/game_window.py 만들어줘:

GameWindow 클래스:
- __init__(): pygame 초기화, 화면 생성, 컴포넌트 인스턴스화
- run(): 메인 게임 루프 (60 FPS)

handle_events():
  - 마우스 클릭: 셀 선택, 버튼 클릭
  - 키보드 숫자키(1-9): 숫자 입력
  - 백스페이스: 숫자 지우기
  - 화살표키: 셀 이동
  - H: 힌트
  - U: 실행취소
  - P: 일시정지
  - ESC: 메뉴로 이동

update():
  - 타이머 업데이트
  - 승리/패배 조건 체크

draw():
  - draw_menu_screen(): 메인 메뉴 (새게임 / 불러오기 / 종료)
  - draw_difficulty_screen(): 난이도 선택 (쉬움 / 보통 / 어려움)
  - draw_game_screen(): 실제 게임 화면
  - draw_result_screen(): 결과 화면 (클리어 시간, 재시작)


■ 6단계: Main & Utils
----------------------------------------------------------------
main.py와 utils/ 파일들 만들어줘:

[utils/save_manager.py]
- JSON으로 게임 저장/불러오기
- 파일: sudoku_save.json

[utils/score_manager.py]
- 난이도별 최고기록 저장
- 파일: sudoku_scores.json

[utils/sound_manager.py]
- pygame.mixer로 효과음 재생
- 숫자 입력음, 오류음, 클리어 팬파레
- 사운드 파일 없으면 beep으로 대체

[utils/timer.py]
- 경과 시간 추적
- start(), pause(), resume(), get_elapsed()

[main.py]
- pygame 초기화 후 GameWindow().run() 실행

[requirements.txt]
- pygame>=2.0.0


■ 7단계: 마무리 및 테스트
----------------------------------------------------------------
전체 코드 리뷰해줘:
1. python main.py 실행해서 오류 없는지 확인
2. 마우스로 셀 클릭 → 숫자 입력 → 완료 감지 흐름 테스트
3. 화면 레이아웃이 깔끔하게 보이는지 확인
4. README.md 작성 (설치 방법, 실행 방법, 조작키 포함)


■ 조작키 요약
----------------------------------------------------------------
마우스 클릭   셀 선택 / 버튼 클릭
숫자키 1-9   숫자 입력
백스페이스    숫자 지우기
화살표키      셀 이동
H             힌트
U             실행취소 (Undo)
P             일시정지
ESC           메인 메뉴


■ Flutter 포팅 대응표
----------------------------------------------------------------
Python (Pygame)          →  Flutter
------------------------------------------------------
SudokuBoard              →  Dart 클래스로 그대로 변환
GameSession              →  ChangeNotifier / Riverpod Provider
BoardRenderer            →  CustomPainter (1:1 대응)
ui_components.py         →  StatelessWidget / StatefulWidget
sound_manager.py         →  audioplayers 패키지
save_manager.py (JSON)   →  shared_preferences / Hive
timer.py                 →  dart:async Timer
ThemeManager 색상값      →  ThemeData / ColorScheme

※ core/ 폴더는 Flutter 포팅 시 Dart로 1:1 변환 가능
※ BoardRenderer의 draw 로직은 CustomPainter.paint()로 대응


================================================================
  끝
================================================================