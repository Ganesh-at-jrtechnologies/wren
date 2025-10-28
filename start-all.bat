@echo off
title WrenAI Startup Manager

echo ========================================
echo WrenAI Local Setup with Gemini 2.5 Flash
echo ========================================
echo.

REM Check if configuration exists
if not exist "%USERPROFILE%\.wrenai\config.yaml" (
    echo ERROR: Configuration not found!
    echo Please copy config.gemini.yaml to %USERPROFILE%\.wrenai\config.yaml
    echo and create %USERPROFILE%\.wrenai\.env with your GEMINI_API_KEY
    echo.
    echo See WINDOWS_SETUP_GUIDE.md for detailed instructions.
    pause
    exit /b 1
)

if not exist "%USERPROFILE%\.wrenai\.env" (
    echo WARNING: Environment file not found at %USERPROFILE%\.wrenai\.env
    echo Creating a template .env file...
    
    echo # Gemini API Configuration > "%USERPROFILE%\.wrenai\.env"
    echo GEMINI_API_KEY=your_gemini_api_key_here >> "%USERPROFILE%\.wrenai\.env"
    echo. >> "%USERPROFILE%\.wrenai\.env"
    echo # Service Configuration >> "%USERPROFILE%\.wrenai\.env"
    echo WREN_ENGINE_ENDPOINT=http://localhost:8080 >> "%USERPROFILE%\.wrenai\.env"
    echo WREN_AI_ENDPOINT=http://localhost:5555 >> "%USERPROFILE%\.wrenai\.env"
    echo IBIS_SERVER_ENDPOINT=http://localhost:8000 >> "%USERPROFILE%\.wrenai\.env"
    echo QDRANT_HOST=localhost >> "%USERPROFILE%\.wrenai\.env"
    echo. >> "%USERPROFILE%\.wrenai\.env"
    echo # Database Configuration >> "%USERPROFILE%\.wrenai\.env"
    echo DB_TYPE=sqlite >> "%USERPROFILE%\.wrenai\.env"
    echo SQLITE_FILE=%USERPROFILE%\.wrenai\data\db.sqlite3 >> "%USERPROFILE%\.wrenai\.env"
    echo. >> "%USERPROFILE%\.wrenai\.env"
    echo # Telemetry >> "%USERPROFILE%\.wrenai\.env"
    echo TELEMETRY_ENABLED=false >> "%USERPROFILE%\.wrenai\.env"
    echo. >> "%USERPROFILE%\.wrenai\.env"
    echo # Development Settings >> "%USERPROFILE%\.wrenai\.env"
    echo PYTHONUNBUFFERED=1 >> "%USERPROFILE%\.wrenai\.env"
    echo CONFIG_PATH=%USERPROFILE%\.wrenai\config.yaml >> "%USERPROFILE%\.wrenai\.env"
    
    echo.
    echo Template .env file created. Please edit it and add your GEMINI_API_KEY
    echo File location: %USERPROFILE%\.wrenai\.env
    echo.
    pause
    exit /b 1
)

echo Checking prerequisites...

REM Check for required tools
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Node.js not found. Please install from https://nodejs.org/
    pause
    exit /b 1
)

where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python not found. Please install Python 3.12 from https://python.org/
    pause
    exit /b 1
)

where qdrant >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Qdrant not found. Please install from https://github.com/qdrant/qdrant/releases
    pause
    exit /b 1
)

echo All prerequisites found!
echo.

echo ========================================
echo Starting Services
echo ========================================

echo 1. Starting Qdrant Vector Database...
start "Qdrant Vector DB" cmd /k "%~dp0start-qdrant.bat"

echo    Waiting for Qdrant to initialize...
timeout /t 10 /nobreak >nul

echo.
echo 2. Starting Wren AI Service...
start "Wren AI Service" cmd /k "%~dp0start-ai-service.bat"

echo    Waiting for AI Service to initialize...
timeout /t 20 /nobreak >nul

echo.
echo 3. Starting Wren UI...
start "Wren UI" cmd /k "%~dp0start-ui.bat"

echo.
echo ========================================
echo WrenAI is Starting Up!
echo ========================================
echo.
echo Services are starting in separate windows:
echo.
echo  🔹 Qdrant Vector DB: http://localhost:6333
echo  🔹 AI Service:       http://localhost:5555  
echo  🔹 Web UI:           http://localhost:3000
echo.
echo ⏳ Please wait 2-3 minutes for all services to fully start
echo.
echo 🌐 Once ready, open: http://localhost:3000
echo.
echo ❗ Keep all command windows open while using WrenAI
echo ❗ Close this window or press Ctrl+C to stop monitoring
echo.

REM Wait and check if services are responding
echo Monitoring services...
timeout /t 30 /nobreak >nul

:check_loop
echo Checking service status...

REM Simple check if ports are listening (requires netstat)
netstat -an | find "LISTENING" | find ":6333" >nul
if %ERRORLEVEL% EQU 0 (
    echo ✅ Qdrant is running
) else (
    echo ⏳ Qdrant starting...
)

netstat -an | find "LISTENING" | find ":5555" >nul
if %ERRORLEVEL% EQU 0 (
    echo ✅ AI Service is running
) else (
    echo ⏳ AI Service starting...
)

netstat -an | find "LISTENING" | find ":3000" >nul
if %ERRORLEVEL% EQU 0 (
    echo ✅ UI is running
    echo.
    echo 🎉 All services are ready!
    echo 🌐 Open http://localhost:3000 in your browser
    echo.
) else (
    echo ⏳ UI starting...
)

echo.
echo Press any key to check again, or Ctrl+C to exit...
pause >nul
goto check_loop