@echo off
echo ========================================
echo Starting Wren AI Service
echo ========================================

REM Change to the AI service directory
cd /d "%~dp0wren-ai-service"

REM Check if Poetry is installed
where poetry >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Poetry not found in PATH
    echo Installing Poetry...
    pip install poetry
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to install Poetry. Please install manually.
        pause
        exit /b 1
    )
)

REM Check if virtual environment exists
if not exist ".venv" (
    echo Creating virtual environment and installing dependencies...
    poetry install
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to install dependencies. Check your Python installation.
        pause
        exit /b 1
    )
)

REM Set environment variables
set CONFIG_PATH=%USERPROFILE%\.wrenai\config.yaml
set PYTHONUNBUFFERED=1

REM Load environment variables from .env file if it exists
if exist "%USERPROFILE%\.wrenai\.env" (
    echo Loading environment variables from %USERPROFILE%\.wrenai\.env
    for /f "usebackq tokens=1,2 delims==" %%a in ("%USERPROFILE%\.wrenai\.env") do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" set %%a=%%b
    )
)

echo Starting AI Service on http://localhost:5555...
echo Press Ctrl+C to stop the service

REM Start the AI service
poetry run python -m src.main