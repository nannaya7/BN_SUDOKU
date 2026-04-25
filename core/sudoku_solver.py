"""SudokuSolver — 백트래킹 솔버 및 유일해 검증."""
from typing import List, Optional, Tuple

Grid = List[List[int]]


class SudokuSolver:
    SIZE = 9
    BOX = 3

    @staticmethod
    def _find_empty(grid: Grid) -> Optional[Tuple[int, int]]:
        for r in range(9):
            for c in range(9):
                if grid[r][c] == 0:
                    return (r, c)
        return None

    @staticmethod
    def _can_place(grid: Grid, row: int, col: int, num: int) -> bool:
        for i in range(9):
            if grid[row][i] == num or grid[i][col] == num:
                return False
        br, bc = (row // 3) * 3, (col // 3) * 3
        for r in range(br, br + 3):
            for c in range(bc, bc + 3):
                if grid[r][c] == num:
                    return False
        return True

    @classmethod
    def solve(cls, grid: Grid) -> bool:
        """grid를 in-place로 해결. 가능하면 True."""
        empty = cls._find_empty(grid)
        if not empty:
            return True
        r, c = empty
        for n in range(1, 10):
            if cls._can_place(grid, r, c, n):
                grid[r][c] = n
                if cls.solve(grid):
                    return True
                grid[r][c] = 0
        return False

    @classmethod
    def count_solutions(cls, grid: Grid, cap: int = 2) -> int:
        """해의 개수를 최대 cap개까지 셈."""
        count = [0]

        def rec():
            if count[0] >= cap:
                return
            empty = cls._find_empty(grid)
            if not empty:
                count[0] += 1
                return
            r, c = empty
            for n in range(1, 10):
                if count[0] >= cap:
                    return
                if cls._can_place(grid, r, c, n):
                    grid[r][c] = n
                    rec()
                    grid[r][c] = 0

        rec()
        return count[0]

    @classmethod
    def has_unique_solution(cls, grid: Grid) -> bool:
        return cls.count_solutions([row[:] for row in grid], cap=2) == 1

    @classmethod
    def get_hint(cls, grid: Grid) -> Optional[Tuple[int, int, int]]:
        """비어있는 한 셀의 정답을 반환 (row, col, num). 없으면 None."""
        solved = [row[:] for row in grid]
        if not cls.solve(solved):
            return None
        for r in range(9):
            for c in range(9):
                if grid[r][c] == 0:
                    return (r, c, solved[r][c])
        return None
