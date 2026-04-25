"""ThemeManager — Zen Sudoku 다크 브라운 테마 (#2C1E1A · #5D3A2E · #B35C3D · #D9B99B)."""
import pygame


class ThemeManager:
    # ── Window ───────────────────────────────────────────────────────────────
    WIDTH  = 420
    HEIGHT = 800

    # ── Board layout ─────────────────────────────────────────────────────────
    CELL_SIZE     = 40
    GRID_OFFSET_X = 26     # tray_x(14) + 12
    GRID_OFFSET_Y = 90     # tray_y(78) + 12
    BLOCK_GAP     = 4      # 3×3 블록 사이 간격

    # ── Mobile chrome ────────────────────────────────────────────────────────
    HEADER_H      = 52
    BOTTOM_NAV_H  = 56

    # ── Palette (Zen dark brown) ──────────────────────────────────────────────
    BG_COLOR         = ( 44,  30,  26)   # #2C1E1A  메인 배경
    BG_DEEP          = ( 33,  22,  17)   # 트레이·셀 사이 배경
    PANEL_BG         = ( 55,  38,  29)   # 패널 배경
    CARD_BG          = ( 66,  47,  36)   # 카드 배경

    CELL_COLOR       = ( 58,  40,  31)   # 일반 셀
    CELL_FIXED_BG    = ( 50,  35,  26)   # 고정 숫자 셀 (약간 어둡게)
    SELECTED_COLOR   = (102,  68,  50)   # 선택된 셀
    HIGHLIGHT_COLOR  = ( 68,  48,  37)   # 같은 행/열/박스
    SAME_NUM_COLOR   = ( 88,  60,  44)   # 같은 숫자 셀
    ERROR_BG         = ( 82,  36,  31)   # 오류 셀

    FIXED_NUM_COLOR  = (217, 185, 155)   # #D9B99B 고정 숫자
    USER_NUM_COLOR   = (235, 205, 175)   # 사용자 입력 숫자 (약간 밝게)
    ERROR_COLOR      = (220,  90,  70)   # 오류 숫자
    NOTE_COLOR       = (128,  98,  80)   # 메모 숫자

    TEXT_COLOR       = (217, 185, 155)   # #D9B99B 기본 텍스트
    TEXT_SOFT        = (165, 133, 112)   # 보조 텍스트
    TEXT_MUTE        = (110,  85,  68)   # 흐린 텍스트

    BUTTON_COLOR     = ( 61,  43,  34)   # 버튼 기본
    BUTTON_HOVER     = ( 80,  56,  44)   # 버튼 hover
    BUTTON_ACTIVE    = ( 93,  58,  46)   # 버튼 active
    BUTTON_PRIMARY   = (179,  92,  61)   # #B35C3D 주요 버튼 (rust)
    BUTTON_PRI_DEEP  = (140,  70,  46)   # 주요 버튼 눌림
    BUTTON_DIM       = ( 50,  35,  27)   # 비활성 버튼

    ACCENT_COLOR     = (179,  92,  61)   # #B35C3D 액센트 (rust)
    ACCENT_LIGHT     = (210, 120,  85)   # 밝은 액센트
    DIVIDER          = ( 70,  50,  38)   # 구분선

    PROGRESS_BG      = ( 55,  38,  29)   # 진행 바 배경
    PROGRESS_FG      = (179,  92,  61)   # 진행 바 전경

    SHADOW_DARK      = ( 22,  14,  10)
    SHADOW_LIGHT     = ( 80,  56,  44)

    def __init__(self):
        pygame.font.init()
        self.font_title  = self._load(34, bold=True)
        self.font_large  = self._load(42, bold=True)
        self.font_medium = self._load(26, bold=True)
        self.font_cell   = self._load(28, bold=True)
        self.font_small  = self._load(16, bold=True)
        self.font_tiny   = self._load(12, bold=True)
        self.font_note   = self._load(11, bold=True)
        self.font_label  = self._load(11, bold=True)
        self.font_sub    = self._load(13, bold=False)

    @staticmethod
    def _load(size: int, bold: bool = False) -> pygame.font.Font:
        candidates = [
            "Malgun Gothic", "AppleGothic", "NanumGothic",
            "Noto Sans CJK KR", "Noto Sans KR", "Arial Unicode MS",
        ]
        for name in candidates:
            try:
                path = pygame.font.match_font(name)
                if path:
                    f = pygame.font.Font(path, size)
                    f.set_bold(bold)
                    return f
            except Exception:
                continue
        return pygame.font.SysFont(None, size, bold=bold)

    def draw_soft_rect(self, surface: pygame.Surface, rect: pygame.Rect,
                       color, radius: int = 10,
                       shadow_offset: int = 3, shadow_alpha: int = 55):
        """다크 테마 카드: 둥근 사각형 + 미세한 상단 하이라이트 테두리."""
        pygame.draw.rect(surface, color, rect, border_radius=radius)
        r, g, b = color
        edge = (min(r + 18, 255), min(g + 14, 255), min(b + 10, 255))
        pygame.draw.rect(surface, edge, rect, width=1, border_radius=radius)
