"""Timer utility."""
import time


class Timer:
    def __init__(self):
        self._start: float = 0.0
        self._accum: float = 0.0
        self._running: bool = False

    def reset(self):
        self._start = 0.0
        self._accum = 0.0
        self._running = False

    def start(self):
        self._start = time.time()
        self._accum = 0.0
        self._running = True

    def pause(self):
        if self._running:
            self._accum += time.time() - self._start
            self._running = False

    def resume(self):
        if not self._running:
            self._start = time.time()
            self._running = True

    def get_elapsed(self) -> float:
        if self._running:
            return self._accum + (time.time() - self._start)
        return self._accum

    def format(self) -> str:
        sec = int(self.get_elapsed())
        return f"{sec // 60:02d}:{sec % 60:02d}"
