"""SoundManager — 효과음 재생. 파일 없으면 pygame 비프음으로 대체."""
import math
import os
from typing import Dict, Optional

import pygame

_DIR   = os.path.join("assets", "sounds")
_FILES = {
    "input": "input.wav",
    "error": "error.wav",
    "clear": "clear.wav",
    "erase": "erase.wav",
    "hint":  "hint.wav",
}
_FREQS = {"input": 880,  "error": 220, "clear": 1047, "erase": 440, "hint": 660}
_DURS  = {"input": 80,   "error": 200, "clear": 500,  "erase": 80,  "hint": 150}


class SoundManager:
    def __init__(self):
        self._enabled = True
        self._sounds: Dict[str, Optional[pygame.mixer.Sound]] = {}
        try:
            if not pygame.mixer.get_init():
                pygame.mixer.pre_init(44100, -16, 1, 256)
                pygame.mixer.init()
        except Exception:
            self._enabled = False
            return

        for name in _FILES:
            path = os.path.join(_DIR, _FILES[name])
            if os.path.exists(path):
                try:
                    self._sounds[name] = pygame.mixer.Sound(path)
                    continue
                except Exception:
                    pass
            self._sounds[name] = self._make_beep(_FREQS[name], _DURS[name])

    @staticmethod
    def _make_beep(freq: int, ms: int) -> Optional[pygame.mixer.Sound]:
        try:
            rate  = 44100
            n     = int(rate * ms / 1000)
            fade  = min(200, n // 4)
            buf   = bytearray(n * 2)
            for i in range(n):
                v   = int(32767 * math.sin(2 * math.pi * freq * i / rate))
                env = min(1.0, min(i / max(fade, 1), (n - i) / max(fade, 1)))
                v   = int(v * env)
                buf[2 * i]     = v & 0xFF
                buf[2 * i + 1] = (v >> 8) & 0xFF
            return pygame.mixer.Sound(buffer=bytes(buf))
        except Exception:
            return None

    def play(self, name: str) -> None:
        if not self._enabled:
            return
        s = self._sounds.get(name)
        if s:
            s.play()

    def toggle(self) -> bool:
        self._enabled = not self._enabled
        return self._enabled

    @property
    def enabled(self) -> bool:
        return self._enabled
