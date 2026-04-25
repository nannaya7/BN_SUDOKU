"""BoardRenderer — Zen Sudoku 다크 테마 보드 렌더링."""
import pygame
from typing import List, Optional, Set, Tuple

from .theme_manager import ThemeManager


class BoardRenderer:
    def __init__(self, theme: ThemeManager):
        self.t = theme

    def board_rect(self) -> pygame.Rect:
        total = self.t.CELL_SIZE * 9 + self.t.BLOCK_GAP * 2
        return pygame.Rect(
            self.t.GRID_OFFSET_X - 12,
            self.t.GRID_OFFSET_Y - 12,
            total + 24,
            total + 24,
        )

    def cell_rect(self, row: int, col: int) -> pygame.Rect:
        br, bc = row // 3, col // 3
        x = self.t.GRID_OFFSET_X + col * self.t.CELL_SIZE + bc * self.t.BLOCK_GAP
        y = self.t.GRID_OFFSET_Y + row * self.t.CELL_SIZE + br * self.t.BLOCK_GAP
        return pygame.Rect(x + 2, y + 2, self.t.CELL_SIZE - 4, self.t.CELL_SIZE - 4)

    def point_to_cell(self, pos: Tuple[int, int]) -> Optional[Tuple[int, int]]:
        x, y = pos
        for r in range(9):
            for c in range(9):
                if self.cell_rect(r, c).collidepoint(x, y):
                    return (r, c)
        return None

    def draw(
        self,
        surface: pygame.Surface,
        board_grid: List[List[int]],
        original: List[List[bool]],
        notes: List[List[Set[int]]],
        selected: Optional[Tuple[int, int]],
        error_cells: List[Tuple[int, int]],
    ):
        t = self.t
        tray = self.board_rect()

        # 다크 트레이 배경 (3×3 블록 사이 갭을 자연스럽게 채움)
        pygame.draw.rect(surface, t.BG_DEEP, tray, border_radius=16)
        pygame.draw.rect(surface, t.DIVIDER, tray, width=1, border_radius=16)

        sel_val = board_grid[selected[0]][selected[1]] if selected is not None else 0
        error_set = set(error_cells)

        for r in range(9):
            for c in range(9):
                rect  = self.cell_rect(r, c)
                v     = board_grid[r][c]
                fixed = original[r][c]

                # 셀 배경색 결정
                if (r, c) in error_set:
                    color = t.ERROR_BG
                elif selected == (r, c):
                    color = t.SELECTED_COLOR
                elif selected is not None and sel_val != 0 and v == sel_val:
                    color = t.SAME_NUM_COLOR
                elif selected is not None and (
                    r == selected[0] or c == selected[1]
                    or (r // 3 == selected[0] // 3 and c // 3 == selected[1] // 3)
                ):
                    color = t.HIGHLIGHT_COLOR
                elif fixed:
                    color = t.CELL_FIXED_BG
                else:
                    color = t.CELL_COLOR

                pygame.draw.rect(surface, color, rect, border_radius=7)

                # 숫자 또는 메모 렌더링
                if v != 0:
                    if (r, c) in error_set:
                        num_color = t.ERROR_COLOR
                    elif fixed:
                        num_color = t.FIXED_NUM_COLOR
                    else:
                        num_color = t.USER_NUM_COLOR
                    text = t.font_cell.render(str(v), True, num_color)
                    surface.blit(text, text.get_rect(center=rect.center))
                elif notes[r][c]:
                    self._draw_notes(surface, rect, notes[r][c])

    def draw_progress_bar(
        self,
        surface: pygame.Surface,
        filled: int,
        total: int,
        x: int,
        y: int,
        width: int,
        height: int = 8,
    ):
        t = self.t
        bg = pygame.Rect(x, y, width, height)
        pygame.draw.rect(surface, t.PROGRESS_BG, bg, border_radius=height // 2)
        if total > 0 and filled > 0:
            fill_w = max(height, int(width * filled / total))  # 최소 높이만큼 보임
            fill   = pygame.Rect(x, y, fill_w, height)
            pygame.draw.rect(surface, t.PROGRESS_FG, fill, border_radius=height // 2)

    def _draw_notes(self, surface: pygame.Surface, cell_rect: pygame.Rect, marks: Set[int]):
        t     = self.t
        sub_w = cell_rect.width / 3
        sub_h = cell_rect.height / 3
        for n in marks:
            i = (n - 1) // 3
            j = (n - 1) % 3
            cx = cell_rect.x + sub_w * j + sub_w / 2
            cy = cell_rect.y + sub_h * i + sub_h / 2
            surf = t.font_note.render(str(n), True, t.NOTE_COLOR)
            surface.blit(surf, surf.get_rect(center=(int(cx), int(cy))))
