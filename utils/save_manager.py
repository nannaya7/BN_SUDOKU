"""SaveManager — JSON 기반 게임 저장/불러오기. 파일: sudoku_save.json"""
import json
import os
from typing import Any, Dict, Optional

SAVE_FILE = "sudoku_save.json"


class SaveManager:
    @staticmethod
    def save(data: Dict[str, Any]) -> bool:
        try:
            with open(SAVE_FILE, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False)
            return True
        except Exception:
            return False

    @staticmethod
    def load() -> Optional[Dict[str, Any]]:
        if not os.path.exists(SAVE_FILE):
            return None
        try:
            with open(SAVE_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return None

    @staticmethod
    def exists() -> bool:
        return os.path.exists(SAVE_FILE)

    @staticmethod
    def delete() -> None:
        try:
            os.remove(SAVE_FILE)
        except FileNotFoundError:
            pass
