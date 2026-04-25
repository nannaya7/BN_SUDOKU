"""UI components — Zen Sudoku 다크 테마 (버튼, 숫자패드, 액션바, 난이도탭, 상태바, 팝업)."""
import pygame
from typing import Callable, List, Optional, Set, Tuple

from .theme_manager import ThemeManager
from core.game_state import GameSession, GameState


# ─────────────────────────────────────────────────────────────────────────────
# Button
# ─────────────────────────────────────────────────────────────────────────────

class Button:
    def __init__(self, rect: pygame.Rect, text: str, theme: ThemeManager,
                 on_click: Optional[Callable] = None,
                 primary: bool = False,
                 font: Optional[pygame.font.Font] = None):
        self.rect     = rect
        self.text     = text
        self.t        = theme
        self.on_click = on_click
        self.primary  = primary
        self.hover    = False
        self.active   = False
        self.font     = font or theme.font_small

    def draw(self, surface: pygame.Surface):
        t = self.t
        if self.primary:
            color      = t.BUTTON_PRI_DEEP if self.active else t.BUTTON_PRIMARY
            text_color = (245, 220, 195)
        else:
            color      = t.BUTTON_ACTIVE if self.active else (
                         t.BUTTON_HOVER if self.hover else t.BUTTON_COLOR)
            text_color = t.TEXT_COLOR
        t.draw_soft_rect(surface, self.rect, color, radius=12)
        surf = self.font.render(self.text, True, text_color)
        surface.blit(surf, surf.get_rect(center=self.rect.center))

    def handle_event(self, ev: pygame.event.Event):
        if ev.type == pygame.MOUSEMOTION:
            self.hover = self.rect.collidepoint(ev.pos)
        elif ev.type == pygame.MOUSEBUTTONDOWN and ev.button == 1:
            if self.rect.collidepoint(ev.pos) and self.on_click:
                self.on_click()


# ─────────────────────────────────────────────────────────────────────────────
# NumberPad  (1×9 가로 배열 — 보드 하단)
# ─────────────────────────────────────────────────────────────────────────────

class NumberPad:
    def __init__(self, theme: ThemeManager, origin: Tuple[int, int],
                 width: int, on_input: Callable[[int], None]):
        self.t        = theme
        self.on_input = on_input
        self._buttons: List[Tuple[pygame.Rect, int]] = []
        self._hover   = [False] * 9

        x0, y0 = origin
        bh  = 52
        bw  = (width - 8 * 6) // 9          # 9개 버튼, 8개 간격(6px)
        gap = (width - 9 * bw) // 8
        offset = (width - (9 * bw + 8 * gap)) // 2  # 가운데 정렬

        for i, num in enumerate(range(1, 10)):
            rx = x0 + offset + i * (bw + gap)
            self._buttons.append((pygame.Rect(rx, y0, bw, bh), num))

    def draw(self, surface: pygame.Surface, counts: List[int]):
        t = self.t
        for i, (rect, num) in enumerate(self._buttons):
            remaining = 9 - counts[num]
            color = t.BUTTON_DIM if remaining <= 0 else (
                    t.BUTTON_HOVER if self._hover[i] else t.BUTTON_COLOR)
            t.draw_soft_rect(surface, rect, color, radius=10)
            num_surf = t.font_medium.render(
                str(num), True,
                t.TEXT_MUTE if remaining <= 0 else t.TEXT_COLOR,
            )
            surface.blit(num_surf, num_surf.get_rect(center=rect.center))
            # 남은 개수 표시 (우상단 작은 숫자)
            if remaining > 0:
                cnt = t.font_tiny.render(str(remaining), True, t.TEXT_MUTE)
                surface.blit(cnt, (rect.right - 14, rect.top + 5))

    def handle_event(self, ev: pygame.event.Event):
        if ev.type == pygame.MOUSEMOTION:
            for i, (rect, _) in enumerate(self._buttons):
                self._hover[i] = rect.collidepoint(ev.pos)
        elif ev.type == pygame.MOUSEBUTTONDOWN and ev.button == 1:
            for rect, num in self._buttons:
                if rect.collidepoint(ev.pos):
                    self.on_input(num)
                    return


# ─────────────────────────────────────────────────────────────────────────────
# ActionBar  (UNDO / ERASE / NOTES / HINT — 보드 하단, 숫자패드 위)
# ─────────────────────────────────────────────────────────────────────────────

class ActionBar:
    # (한국어 폰트 호환 아이콘, 영문 레이블)
    _ITEMS = [
        ("되돌리기", "UNDO"),
        ("지우기",   "ERASE"),
        ("메모",     "NOTES"),
        ("힌트",     "HINT"),
    ]

    def __init__(self, theme: ThemeManager, origin: Tuple[int, int], width: int,
                 on_undo: Callable, on_erase: Callable,
                 on_notes: Callable, on_hint: Callable):
        self.t       = theme
        self._cbs    = [on_undo, on_erase, on_notes, on_hint]
        self._rects: List[pygame.Rect] = []
        self._hover  = [False] * 4
        self.notes_active = False

        x0, y0 = origin
        bw  = (width - 3 * 10) // 4
        bh  = 50
        for i in range(4):
            self._rects.append(pygame.Rect(x0 + i * (bw + 10), y0, bw, bh))

    def draw(self, surface: pygame.Surface):
        t = self.t
        for i, (ko_label, en_label) in enumerate(self._ITEMS):
            rect   = self._rects[i]
            active = (i == 2 and self.notes_active)  # index 2 = NOTES/메모
            color  = t.BUTTON_PRIMARY if active else (
                     t.BUTTON_HOVER   if self._hover[i] else t.BUTTON_COLOR)
            t.draw_soft_rect(surface, rect, color, radius=10)
            ko_c  = (245, 220, 195) if active else t.TEXT_COLOR
            en_c  = (245, 220, 195) if active else t.TEXT_MUTE
            ko_surf = t.font_small.render(ko_label, True, ko_c)
            surface.blit(ko_surf, ko_surf.get_rect(
                centerx=rect.centerx, centery=rect.top + 15))
            en_surf = t.font_label.render(en_label, True, en_c)
            surface.blit(en_surf, en_surf.get_rect(
                centerx=rect.centerx, centery=rect.bottom - 11))

    def handle_event(self, ev: pygame.event.Event):
        if ev.type == pygame.MOUSEMOTION:
            for i, rect in enumerate(self._rects):
                self._hover[i] = rect.collidepoint(ev.pos)
        elif ev.type == pygame.MOUSEBUTTONDOWN and ev.button == 1:
            for i, rect in enumerate(self._rects):
                if rect.collidepoint(ev.pos):
                    self._cbs[i]()
                    return


# ─────────────────────────────────────────────────────────────────────────────
# DifficultyTabs  (EASY / MED / HARD / EXPERT)
# ─────────────────────────────────────────────────────────────────────────────

class DifficultyTabs:
    _TABS = [("EASY", "easy"), ("MED", "medium"), ("HARD", "hard"), ("EXPERT", "expert")]

    def __init__(self, theme: ThemeManager, origin: Tuple[int, int], width: int,
                 get_selected: Callable[[], str],
                 on_select: Callable[[str], None]):
        self.t            = theme
        self.get_selected = get_selected
        self.on_select    = on_select
        self._rects: List[pygame.Rect] = []
        self._hover = [False] * 4

        x0, y0 = origin
        bw  = (width - 3 * 8) // 4
        bh  = 48
        for i in range(4):
            self._rects.append(pygame.Rect(x0 + i * (bw + 8), y0, bw, bh))

    def draw(self, surface: pygame.Surface):
        t       = self.t
        current = self.get_selected()
        for i, (label, key) in enumerate(self._TABS):
            rect   = self._rects[i]
            active = (key == current)
            if active:
                color      = t.BUTTON_PRIMARY
                text_color = (245, 220, 195)
            elif self._hover[i]:
                color      = t.BUTTON_HOVER
                text_color = t.TEXT_COLOR
            else:
                color      = t.BUTTON_COLOR
                text_color = t.TEXT_SOFT
            t.draw_soft_rect(surface, rect, color, radius=10)
            surf = t.font_tiny.render(label, True, text_color)
            surface.blit(surf, surf.get_rect(center=rect.center))

    def handle_event(self, ev: pygame.event.Event):
        if ev.type == pygame.MOUSEMOTION:
            for i, rect in enumerate(self._rects):
                self._hover[i] = rect.collidepoint(ev.pos)
        elif ev.type == pygame.MOUSEBUTTONDOWN and ev.button == 1:
            for i, (_, key) in enumerate(self._TABS):
                if self._rects[i].collidepoint(ev.pos):
                    self.on_select(key)
                    return


# ─────────────────────────────────────────────────────────────────────────────
# MiniStatusBar  (우측 패널 상단 — TIME / 실수 / 힌트 카드 3개)
# ─────────────────────────────────────────────────────────────────────────────

class MiniStatusBar:
    def __init__(self, theme: ThemeManager, origin: Tuple[int, int], width: int):
        self.t = theme
        x0, y0 = origin
        cw  = (width - 2 * 12) // 3
        ch  = 72
        gap = (width - 3 * cw) // 2
        self._rects = [
            pygame.Rect(x0 + i * (cw + gap), y0, cw, ch) for i in range(3)
        ]

    def draw(self, surface: pygame.Surface, session: GameSession):
        t = self.t
        items = [
            ("TIME",  session.timer.format()),
            ("실수",  f"{session.mistakes} / {session.max_mistakes}"),
            ("힌트",  str(session.max_hints - session.hints_used)),
        ]
        for i, (label, value) in enumerate(items):
            rect = self._rects[i]
            t.draw_soft_rect(surface, rect, t.CARD_BG, radius=12)
            # 상단 액센트 선
            accent = pygame.Rect(rect.x + 10, rect.y + 7, rect.width - 20, 3)
            pygame.draw.rect(surface, t.ACCENT_COLOR, accent, border_radius=2)
            lbl = t.font_label.render(label, True, t.TEXT_MUTE)
            surface.blit(lbl, lbl.get_rect(midtop=(rect.centerx, rect.top + 15)))
            val = t.font_small.render(value, True, t.TEXT_COLOR)
            surface.blit(val, val.get_rect(midbottom=(rect.centerx, rect.bottom - 10)))


# ─────────────────────────────────────────────────────────────────────────────
# ShortcutsLegend
# ─────────────────────────────────────────────────────────────────────────────

class ShortcutsLegend:
    _ITEMS = [
        ("1–9",    "숫자 입력"),
        ("방향키", "셀 이동"),
        ("N",      "메모 모드"),
        ("H",      "힌트"),
        ("U",      "되돌리기"),
        ("P",      "일시정지"),
        ("⌫ / Del", "지우기"),
    ]

    def __init__(self, theme: ThemeManager, origin: Tuple[int, int]):
        self.t = theme
        self.x, self.y = origin

    def draw(self, surface: pygame.Surface):
        t = self.t
        y = self.y
        for key, desc in self._ITEMS:
            key_surf  = t.font_sub.render(key,  True, t.TEXT_SOFT)
            desc_surf = t.font_sub.render(desc, True, t.TEXT_MUTE)
            surface.blit(key_surf,  (self.x,      y))
            surface.blit(desc_surf, (self.x + 72, y))
            y += 21


# ─────────────────────────────────────────────────────────────────────────────
# Popup
# ─────────────────────────────────────────────────────────────────────────────

class Popup:
    @staticmethod
    def draw_overlay(surface: pygame.Surface, theme: ThemeManager,
                     title: str, message: str):
        overlay = pygame.Surface(surface.get_size(), pygame.SRCALPHA)
        overlay.fill((22, 14, 10, 200))
        surface.blit(overlay, (0, 0))

        w, h = 400, 190
        x    = (surface.get_width()  - w) // 2
        y    = (surface.get_height() - h) // 2
        rect = pygame.Rect(x, y, w, h)
        theme.draw_soft_rect(surface, rect, theme.CARD_BG, radius=20)
        pygame.draw.rect(surface, theme.ACCENT_COLOR, rect, width=2, border_radius=20)

        title_surf = theme.font_large.render(title, True, theme.TEXT_COLOR)
        surface.blit(title_surf, title_surf.get_rect(
            midtop=(rect.centerx, rect.top + 28)))
        msg_surf = theme.font_small.render(message, True, theme.TEXT_SOFT)
        surface.blit(msg_surf, msg_surf.get_rect(
            midtop=(rect.centerx, rect.top + 95)))
        hint_surf = theme.font_label.render(
            "N: 새 게임    ESC: 다시 시작", True, theme.TEXT_MUTE)
        surface.blit(hint_surf, hint_surf.get_rect(
            midbottom=(rect.centerx, rect.bottom - 16)))

    @staticmethod
    def draw_pause(surface: pygame.Surface, theme: ThemeManager):
        Popup.draw_overlay(surface, theme, "일시정지", "P를 눌러 계속하기")


# ─────────────────────────────────────────────────────────────────────────────
# BottomNav  (PLAY / DAILY / STATS / LEVELS)
# ─────────────────────────────────────────────────────────────────────────────

class BottomNav:
    _TABS = [("PLAY", "play"), ("DAILY", "daily"), ("STATS", "stats"), ("LEVELS", "levels")]

    def __init__(self, theme: ThemeManager):
        self.t       = theme
        self._active = "play"
        h  = theme.BOTTOM_NAV_H
        y  = theme.HEIGHT - h
        bw = theme.WIDTH // 4
        self._rects = [pygame.Rect(i * bw, y, bw, h) for i in range(4)]
        self._hover  = [False] * 4

    def draw(self, surface: pygame.Surface):
        t = self.t
        h = t.BOTTOM_NAV_H
        y = t.HEIGHT - h
        pygame.draw.rect(surface, t.BG_DEEP, pygame.Rect(0, y, t.WIDTH, h))
        pygame.draw.line(surface, t.DIVIDER, (0, y), (t.WIDTH, y), 1)

        for i, (label, key) in enumerate(self._TABS):
            rect   = self._rects[i]
            active = (key == self._active)
            color  = t.ACCENT_COLOR if active else (
                     t.TEXT_SOFT if self._hover[i] else t.TEXT_MUTE)
            if active:
                pygame.draw.rect(surface, t.ACCENT_COLOR,
                                 pygame.Rect(rect.x + 12, y + 3, rect.width - 24, 3),
                                 border_radius=2)
            surf = t.font_tiny.render(label, True, color)
            surface.blit(surf, surf.get_rect(center=rect.center))

    def handle_event(self, ev: pygame.event.Event):
        if ev.type == pygame.MOUSEMOTION:
            for i, rect in enumerate(self._rects):
                self._hover[i] = rect.collidepoint(ev.pos)
        elif ev.type == pygame.MOUSEBUTTONDOWN and ev.button == 1:
            for i, (_, key) in enumerate(self._TABS):
                if self._rects[i].collidepoint(ev.pos):
                    self._active = key
                    return
