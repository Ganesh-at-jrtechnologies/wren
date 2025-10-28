@echo off
echo ========================================
echo Starting Qdrant Vector Database (Simple)
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
echo.

REM Create data directory if it doesn't exist
if not exist "%USERPROFILE%\.wrenai\qdrant_data" mkdir "%USERPROFILE%\.wrenai\qdrant_data"

REM Set environment variable for Qdrant data path
set QDRANT__STORAGE__STORAGE_PATH=%USERPROFILE%\.wrenai\qdrant_data
set QDRANT__SERVICE__HTTP_PORT=6333
set QDRANT__SERVICE__GRPC_PORT=6334

REM Start Qdrant with environment variables (works with Qdrant 1.15.5+)
echo Using data directory: %USERPROFILE%\.wrenai\qdrant_data
qdrant