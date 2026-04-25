"""SudokuGenerator — 난이도별 퍼즐 생성 (유일해 보장)."""
import random
from typing import List, Tuple

from .sudoku_solver import SudokuSolver

Grid = List[List[int]]


class SudokuGenerator:
    DIFFICULTY_HOLES = {
        "easy": 35,
        "medium": 45,
        "hard": 55,
        "expert": 62,
    }

    @staticmethod
    def _empty_grid() -> Grid:
        return [[0] * 9 for _ in range(9)]

    @classmethod
    def _fill_full(cls, grid: Grid) -> bool:
        """백트래킹으로 완성된 보드 생성."""
        for r in range(9):
            for c in range(9):
                if grid[r][c] == 0:
                    nums = list(range(1, 10))
                    random.shuffle(nums)
                    for n in nums:
                        if SudokuSolver._can_place(grid, r, c, n):
                            grid[r][c] = n
                            if cls._fill_full(grid):
                                return True
                            grid[r][c] = 0
                    return False
        return True

    @classmethod
    def generate(cls, difficulty: str = "easy") -> Tuple[Grid, Grid]:
        """(puzzle, solution) 반환. puzzle은 0이 빈칸, solution은 완성된 보드."""
        solution = cls._empty_grid()
        cls._fill_full(solution)
        puzzle = [row[:] for row in solution]
        holes_target = cls.DIFFICULTY_HOLES.get(difficulty, 35)

        cells = [(r, c) for r in range(9) for c in range(9)]
        random.shuffle(cells)

        holes = 0
        for (r, c) in cells:
            if holes >= holes_target:
                break
            backup = puzzle[r][c]
            if backup == 0:
                continue
            puzzle[r][c] = 0
            if SudokuSolver.has_unique_solution(puzzle):
                holes += 1
            else:
                puzzle[r][c] = backup
        return puzzle, solution
