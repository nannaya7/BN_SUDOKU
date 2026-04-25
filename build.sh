#!/bin/bash
echo "============================================"
echo " Sudoku 앱 빌드 스크립트 (PyInstaller)"
echo "============================================"
echo

# PyInstaller 설치 확인
if ! python3 -m pyinstaller --version &>/dev/null; then
    echo "[1/3] PyInstaller 설치 중..."
    python3 -m pip install pyinstaller || { echo "[ERROR] 설치 실패"; exit 1; }
else
    echo "[1/3] PyInstaller 확인됨."
fi

# 이전 빌드 정리
echo "[2/3] 이전 빌드 정리 중..."
rm -rf build dist Sudoku.spec

# PyInstaller 빌드
echo "[3/3] 빌드 시작..."
python3 -m pyinstaller \
    --onefile \
    --windowed \
    --name Sudoku \
    main.py

if [ $? -ne 0 ]; then
    echo
    echo "[ERROR] 빌드 실패. 위 오류 메시지를 확인하세요."
    exit 1
fi

echo
echo "============================================"
echo " 완료! 실행 파일 위치: dist/Sudoku"
echo "============================================"
open dist 2>/dev/null || xdg-open dist 2>/dev/null || true
