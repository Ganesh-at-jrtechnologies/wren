@echo off
echo ========================================
echo Starting Wren UI
echo ========================================

REM Change to the UI directory
cd /d "%~dp0wren-ui"

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Node.js not found in PATH
    echo Please install Node.js from: https://nodejs.org/
    pause
    exit /b 1
)

REM Check if dependencies are installed
if not exist "node_modules" (
    echo Installing dependencies...
    npm install
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to install dependencies. Trying with yarn...
        where yarn >nul 2>nul
        if %ERRORLEVEL% EQU 0 (
            yarn install
        ) else (
            echo Both npm and yarn failed. Please check your Node.js installation.
            pause
            exit /b 1
        )
    )
)

REM Check if the app is built
if not exist ".next" (
    echo Building the application...
    npm run build
    if %ERRORLEVEL% NEQ 0 (
        echo Build failed. Please check for errors above.
        pause
        exit /b 1
    )
)

REM Set environment variables for the UI
set DB_TYPE=sqlite
set SQLITE_FILE=%USERPROFILE%\.wrenai\data\db.sqlite3
set WREN_AI_ENDPOINT=http://localhost:5555
set IBIS_SERVER_ENDPOINT=http://localhost:8000
set WREN_ENGINE_ENDPOINT=http://localhost:8080
set NEXT_PUBLIC_TELEMETRY_ENABLED=false
set TELEMETRY_ENABLED=false

REM Create data directory if it doesn't exist
if not exist "%USERPROFILE%\.wrenai\data" mkdir "%USERPROFILE%\.wrenai\data"

echo Starting UI on http://localhost:3000...
echo Press Ctrl+C to stop the UI

REM Start the UI
npm start