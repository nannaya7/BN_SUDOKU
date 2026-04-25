"""GameWindow — Zen Sudoku 모바일 세로 레이아웃 (단일 컬럼)."""
import math
import pygame
import sys

from core.game_state import GameSession, GameState
from .theme_manager import ThemeManager
from .board_renderer import BoardRenderer
from .ui_components import (
    NumberPad, ActionBar, DifficultyTabs,
    Button, Popup, BottomNav,
)


class GameWindow:
    FPS = 60

    def __init__(self):
        pygame.init()
        self.theme  = ThemeManager()
        self.screen = pygame.display.set_mode((self.theme.WIDTH, self.theme.HEIGHT))
        pygame.display.set_caption("Zen Sudoku")
        self.clock  = pygame.time.Clock()

        self.session = GameSession()
        self.session.new_game("easy")
        self.selected_difficulty = "easy"

        t = self.theme
        self.board_renderer = BoardRenderer(t)

        # ── 보드 지오메트리 ──────────────────────────────────────────────────
        board_total = t.CELL_SIZE * 9 + t.BLOCK_GAP * 2   # 40*9+4*2 = 368
        tray_x      = (t.WIDTH - (board_total + 24)) // 2  # (420-392)//2 = 14
        tray_width  = board_total + 24                     # 392
        tray_y      = t.GRID_OFFSET_Y - 12                 # 78
        tray_bottom = tray_y + (board_total + 24)          # 470

        # ── 숫자 패드 (보드 바로 아래) ────────────────────────────────────────
        numpad_y = tray_bottom + 8                         # 478
        self.number_pad = NumberPad(
            t, (tray_x, numpad_y), tray_width,
            on_input=self.session.input_number,
        )

        # ── 액션 바 (숫자 패드 아래) ──────────────────────────────────────────
        action_y = numpad_y + 52 + 8                       # 538
        self.action_bar = ActionBar(
            t, (tray_x, action_y), tray_width,
            on_undo=self.session.undo,
            on_erase=self.session.erase,
            on_notes=self.session.toggle_notes,
            on_hint=self.session.hint,
        )

        # ── 난이도 탭 (액션 바 아래) ──────────────────────────────────────────
        diff_y = action_y + 50 + 10                        # 598
        self._diff_label_y = diff_y - 18                   # 580
        self.diff_tabs = DifficultyTabs(
            t, (tray_x, diff_y), tray_width,
            get_selected=lambda: self.selected_difficulty,
            on_select=self._select_difficulty,
        )

        # ── 새 게임 버튼 ──────────────────────────────────────────────────────
        new_game_y = diff_y + 40 + 8                       # 646
        self.btn_new_game = Button(
            pygame.Rect(tray_x, new_game_y, tray_width, 44),
            "새 게임 시작", t,
            primary=True,
            on_click=self._start_new_game,
            font=t.font_small,
        )

        # ── 하단 내비게이션 ────────────────────────────────────────────────────
        self.bottom_nav = BottomNav(t)

        # ── 진행 바 (보드 바로 위) ────────────────────────────────────────────
        self._comp_bar_x = tray_x
        self._comp_bar_w = tray_width
        self._comp_bar_y = tray_y - 10                     # 68

    # ── 메인 루프 ─────────────────────────────────────────────────────────────

    def run(self):
        running = True
        while running:
            for ev in pygame.event.get():
                if ev.type == pygame.QUIT:
                    running = False
                self.handle_event(ev)
            self.draw()
            pygame.display.flip()
            self.clock.tick(self.FPS)
        pygame.quit()
        sys.exit(0)

    # ── 이벤트 처리 ───────────────────────────────────────────────────────────

    def handle_event(self, ev: pygame.event.Event):
        s = self.session

        self.number_pad.handle_event(ev)
        self.action_bar.handle_event(ev)
        self.diff_tabs.handle_event(ev)
        self.btn_new_game.handle_event(ev)
        self.bottom_nav.handle_event(ev)
        self.action_bar.notes_active = s.notes_mode

        if ev.type == pygame.MOUSEBUTTONDOWN and ev.button == 1:
            if s.state == GameState.PLAYING:
                cell = self.board_renderer.point_to_cell(ev.pos)
                if cell:
                    s.selected = cell

        if ev.type == pygame.KEYDOWN:
            k = ev.key
            if k == pygame.K_ESCAPE:
                s.new_game(self.selected_difficulty)
                return
            if s.state == GameState.PAUSED and k != pygame.K_p:
                return
            if s.state in (GameState.WIN, GameState.GAME_OVER):
                if k == pygame.K_n:
                    s.new_game(self.selected_difficulty)
                return

            if pygame.K_1 <= k <= pygame.K_9:
                s.input_number(k - pygame.K_0)
            elif pygame.K_KP1 <= k <= pygame.K_KP9:
                s.input_number(k - pygame.K_KP0)
            elif k in (pygame.K_BACKSPACE, pygame.K_DELETE, pygame.K_0):
                s.erase()
            elif k == pygame.K_UP:
                s.move_selection(-1, 0)
            elif k == pygame.K_DOWN:
                s.move_selection(1, 0)
            elif k == pygame.K_LEFT:
                s.move_selection(0, -1)
            elif k == pygame.K_RIGHT:
                s.move_selection(0, 1)
            elif k == pygame.K_n:
                s.toggle_notes()
            elif k == pygame.K_h:
                s.hint()
            elif k == pygame.K_u:
                s.undo()
            elif k == pygame.K_p:
                s.toggle_pause()

    # ── 그리기 ────────────────────────────────────────────────────────────────

    def draw(self):
        t = self.theme
        s = self.session
        self.screen.fill(t.BG_COLOR)

        self._draw_header()
        self._draw_completion_bar(s)

        if s.board is not None:
            errors = s.board.find_errors()
            self.board_renderer.draw(
                self.screen, s.board.grid, s.board.original,
                s.notes, s.selected, errors,
            )

        counts = [0] * 10
        if s.board:
            for r in range(9):
                for c in range(9):
                    v = s.board.grid[r][c]
                    if v:
                        counts[v] += 1
        self.number_pad.draw(self.screen, counts)
        self.action_bar.draw(self.screen)

        lbl = t.font_label.render("난이도 선택", True, t.TEXT_MUTE)
        self.screen.blit(lbl, (self._comp_bar_x, self._diff_label_y))
        self.diff_tabs.draw(self.screen)
        self.btn_new_game.draw(self.screen)

        self.bottom_nav.draw(self.screen)

        if s.state == GameState.PAUSED:
            Popup.draw_pause(self.screen, t)
        elif s.state == GameState.WIN:
            Popup.draw_overlay(self.screen, t, "훌륭해요!",
                               f"클리어 시간: {s.timer.format()}")
        elif s.state == GameState.GAME_OVER:
            Popup.draw_overlay(self.screen, t, "게임 오버",
                               f"실수 {s.mistakes}회 · N: 재도전")

    def _draw_header(self):
        t  = self.theme
        s  = self.session
        h  = t.HEADER_H
        cy = h // 2

        pygame.draw.rect(self.screen, t.BG_DEEP, pygame.Rect(0, 0, t.WIDTH, h))
        pygame.draw.line(self.screen, t.DIVIDER, (0, h - 1), (t.WIDTH, h - 1), 1)

        # 햄버거 아이콘 (좌측)
        hx = 16
        for dy in (-6, 0, 6):
            pygame.draw.line(self.screen, t.TEXT_SOFT,
                             (hx, cy + dy), (hx + 18, cy + dy), 2)

        # ZEN SUDOKU (가운데)
        cx = t.WIDTH // 2
        zen_surf    = t.font_tiny.render("ZEN",    True, t.ACCENT_COLOR)
        sudoku_surf = t.font_small.render("SUDOKU", True, t.TEXT_COLOR)
        total_w = zen_surf.get_width() + 5 + sudoku_surf.get_width()
        sx = cx - total_w // 2
        self.screen.blit(zen_surf,    zen_surf.get_rect(midleft=(sx, cy)))
        self.screen.blit(sudoku_surf, sudoku_surf.get_rect(
            midleft=(sx + zen_surf.get_width() + 5, cy)))

        # 난이도 배지 + 타이머 (우측)
        right_edge  = t.WIDTH - 38
        badge_surf  = t.font_tiny.render(s.difficulty.upper(), True, (245, 220, 195))
        time_surf   = t.font_label.render(s.timer.format(), True, t.TEXT_SOFT)
        badge_rect  = pygame.Rect(
            right_edge - badge_surf.get_width() - 8,
            cy - 16,
            badge_surf.get_width() + 10,
            15,
        )
        pygame.draw.rect(self.screen, t.BUTTON_PRIMARY, badge_rect, border_radius=4)
        self.screen.blit(badge_surf, badge_surf.get_rect(center=badge_rect.center))
        self.screen.blit(time_surf,  time_surf.get_rect(
            midtop=(badge_rect.centerx, badge_rect.bottom + 2)))

        # 설정 아이콘 (우측 끝 — 원 + 중심점)
        gx, gy = t.WIDTH - 20, cy
        pygame.draw.circle(self.screen, t.TEXT_MUTE, (gx, gy), 9, 2)
        pygame.draw.circle(self.screen, t.TEXT_MUTE, (gx, gy), 3)
        for i in range(4):
            angle = math.pi * i / 2
            pygame.draw.circle(
                self.screen, t.TEXT_MUTE,
                (int(gx + 12 * math.cos(angle)), int(gy + 12 * math.sin(angle))), 2,
            )

    def _draw_completion_bar(self, s: GameSession):
        t = self.theme
        if s.board is None:
            return

        filled = sum(1 for r in range(9) for c in range(9) if s.board.grid[r][c] != 0)
        total  = 81

        label_y = self._comp_bar_y - 14
        label = t.font_label.render("PUZZLE COMPLETION", True, t.TEXT_MUTE)
        count = t.font_label.render(f"{filled}/{total}", True, t.TEXT_SOFT)
        self.screen.blit(label, (self._comp_bar_x, label_y))
        self.screen.blit(count, (
            self._comp_bar_x + self._comp_bar_w - count.get_width(),
            label_y,
        ))
        self.board_renderer.draw_progress_bar(
            self.screen, filled, total,
            self._comp_bar_x, self._comp_bar_y, self._comp_bar_w,
            height=6,
        )

    # ── 내부 동작 ─────────────────────────────────────────────────────────────

    def _select_difficulty(self, key: str):
        self.selected_difficulty = key

    def _start_new_game(self):
        self.session.new_game(self.selected_difficulty)
