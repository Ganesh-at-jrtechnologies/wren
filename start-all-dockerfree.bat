@echo off
REM WrenAI Complete Startup Script for Windows (Docker-free)
REM This script starts all WrenAI services locally without Docker

title WrenAI Local Setup with Gemini 2.5 Flash (Docker-free)

echo ========================================
echo WrenAI Local Setup with Gemini 2.5 Flash
echo Docker-free Version with Local Services
echo ========================================
echo.

REM Check prerequisites
echo Checking prerequisites...

REM Check Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js not found. Please install Node.js 18+ from https://nodejs.org/
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('node --version') do echo ✅ Node.js found: %%i
)

REM Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python not found. Please install Python 3.12+ from https://python.org/
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('python --version') do echo ✅ Python found: %%i
)

REM Check Poetry
poetry --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Poetry not found. Please install Poetry from https://python-poetry.org/
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('poetry --version') do echo ✅ Poetry found: %%i
)

REM Check Qdrant
qdrant --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Qdrant not found. Please install Qdrant from https://qdrant.tech/
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('qdrant --version') do echo ✅ Qdrant found: %%i
)

echo.
echo All prerequisites found!
echo.

echo ========================================
echo Starting Services (Docker-free)
echo ========================================
echo.

REM Start Qdrant Vector Database
echo 1. Starting Qdrant Vector Database...
start "Qdrant Vector DB" cmd /c "%~dp0start-qdrant.bat"
timeout /t 8 /nobreak >nul
echo    Waiting for Qdrant to initialize...

REM Start Local Wren Engine (replaces Docker container)
echo 2. Starting Local Wren Engine...
start "Local Wren Engine" cmd /c "%~dp0start-local-engine.bat"
timeout /t 5 /nobreak >nul
echo    Waiting for Wren Engine to initialize...

REM Start Local Ibis Server (replaces Docker container)
echo 3. Starting Local Ibis Server...
start "Local Ibis Server" cmd /c "%~dp0start-local-ibis.bat"
timeout /t 5 /nobreak >nul
echo    Waiting for Ibis Server to initialize...

REM Start Wren AI Service
echo 4. Starting Wren AI Service...
start "Wren AI Service" cmd /c "%~dp0start-ai-service.bat"
timeout /t 10 /nobreak >nul
echo    Waiting for AI Service to initialize...

REM Start Wren UI
echo 5. Starting Wren UI...
start "Wren UI" cmd /c "%~dp0start-ui.bat"

echo.
echo ========================================
echo WrenAI is Starting Up! (Docker-free)
echo ========================================
echo.
echo Services are starting in separate windows:
echo.
echo   🔹 Qdrant Vector DB:  http://localhost:6333
echo   🔹 Local Wren Engine: http://localhost:8080
echo   🔹 Local Ibis Server: http://localhost:8000
echo   🔹 AI Service:        http://localhost:5555  
echo   🔹 Web UI:            http://localhost:3000
echo.
echo ⏳ Please wait 3-4 minutes for all services to fully start
echo.
echo 🌐 Once ready, open: http://localhost:3000
echo.
echo ❗ Keep all command windows open while using WrenAI
echo ❗ Close this window or press Ctrl+C to stop monitoring
echo.

:monitor
echo Monitoring services...
echo.

REM Check if services are running
timeout /t 30 /nobreak >nul

echo Checking service status...

REM Check Qdrant
curl -s http://localhost:6333/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Qdrant is running
) else (
    echo ⚠️  Qdrant may still be starting...
)

REM Check Local Wren Engine
curl -s http://localhost:8080/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Local Wren Engine is running
) else (
    echo ⚠️  Local Wren Engine may still be starting...
)

REM Check Local Ibis Server
curl -s http://localhost:8000/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Local Ibis Server is running
) else (
    echo ⚠️  Local Ibis Server may still be starting...
)

REM Check AI Service
curl -s http://localhost:5555/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ AI Service is running
) else (
    echo ⚠️  AI Service may still be starting...
)

REM Check UI
curl -s http://localhost:3000 >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ UI is running
) else (
    echo ⚠️  UI may still be starting...
)

echo.
echo 🎉 All services are ready!
echo 🌐 Open http://localhost:3000 in your browser
echo.
echo Press any key to check again, or Ctrl+C to exit...
pause >nul

goto monitor