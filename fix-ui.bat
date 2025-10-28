@echo off
echo ========================================
echo WrenAI UI Fix Script
echo ========================================
echo.

REM Change to UI directory
cd /d "%~dp0wren-ui"

REM Check if we're in the right directory
if not exist "package.json" (
    echo ❌ Error: package.json not found
    echo Make sure you're running this from the WrenAI root directory
    pause
    exit /b 1
)

echo ✅ Found package.json, proceeding with UI fixes...
echo.

echo Step 1: Cleaning previous installation...
if exist "node_modules" (
    echo Removing old node_modules...
    rmdir /s /q node_modules
)
if exist ".next" (
    echo Removing old build...
    rmdir /s /q .next
)
if exist "package-lock.json" (
    echo Removing package-lock.json...
    del package-lock.json
)

echo.
echo Step 2: Installing dependencies...
npm install --force
if %ERRORLEVEL% NEQ 0 (
    echo ❌ npm install failed, trying with different approach...
    npm cache clean --force
    npm install --legacy-peer-deps
    if %ERRORLEVEL% NEQ 0 (
        echo ❌ Both npm install attempts failed
        echo Try running: npm install --legacy-peer-deps --force
        pause
        exit /b 1
    )
)

echo.
echo Step 3: Fixing security vulnerabilities...
npm audit fix --force

echo.
echo Step 4: Building the application...
npm run build
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Build failed
    echo Check the error messages above
    pause
    exit /b 1
)

echo.
echo Step 5: Testing the UI startup...
echo Setting environment variables...
set TZ=UTC
set DB_TYPE=sqlite
set SQLITE_FILE=%USERPROFILE%\.wrenai\data\db.sqlite3
set WREN_AI_ENDPOINT=http://localhost:5555
set IBIS_SERVER_ENDPOINT=http://localhost:8000
set WREN_ENGINE_ENDPOINT=http://localhost:8080
set NEXT_PUBLIC_TELEMETRY_ENABLED=false
set TELEMETRY_ENABLED=false

REM Create data directory
if not exist "%USERPROFILE%\.wrenai\data" mkdir "%USERPROFILE%\.wrenai\data"

echo.
echo ✅ UI setup complete!
echo.
echo To start the UI manually:
echo 1. Open a new command prompt
echo 2. cd %~dp0wren-ui
echo 3. Run: npm start
echo.
echo Or use the startup script: start-ui.bat
echo.

set /p START_NOW="Would you like to start the UI now? (y/n): "
if /i "%START_NOW%"=="y" (
    echo Starting UI on http://localhost:3000...
    echo Press Ctrl+C to stop the UI
    npm start
) else (
    echo UI is ready to start. Use start-ui.bat or run 'npm start' in the wren-ui directory.
)

echo.
echo Press any key to exit...
pause >nul