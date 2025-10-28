@echo off
REM Start Local Ibis Server (Docker-free replacement)
REM This replaces the Docker ibis-server with a Python service

title Local Ibis Server

echo ========================================
echo Starting Local Ibis Server
echo ========================================
echo Starting Ibis Server on http://localhost:8000...
echo Press Ctrl+C to stop the server
echo.

REM Set environment variables
set CONFIG_PATH=%USERPROFILE%\.wrenai\config.yaml
set PORT=8000
set HOST=0.0.0.0

REM Change to the local ibis server directory
cd /d "%~dp0local-ibis-server"

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

REM Start the local ibis server
echo Starting Local Ibis Server...
python app.py

pause