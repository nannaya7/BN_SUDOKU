# Sudoku (Python / Pygame + Flutter)

**Sudoku**는 다크 브라운 팔레트(`#2C1E1A · #5D3A2E · #B35C3D · #D9B99B`)로 제작한 수도쿠 게임입니다.
Python/Pygame 버전과 **Flutter 모바일 앱** 버전 두 가지로 제공됩니다.
Core 로직과 UI 레이어가 분리되어 있어 두 플랫폼 간 구조가 1:1 대응됩니다.

---

## 스크린샷

> `python main.py` 실행 후 게임 화면이 나타납니다.

---

## 요구사항

| 항목 | 버전 |
| --- | --- |
| Python | 3.10 이상 |
| pygame | 2.5.0 이상 |

---

## 설치 및 실행

```bash
# 1. 의존성 설치
pip install -r requirements.txt

# 2. 실행
python main.py
```

---

## 실행 파일 빌드 (.exe / 바이너리)

Python 없이 배포 가능한 단일 실행 파일을 생성합니다.

### Windows

```bat
build.bat
```

빌드 완료 후 `dist\Sudoku.exe` 파일 하나만 배포하면 됩니다.

### Mac / Linux

```bash
chmod +x build.sh
./build.sh
```

빌드 완료 후 `dist/Sudoku` 실행 파일이 생성됩니다.

> PyInstaller가 없으면 스크립트가 자동으로 설치합니다.
> 첫 실행은 압축 해제로 인해 2–3초 지연될 수 있습니다.

---

## 게임 사용방법

### 1. 게임 시작

1. 화면 하단 **난이도 탭** (EASY / MED / HARD / EXPERT) 에서 원하는 난이도를 선택합니다.
2. **새 게임 시작** 버튼을 클릭하면 해당 난이도의 새 퍼즐이 생성됩니다.
3. `ESC` 키를 누르면 현재 난이도로 즉시 새 게임을 시작합니다.

### 2. 숫자 입력

| 방법 | 설명 |
| --- | --- |
| 셀 클릭 후 숫자패드 클릭 | 보드 아래 1×9 가로 숫자패드로 입력 |
| 셀 클릭 후 키보드 1–9 | 일반 숫자키 또는 키패드 |
| 방향키 | 셀 이동 |

- 이미 입력된 숫자를 같은 숫자로 다시 입력하면 **자동으로 지워집니다** (토글).
- 오답 입력 시 해당 셀이 빨간색으로 표시되고 **실수 횟수**가 증가합니다.
- 숫자패드 각 버튼 우상단의 작은 숫자는 **보드에 남은 해당 숫자 개수**입니다. 0이 되면 버튼이 흐려집니다.

### 3. 메모(Notes) 모드

- **메모** 버튼 또는 `N` 키로 메모 모드를 켜고 끕니다.
- 메모 모드 활성화 시 입력한 숫자가 셀 안에 **작은 후보 숫자**로 표시됩니다.
- 인접 셀에 숫자가 확정되면 해당 메모가 **자동 삭제**됩니다.

### 4. 보조 기능

| 기능 | 버튼 | 키 | 설명 |
| --- | --- | --- | --- |
| 지우기 | 지우기 / ERASE | Backspace / Delete | 선택 셀의 숫자 또는 메모 삭제 |
| 힌트 | 힌트 / HINT | H | 선택 셀에 정답 자동 입력 (최대 3회) |
| 되돌리기 | 되돌리기 / UNDO | U | 최대 100단계 실행 취소 |
| 일시정지 | — | P | 게임 시간 정지, P로 재개 |

### 5. 게임 종료 조건

| 결과 | 조건 |
| --- | --- |
| 승리 | 81칸 모두 정답으로 채움 |
| 게임 오버 | 실수 3회 초과 |

- 게임 종료 후 `N` 키로 새 게임, `ESC` 키로 즉시 재시작합니다.

---

## 조작키

| 키 | 동작 |
| --- | --- |
| 마우스 클릭 | 셀 선택 / 버튼 클릭 |
| 숫자 1 – 9 | 숫자 입력 (일반 키 / 키패드) |
| Backspace / Delete | 숫자 지우기 |
| 방향키 (위/아래/좌/우) | 셀 이동 (경계에서 반대편으로 순환) |
| N | 메모(Notes) 모드 토글 |
| H | 힌트 사용 (최대 3회) |
| U | 실행 취소 (Undo, 최대 100단계) |
| P | 일시정지 / 재개 |
| ESC | 현재 난이도로 새 게임 시작 |

---

## 게임 규칙

- **실수 3회** 초과 시 게임 오버 (솔루션과 다른 숫자 입력 시 카운트)
- **힌트**는 최대 3회 사용 가능하며, 선택된 셀에 정답을 자동 입력
- **메모 모드** 활성화 시 셀에 후보 숫자를 작게 표시; 다른 셀에 숫자가 채워지면 관련 메모 자동 삭제
- 숫자를 다시 누르면 해당 셀의 값이 지워짐 (토글)

---

## 난이도

| 난이도 | 빈칸 수 |
| --- | --- |
| Easy | 약 35개 |
| Medium | 약 45개 |
| Hard | 약 55개 |
| Expert | 약 60개 이상 |

모든 퍼즐은 **유일해**를 보장합니다.

---

## 프로젝트 구조

```text
BN_SUDOKU/
├── main.py                  # Python 진입점 — GameWindow().run()
├── requirements.txt
├── README.md
│
├── core/                    # 순수 게임 로직 (UI 의존성 없음)
│   ├── sudoku_board.py      # 9x9 보드 상태, 오류 감지
│   ├── sudoku_generator.py  # 백트래킹 기반 퍼즐 생성
│   ├── sudoku_solver.py     # 솔버, 유일해 검증, 힌트
│   └── game_state.py        # GameState(Enum), GameSession(dataclass)
│
├── ui/                      # Pygame UI 레이어
│   ├── theme_manager.py     # 다크 브라운 색상 팔레트, 폰트 로딩
│   ├── board_renderer.py    # 보드 및 셀 렌더링
│   ├── ui_components.py     # Button, NumberPad, ActionBar, DifficultyTabs, BottomNav, Popup
│   └── game_window.py       # 메인 루프, 이벤트 처리 (모바일 세로 레이아웃)
│
├── utils/
│   ├── timer.py             # 경과 시간 추적 (start/pause/resume/reset)
│   ├── save_manager.py      # JSON 게임 저장/불러오기
│   └── score_manager.py     # 난이도별 최고기록 저장
│
├── Theme/                   # 디자인 레퍼런스 이미지
│   ├── Theme_Color.png
│   ├── Theme_opening_screen.png
│   └── Theme_play_screen.png
│
└── Flutter/                 # Flutter 모바일 앱 (iOS / Android)
    ├── pubspec.yaml
    ├── lib/
    │   ├── main.dart                    # 앱 진입점, 라우터
    │   ├── core/
    │   │   ├── sudoku_board.dart        # Python SudokuBoard → Dart
    │   │   ├── sudoku_generator.dart    # Python SudokuGenerator → Dart
    │   │   ├── sudoku_solver.dart       # Python SudokuSolver → Dart
    │   │   └── game_session.dart        # ChangeNotifier 상태 관리
    │   ├── ui/
    │   │   ├── app_theme.dart           # 색상/폰트 상수 (ThemeManager 대응)
    │   │   ├── board_painter.dart       # CustomPainter (BoardRenderer 대응)
    │   │   └── screens/
    │   │       ├── menu_screen.dart     # 메인 메뉴
    │   │       └── game_screen.dart     # 게임 화면
    │   └── utils/
    │       ├── game_timer.dart          # dart:async 타이머
    │       ├── save_manager.dart        # shared_preferences 저장
    │       └── score_manager.dart       # 최고기록 관리
    └── assets/
        └── fonts/                       # Inter / Pretendard / SpaceGrotesk
```

---

## 아키텍처

### Core Layer (`core/`)

- **UI 의존성 없는 순수 Python** — Flutter/Dart 포팅 시 1:1 변환 가능
- `SudokuBoard`: 그리드 상태, 고정 셀, 오류 감지
- `SudokuGenerator`: 백트래킹으로 완성된 보드 생성 후 유일해 보장하며 셀 제거
- `SudokuSolver`: 백트래킹 솔버 + 힌트 추출
- `GameSession`: 게임 전체 상태 (선택, 메모, 실수, 힌트, 타이머, Undo 히스토리)

### UI Layer (`ui/`)

- `ThemeManager`: 다크 브라운 색상 상수 + 폰트 로딩 (한글 지원 시스템 폰트 자동 선택) + `draw_soft_rect` 헬퍼
- `BoardRenderer`: 플랫 다크 셀 렌더링, 셀 하이라이트, 메모 표시, 진행 바
- `ui_components`: Button, NumberPad (잔여 숫자 표시), ActionBar (되돌리기/지우기/메모/힌트), DifficultyTabs, BottomNav, Popup
- `GameWindow`: 60 FPS 메인 루프, 키보드·마우스 이벤트 통합, 모바일 단일 컬럼 레이아웃

### 화면 레이아웃 (420×800)

```text
┌─────────────────────────────┐ ← Header (52px): 햄버거 / ZEN SUDOKU / 난이도+시간 / 설정
├─────────────────────────────┤ ← PUZZLE COMPLETION 진행 바
│                             │
│       수도쿠 보드 9×9        │ ← 392px (셀 40px × 9 + 블록 갭)
│                             │
├─────────────────────────────┤ ← 숫자패드 1–9 (52px)
├─────────────────────────────┤ ← 액션바: 되돌리기 / 지우기 / 메모 / 힌트 (50px)
├─────────────────────────────┤ ← 난이도 탭: EASY / MED / HARD / EXPERT (40px)
├─────────────────────────────┤ ← 새 게임 시작 버튼 (44px)
├─────────────────────────────┤
│  PLAY  DAILY  STATS  LEVELS │ ← Bottom Nav (56px)
└─────────────────────────────┘
```

---

## Flutter 포팅 대응표

| Python (Pygame) | Flutter |
| --- | --- |
| `SudokuBoard` | Dart 클래스 (1:1 변환) |
| `GameSession` | `ChangeNotifier` / Riverpod Provider |
| `BoardRenderer` | `CustomPainter` |
| `Button`, `NumberPad`, `ActionBar` | `StatelessWidget` / `StatefulWidget` |
| `timer.py` | `dart:async Timer` |
| `ThemeManager` 색상값 | `ThemeData` / `ColorScheme` |

> `core/` 폴더는 Flutter 포팅 시 Dart로 직접 변환 가능하도록 UI 의존성이 없습니다.

---

## Flutter 앱 실행

```bash
cd Flutter
flutter pub get
flutter run
```

### 폰트

| 용도 | 폰트 | 변수명 |
| --- | --- | --- |
| 숫자 (보드, 패드, 타이머) | Inter Variable | `AppTheme.fontNumber` |
| 한글 UI 텍스트 | Pretendard Variable | `AppTheme.fontKorean` |
| 영문 타이틀 (SUDOKU) | Space Grotesk Bold | `AppTheme.fontEnglish` |

---

## 변경 이력

### V.0.03.100 (2026-05-04)
- **Flutter 앱 추가**: Python/Pygame 로직을 Flutter/Dart로 포팅 완료
  - `core/` → Dart 1:1 변환 (SudokuBoard, Generator, Solver, GameSession)
  - `BoardRenderer` → `CustomPainter` (board_painter.dart)
  - `GameSession` → `ChangeNotifier` + Provider
  - 메뉴 화면, 게임 화면, 숫자 패드, 액션 바, 팝업 구현
- **리팩토링**: 전체 UI 텍스트 한글화 (영문 레이블 제거)
- **폰트 정리**: 한글 텍스트 `fontKorean(Pretendard)`, 숫자 `fontNumber(Inter)` 통일
- **버그 수정**: 홈 화면에서 "계속하기" 클릭 시 게임으로 복귀하지 않는 문제 (`resumeGame()` 상태 조건 수정)
- **UI 개선**: 진행도 바(PUZZLE COMPLETION) 섹션 제거
- **앱 이름**: "Zen Sudoku" → "SUDOKU"
- **Python**: `utils/save_manager.py`, `utils/score_manager.py` 추가

### V.0.02.101 (2026-04-25)
- README.md 전면 개정

### V.0.02.100 (2026-04-25)
- Zen Sudoku 모바일 세로 레이아웃 전환 (420×800)
