@echo off
echo ============================================
echo  Sudoku .exe Build Script (PyInstaller)
echo ============================================
echo.

pyinstaller --version > nul 2>&1
if errorlevel 1 (
    echo [1/3] Installing PyInstaller...
    pip install pyinstaller
    if errorlevel 1 (
        echo [ERROR] PyInstaller install failed.
        pause
        exit /b 1
    )
) else (
    echo [1/3] PyInstaller found.
)

echo [2/3] Cleaning previous build...
if exist build rmdir /s /q build
if exist dist  rmdir /s /q dist
if exist Sudoku.spec del /q Sudoku.spec

echo [3/3] Building...
pyinstaller --onefile --windowed --name Sudoku main.py

if errorlevel 1 (
    echo.
    echo [ERROR] Build failed. Check the log above.
    pause
    exit /b 1
)

echo.
echo ============================================
echo  Done! Output: dist\Sudoku.exe
echo ============================================
explorer dist
pause
