"""Main entry point for the warm 3D Sudoku game."""
import os
os.environ["PYGAME_HIDE_SUPPORT_PROMPT"] = "1"

from ui.game_window import GameWindow


def main():
    GameWindow().run()


if __name__ == "__main__":
    main()
