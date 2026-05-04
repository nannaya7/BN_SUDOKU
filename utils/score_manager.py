"""ScoreManager — 난이도별 최고기록 저장. 파일: sudoku_scores.json"""
import json
import os
from typing import Dict, Optional

SCORES_FILE = "sudoku_scores.json"


class ScoreManager:
    @staticmethod
    def _load() -> Dict[str, int]:
        if not os.path.exists(SCORES_FILE):
            return {}
        try:
            with open(SCORES_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {}

    @staticmethod
    def _save(data: Dict[str, int]) -> None:
        try:
            with open(SCORES_FILE, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False)
        except Exception:
            pass

    @staticmethod
    def get_best(difficulty: str) -> Optional[int]:
        return ScoreManager._load().get(difficulty)

    @staticmethod
    def update(difficulty: str, seconds: int) -> bool:
        """기록 갱신 시 True 반환."""
        data = ScoreManager._load()
        current = data.get(difficulty)
        if current is None or seconds < current:
            data[difficulty] = seconds
            ScoreManager._save(data)
            return True
        return False

    @staticmethod
    def format_time(seconds: int) -> str:
        return f"{seconds // 60:02d}:{seconds % 60:02d}"

    @staticmethod
    def all_bests() -> Dict[str, int]:
        return ScoreManager._load()
