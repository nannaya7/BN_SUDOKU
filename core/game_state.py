"""GameState 및 GameSession."""
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import List, Optional, Set, Tuple

from .sudoku_board import SudokuBoard
from .sudoku_generator import SudokuGenerator
from .sudoku_solver import SudokuSolver
from utils.timer import Timer


class GameState(Enum):
    MENU = auto()
    DIFFICULTY = auto()
    PLAYING = auto()
    PAUSED = auto()
    WIN = auto()
    GAME_OVER = auto()


@dataclass
class GameSession:
    difficulty: str = "easy"
    board: Optional[SudokuBoard] = None
    timer: Timer = field(default_factory=Timer)
    mistakes: int = 0
    max_mistakes: int = 3
    hints_used: int = 0
    max_hints: int = 3
    selected: Optional[Tuple[int, int]] = None
    notes: List[List[Set[int]]] = field(default_factory=list)
    history: List[Tuple[List[List[int]], List[List[Set[int]]], int]] = field(default_factory=list)
    notes_mode: bool = False
    state: GameState = GameState.PLAYING

    def new_game(self, difficulty: str):
        self.difficulty = difficulty
        puzzle, solution = SudokuGenerator.generate(difficulty)
        self.board = SudokuBoard(puzzle, solution)
        self.mistakes = 0
        self.hints_used = 0
        self.selected = None
        self.notes = [[set() for _ in range(9)] for _ in range(9)]
        self.history = []
        self.notes_mode = False
        self.state = GameState.PLAYING
        self.timer.reset()
        self.timer.start()

    def _snapshot(self):
        if not self.board:
            return
        grid_copy = [row[:] for row in self.board.grid]
        notes_copy = [[set(s) for s in row] for row in self.notes]
        self.history.append((grid_copy, notes_copy, self.mistakes))
        if len(self.history) > 100:
            self.history.pop(0)

    def undo(self):
        if not self.board or not self.history:
            return
        grid, notes, mistakes = self.history.pop()
        self.board.grid = grid
        self.notes = notes
        self.mistakes = mistakes

    def input_number(self, num: int):
        if self.state != GameState.PLAYING or not self.board or not self.selected:
            return
        r, c = self.selected
        if self.board.is_fixed(r, c):
            return

        self._snapshot()

        if self.notes_mode:
            if self.board.grid[r][c] != 0:
                return
            if num in self.notes[r][c]:
                self.notes[r][c].remove(num)
            else:
                self.notes[r][c].add(num)
            return

        if self.board.grid[r][c] == num:
            self.board.grid[r][c] = 0
            return

        self.board.grid[r][c] = num
        self.notes[r][c].clear()
        # peer notes clear
        for i in range(9):
            self.notes[r][i].discard(num)
            self.notes[i][c].discard(num)
        br, bc = (r // 3) * 3, (c // 3) * 3
        for rr in range(br, br + 3):
            for cc in range(bc, bc + 3):
                self.notes[rr][cc].discard(num)

        # validate
        if self.board.solution and self.board.solution[r][c] != num:
            self.mistakes += 1
            if self.mistakes >= self.max_mistakes:
                self.state = GameState.GAME_OVER
                self.timer.pause()
                return

        if self.board.is_complete():
            self.state = GameState.WIN
            self.timer.pause()

    def erase(self):
        if self.state != GameState.PLAYING or not self.board or not self.selected:
            return
        r, c = self.selected
        if self.board.is_fixed(r, c):
            return
        self._snapshot()
        self.board.grid[r][c] = 0
        self.notes[r][c].clear()

    def hint(self):
        if self.state != GameState.PLAYING or not self.board:
            return
        if self.hints_used >= self.max_hints:
            return
        h = SudokuSolver.get_hint(self.board.grid)
        if h is None:
            return
        r, c, n = h
        if self.selected and self.board.grid[self.selected[0]][self.selected[1]] == 0 \
                and not self.board.is_fixed(*self.selected):
            r, c = self.selected
            n = self.board.solution[r][c] if self.board.solution else n
        self._snapshot()
        self.board.grid[r][c] = n
        self.board.original[r][c] = True
        self.notes[r][c].clear()
        self.selected = (r, c)
        self.hints_used += 1
        if self.board.is_complete():
            self.state = GameState.WIN
            self.timer.pause()

    def toggle_notes(self):
        self.notes_mode = not self.notes_mode

    def toggle_pause(self):
        if self.state == GameState.PLAYING:
            self.state = GameState.PAUSED
            self.timer.pause()
        elif self.state == GameState.PAUSED:
            self.state = GameState.PLAYING
            self.timer.resume()

    def move_selection(self, dr: int, dc: int):
        if self.state != GameState.PLAYING:
            return
        if self.selected is None:
            self.selected = (0, 0)
            return
        r, c = self.selected
        self.selected = ((r + dr) % 9, (c + dc) % 9)
