@echo off
REM Start Local Wren Engine (Docker-free replacement)
REM This replaces the Java Docker container with a Python service

title Local Wren Engine

echo ========================================
echo Starting Local Wren Engine
echo ========================================
echo Starting Wren Engine on http://localhost:8080...
echo Press Ctrl+C to stop the engine
echo.

REM Set environment variables
set CONFIG_PATH=%USERPROFILE%\.wrenai\config.yaml
set PORT=8080
set HOST=0.0.0.0

REM Change to the local engine directory
cd /d "%~dp0local-wren-engine"

REM Check if virtual environment exists
if not exist "venv" (
    echo Creating Python virtual environment...
    python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Install dependencies if needed
if not exist "venv\Lib\site-packages\fastapi" (
    echo Installing dependencies...
    pip install -r requirements.txt
)

REM Start the local wren engine
echo Starting Local Wren Engine...
python app.py

pause