@echo off
echo ========================================
echo Starting Qdrant Vector Database
echo ========================================

REM Check if Qdrant is installed
where qdrant >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Qdrant not found in PATH
    echo Please install Qdrant from: https://github.com/qdrant/qdrant/releases
    echo Or install via Rust: cargo install qdrant
    pause
    exit /b 1
)

echo Starting Qdrant on http://localhost:6333...
echo Press Ctrl+C to stop Qdrant

REM Create data directory if it doesn't exist
if not exist "%USERPROFILE%\.wrenai\qdrant_data" mkdir "%USERPROFILE%\.wrenai\qdrant_data"

REM Start Qdrant with custom storage path
qdrant --storage-path "%USERPROFILE%\.wrenai\qdrant_data"