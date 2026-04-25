"""SudokuBoard — 9x9 그리드 관리 및 유효성 검증."""
from typing import List, Optional, Tuple


class SudokuBoard:
    SIZE = 9
    BOX = 3

    def __init__(self, puzzle: Optional[List[List[int]]] = None,
                 solution: Optional[List[List[int]]] = None):
        self.grid: List[List[int]] = (
            [row[:] for row in puzzle] if puzzle
            else [[0] * self.SIZE for _ in range(self.SIZE)]
        )
        self.original: List[List[bool]] = [
            [self.grid[r][c] != 0 for c in range(self.SIZE)]
            for r in range(self.SIZE)
        ]
        self.solution: Optional[List[List[int]]] = (
            [row[:] for row in solution] if solution else None
        )

    def get_cell(self, row: int, col: int) -> int:
        return self.grid[row][col]

    def set_cell(self, row: int, col: int, num: int) -> bool:
        if self.is_fixed(row, col):
            return False
        self.grid[row][col] = num
        return True

    def is_fixed(self, row: int, col: int) -> bool:
        return self.original[row][col]

    def is_valid_move(self, row: int, col: int, num: int) -> bool:
        """0-9 값을 해당 위치에 놓을 때 규칙 위반이 없는지 검사."""
        if num == 0:
            return True
        for i in range(self.SIZE):
            if i != col and self.grid[row][i] == num:
                return False
            if i != row and self.grid[i][col] == num:
                return False
        br, bc = (row // self.BOX) * self.BOX, (col // self.BOX) * self.BOX
        for r in range(br, br + self.BOX):
            for c in range(bc, bc + self.BOX):
                if (r, c) != (row, col) and self.grid[r][c] == num:
                    return False
        return True

    def is_complete(self) -> bool:
        if self.solution is not None:
            return self.grid == self.solution
        for r in range(self.SIZE):
            for c in range(self.SIZE):
                if self.grid[r][c] == 0:
                    return False
                if not self.is_valid_move(r, c, self.grid[r][c]):
                    return False
        return True

    def find_errors(self) -> List[Tuple[int, int]]:
        """정답(solution)과 다른 사용자 입력 셀들을 반환."""
        errors = []
        if self.solution is None:
            return errors
        for r in range(self.SIZE):
            for c in range(self.SIZE):
                v = self.grid[r][c]
                if v != 0 and not self.original[r][c] and v != self.solution[r][c]:
                    errors.append((r, c))
        return errors

    def copy(self) -> "SudokuBoard":
        b = SudokuBoard()
        b.grid = [row[:] for row in self.grid]
        b.original = [row[:] for row in self.original]
        b.solution = [row[:] for row in self.solution] if self.solution else None
        return b
