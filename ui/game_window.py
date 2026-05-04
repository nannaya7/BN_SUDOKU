"""GameWindow — Zen Sudoku (메뉴 → 게임 전체 흐름)."""
import math
import pygame
import sys

from core.game_state import GameSession, GameState
from utils.save_manager import SaveManager
from utils.score_manager import ScoreManager
from utils.sound_manager import SoundManager
from .theme_manager import ThemeManager
from .board_renderer import BoardRenderer
from .ui_components import (
    NumberPad, ActionBar, DifficultyTabs, DifficultyCardGrid,
    Button, Popup, BottomNav,
)


class GameWindow:
    FPS = 60

    def __init__(self):
        pygame.mixer.pre_init(44100, -16, 1, 256)
        pygame.init()

        self.theme  = ThemeManager()
        self.screen = pygame.display.set_mode((self.theme.WIDTH, self.theme.HEIGHT))
        pygame.display.set_caption("Zen Sudoku")
        self.clock  = pygame.time.Clock()

        self.session = GameSession()           # 초기 상태 = MENU
        self.sound   = SoundManager()

        t = self.theme
        self.board_renderer = BoardRenderer(t)

        # ── 게임 화면 지오메트리 ─────────────────────────────────────────────
        board_total  = t.CELL_SIZE * 9 + t.BLOCK_GAP * 2   # 368
        tray_x       = (t.WIDTH - (board_total + 24)) // 2  # 14
        tray_width   = board_total + 24                     # 392
        tray_y       = t.GRID_OFFSET_Y - 12                 # 78
        tray_bottom  = tray_y + (board_total + 24)          # 470

        # 진행 바 (보드 위) — 헤더(52) 아래 6px 여백 확보
        self._comp_bar_x = tray_x
        self._comp_bar_w = tray_width
        self._comp_bar_y = tray_y - 6                       # 72 (레이블 y=58)

        # 숫자 패드
        numpad_y = tray_bottom + 8                          # 478
        self.number_pad = NumberPad(
            t, (tray_x, numpad_y), tray_width,
            on_input=self._handle_input,
        )

        # 액션 바
        action_y = numpad_y + 52 + 8                        # 538
        self.action_bar = ActionBar(
            t, (tray_x, action_y), tray_width,
            on_undo=self._handle_undo,
            on_erase=self._handle_erase,
            on_notes=self.session.toggle_notes,
            on_hint=self._handle_hint,
        )

        # 난이도 탭 (게임 화면 하단)
        diff_y = action_y + 50 + 28                         # 616  (gap 10→28: "난이도 선택" 레이블 공간 확보)
        self._diff_label_y = diff_y - 18                    # 598  (ActionBar bottom=588 아래 10px)
        self.diff_tabs = DifficultyTabs(
            t, (tray_x, diff_y), tray_width,
            get_selected=lambda: self.selected_difficulty,
            on_select=self._select_difficulty,
        )

        # 새 게임 버튼 (게임 화면) — DifficultyTabs 실제 높이 48px + gap 8px
        new_game_y = diff_y + 48 + 8                        # 672
        self.btn_new_game = Button(
            pygame.Rect(tray_x, new_game_y, tray_width, 44),
            "새 게임 시작", t,
            primary=True,
            on_click=self._start_new_game,
            font=t.font_small,
        )

        # ── 메뉴 화면 컴포넌트 ──────────────────────────────────────────────
        pad   = 16
        mw    = t.WIDTH - pad * 2                           # 388px 사용 가능

        # SELECT LEVEL 2×2 카드 (메뉴 화면)
        # IN PROGRESS 카드가 있을 때: cards_y=220, 없을 때: cards_y=140
        self._cards_y_with_inprog    = 220
        self._cards_y_without_inprog = 140
        self.diff_cards = DifficultyCardGrid(
            t, (pad, self._cards_y_with_inprog), mw,
            get_selected=lambda: self.selected_difficulty,
            on_select=self._select_difficulty,
        )

        # 새 게임 시작 버튼 (메뉴 화면)
        self.btn_menu_start = Button(
            pygame.Rect(pad, 0, mw, 50),          # y는 draw에서 계산
            "새 게임 시작", t, primary=True,
            on_click=self._start_new_game,
            font=t.font_small,
        )

        # 계속하기 버튼 (IN PROGRESS 카드 안)
        self.btn_continue = Button(
            pygame.Rect(0, 0, 140, 36), "계속하기", t,
            primary=True,
            on_click=self._continue_game,
            font=t.font_label,
        )

        # 불러오기 버튼 (메뉴 화면)
        self.btn_load = Button(
            pygame.Rect(pad, 0, mw, 44), "저장된 게임 불러오기", t,
            on_click=self._load_game,
            font=t.font_small,
        )

        # 하단 내비게이션
        self.bottom_nav = BottomNav(t)

        self.selected_difficulty = "easy"

        # 자동 불러오기 시도 (앱 재시작 시)
        self._try_auto_load()

    # ── 자동 불러오기 ────────────────────────────────────────────────────────

    def _try_auto_load(self):
        data = SaveManager.load()
        if data:
            self.session.from_dict(data)
            self.selected_difficulty = self.session.difficulty
            self.session.go_to_menu()   # 불러온 뒤 메뉴로

    # ── 메인 루프 ────────────────────────────────────────────────────────────

    def run(self):
        running = True
        while running:
            for ev in pygame.event.get():
                if ev.type == pygame.QUIT:
                    self._auto_save()
                    running = False
                self.handle_event(ev)
            self.draw()
            pygame.display.flip()
            self.clock.tick(self.FPS)
        pygame.quit()
        sys.exit(0)

    # ── 이벤트 처리 ──────────────────────────────────────────────────────────

    def handle_event(self, ev: pygame.event.Event):
        s = self.session

        if s.state == GameState.MENU:
            self._handle_menu_event(ev)
            return

        # ── 게임 중 ────────────────────────────────────────────────────────
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
                self._auto_save()
                s.go_to_menu()
                return
            if s.state == GameState.PAUSED and k != pygame.K_p:
                return
            if s.state in (GameState.WIN, GameState.GAME_OVER):
                if k == pygame.K_n:
                    self._start_new_game()
                elif k == pygame.K_ESCAPE:
                    self._auto_save()
                    s.go_to_menu()
                return
            if pygame.K_1 <= k <= pygame.K_9:
                self._handle_input(k - pygame.K_0)
            elif pygame.K_KP1 <= k <= pygame.K_KP9:
                self._handle_input(k - pygame.K_KP0)
            elif k in (pygame.K_BACKSPACE, pygame.K_DELETE, pygame.K_0):
                self._handle_erase()
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
                self._handle_hint()
            elif k == pygame.K_u:
                self._handle_undo()
            elif k == pygame.K_p:
                s.toggle_pause()

    def _handle_menu_event(self, ev: pygame.event.Event):
        s = self.session
        has_game = s.has_active_game()

        self.diff_cards.handle_event(ev)
        self.btn_menu_start.handle_event(ev)
        self.bottom_nav.handle_event(ev)
        if has_game:
            self.btn_continue.handle_event(ev)
        if SaveManager.exists() and not has_game:
            self.btn_load.handle_event(ev)

        if ev.type == pygame.KEYDOWN and ev.key == pygame.K_ESCAPE:
            pygame.event.post(pygame.event.Event(pygame.QUIT))

    # ── 사운드 래핑 입력 처리 ────────────────────────────────────────────────

    def _handle_input(self, num: int):
        s = self.session
        before_mistakes = s.mistakes
        before_state    = s.state
        s.input_number(num)
        if s.state == GameState.WIN:
            self.sound.play("clear")
            ScoreManager.update(s.difficulty, int(s.timer.get_elapsed()))
            SaveManager.delete()
        elif s.mistakes > before_mistakes:
            self.sound.play("error")
        else:
            self.sound.play("input")

    def _handle_erase(self):
        self.session.erase()
        self.sound.play("erase")

    def _handle_hint(self):
        before = self.session.hints_used
        self.session.hint()
        if self.session.hints_used > before:
            self.sound.play("hint")

    def _handle_undo(self):
        self.session.undo()
        self.sound.play("erase")

    # ── 내부 동작 ────────────────────────────────────────────────────────────

    def _select_difficulty(self, key: str):
        self.selected_difficulty = key

    def _start_new_game(self):
        SaveManager.delete()
        self.session.new_game(self.selected_difficulty)

    def _continue_game(self):
        self.session.resume()

    def _load_game(self):
        data = SaveManager.load()
        if data and self.session.from_dict(data):
            self.selected_difficulty = self.session.difficulty

    def _auto_save(self):
        s = self.session
        if s.has_active_game() and s.state not in (GameState.WIN, GameState.GAME_OVER):
            data = s.to_dict()
            if data:
                SaveManager.save(data)

    # ── 그리기 ───────────────────────────────────────────────────────────────

    def draw(self):
        s = self.session
        if s.state == GameState.MENU:
            self._draw_menu_screen()
        else:
            self._draw_game_screen()

    # ── 메뉴 화면 ────────────────────────────────────────────────────────────

    def _draw_menu_screen(self):
        t = self.theme
        s = self.session
        self.screen.fill(t.BG_COLOR)
        self._draw_header()

        pad      = 16
        mw       = t.WIDTH - pad * 2
        has_game = s.has_active_game()
        y        = t.HEADER_H + 16

        # ── IN PROGRESS 섹션 ──────────────────────────────────────────────
        if has_game and s.board is not None:
            sec_lbl = t.font_tiny.render("IN PROGRESS", True, t.TEXT_MUTE)
            self.screen.blit(sec_lbl, (pad, y))
            y += 20

            card = pygame.Rect(pad, y, mw, 110)
            t.draw_soft_rect(self.screen, card, t.CARD_BG, radius=14)

            # 진행 바
            filled = sum(1 for r in range(9) for c in range(9)
                         if s.board.grid[r][c] != 0)
            pct    = filled / 81
            bar_bg = pygame.Rect(card.x + 12, card.y + 70, card.width - 24, 5)
            pygame.draw.rect(self.screen, t.PROGRESS_BG, bar_bg, border_radius=3)
            if pct > 0:
                bar_fg = pygame.Rect(bar_bg.x, bar_bg.y,
                                     max(5, int(bar_bg.width * pct)), 5)
                pygame.draw.rect(self.screen, t.PROGRESS_FG, bar_fg, border_radius=3)

            # 난이도 배지
            badge = t.font_tiny.render(s.difficulty.upper(), True, (245, 220, 195))
            b_rect = pygame.Rect(card.x + 12, card.y + 10,
                                 badge.get_width() + 10, 16)
            pygame.draw.rect(self.screen, t.BUTTON_PRIMARY, b_rect, border_radius=4)
            self.screen.blit(badge, badge.get_rect(center=b_rect.center))

            # 제목
            title = t.font_small.render("Continue Last Game", True, t.TEXT_COLOR)
            self.screen.blit(title, (card.x + 12, card.y + 32))

            # 타이머
            elapsed = t.font_tiny.render(s.timer.format(), True, t.TEXT_SOFT)
            self.screen.blit(elapsed, (card.right - elapsed.get_width() - 12,
                                       card.y + 12))

            # 완성도 텍스트
            pct_txt = t.font_label.render(f"{int(pct*100)}% Complete",
                                          True, t.TEXT_MUTE)
            self.screen.blit(pct_txt, (card.x + 12, card.y + 82))

            # 계속하기 버튼
            self.btn_continue.rect = pygame.Rect(
                card.right - 152, card.y + 28, 140, 36)
            self.btn_continue.draw(self.screen)

            y += 120

        # ── SELECT LEVEL 섹션 ─────────────────────────────────────────────
        sec_lbl2 = t.font_tiny.render("SELECT LEVEL", True, t.TEXT_MUTE)
        self.screen.blit(sec_lbl2, (pad, y))
        y += 20

        # DifficultyCardGrid 위치 재계산
        self.diff_cards._rects.clear()
        gap = 10
        cw  = (mw - gap) // 2
        ch  = 100
        for i in range(4):
            col = i % 2
            row = i // 2
            rx  = pad + col * (cw + gap)
            ry  = y + row * (ch + gap)
            self.diff_cards._rects.append(pygame.Rect(rx, ry, cw, ch))
        self.diff_cards.draw(self.screen)
        y += 2 * ch + gap + 14

        # ── 새 게임 시작 버튼 ──────────────────────────────────────────────
        self.btn_menu_start.rect = pygame.Rect(pad, y, mw, 50)
        self.btn_menu_start.draw(self.screen)
        y += 60

        # ── 저장된 게임 불러오기 버튼 (진행 중 게임 없고 저장 파일 있을 때) ──
        if not has_game and SaveManager.exists():
            self.btn_load.rect = pygame.Rect(pad, y, mw, 44)
            self.btn_load.draw(self.screen)

        # ── 최고기록 표시 ──────────────────────────────────────────────────
        bests = ScoreManager.all_bests()
        if bests:
            by = t.HEIGHT - t.BOTTOM_NAV_H - 14 - len(bests) * 18
            for diff, secs in bests.items():
                rec = t.font_label.render(
                    f"{diff.upper()}  최고: {ScoreManager.format_time(secs)}",
                    True, t.TEXT_MUTE)
                self.screen.blit(rec, (pad, by))
                by += 18

        self.bottom_nav.draw(self.screen)

    # ── 게임 화면 ────────────────────────────────────────────────────────────

    def _draw_game_screen(self):
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
            best = ScoreManager.get_best(s.difficulty)
            msg  = f"클리어: {s.timer.format()}"
            if best:
                msg += f"  최고: {ScoreManager.format_time(best)}"
            Popup.draw_overlay(self.screen, t, "훌륭해요!", msg)
        elif s.state == GameState.GAME_OVER:
            Popup.draw_overlay(self.screen, t, "게임 오버",
                               f"실수 {s.mistakes}회 · N: 재도전")

    # ── 공통 헤더 ────────────────────────────────────────────────────────────

    def _draw_header(self):
        t  = self.theme
        s  = self.session
        h  = t.HEADER_H
        cy = h // 2

        pygame.draw.rect(self.screen, t.BG_DEEP, pygame.Rect(0, 0, t.WIDTH, h))
        pygame.draw.line(self.screen, t.DIVIDER, (0, h - 1), (t.WIDTH, h - 1), 1)

        # 햄버거 아이콘
        hx = 16
        for dy in (-6, 0, 6):
            pygame.draw.line(self.screen, t.TEXT_SOFT,
                             (hx, cy + dy), (hx + 18, cy + dy), 2)

        # ZEN SUDOKU (가운데)
        cx          = t.WIDTH // 2
        zen_surf    = t.font_tiny.render("ZEN",    True, t.ACCENT_COLOR)
        sudoku_surf = t.font_small.render("SUDOKU", True, t.TEXT_COLOR)
        total_w     = zen_surf.get_width() + 5 + sudoku_surf.get_width()
        sx          = cx - total_w // 2
        self.screen.blit(zen_surf,    zen_surf.get_rect(midleft=(sx, cy)))
        self.screen.blit(sudoku_surf, sudoku_surf.get_rect(
            midleft=(sx + zen_surf.get_width() + 5, cy)))

        # 난이도 배지 + 타이머 (우측)
        right_edge = t.WIDTH - 38
        badge_surf = t.font_tiny.render(s.difficulty.upper(), True, (245, 220, 195))
        time_surf  = t.font_label.render(s.timer.format(), True, t.TEXT_SOFT)
        badge_rect = pygame.Rect(
            right_edge - badge_surf.get_width() - 8,
            cy - 16,
            badge_surf.get_width() + 10,
            15,
        )
        pygame.draw.rect(self.screen, t.BUTTON_PRIMARY, badge_rect, border_radius=4)
        self.screen.blit(badge_surf, badge_surf.get_rect(center=badge_rect.center))
        self.screen.blit(time_surf, time_surf.get_rect(
            midtop=(badge_rect.centerx, badge_rect.bottom + 2)))

        # 설정 아이콘 (우측 끝)
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
        filled  = sum(1 for r in range(9) for c in range(9) if s.board.grid[r][c] != 0)
        total   = 81
        label_y = self._comp_bar_y - 14   # 72-14=58 (헤더 52 아래 6px)
        label   = t.font_label.render("PUZZLE COMPLETION", True, t.TEXT_MUTE)
        count   = t.font_label.render(f"{filled}/{total}", True, t.TEXT_SOFT)
        self.screen.blit(label, (self._comp_bar_x, label_y))
        self.screen.blit(count, (
            self._comp_bar_x + self._comp_bar_w - count.get_width(), label_y))
        self.board_renderer.draw_progress_bar(
            self.screen, filled, total,
            self._comp_bar_x, self._comp_bar_y, self._comp_bar_w, height=6,
        )
