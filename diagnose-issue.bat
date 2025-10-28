@echo off
title WrenAI Diagnostic Tool

echo ========================================
echo WrenAI Comprehensive Diagnostic Tool
echo ========================================
echo.

echo Running comprehensive diagnostics...
echo.

REM 1. Check if directories exist
echo 1. Directory Structure Check:
echo ----------------------------------------
if exist "%~dp0wren-ui" (
    echo ✅ wren-ui directory exists
    if exist "%~dp0wren-ui\package.json" (
        echo ✅ package.json found
    ) else (
        echo ❌ package.json missing
    )
    if exist "%~dp0wren-ui\node_modules" (
        echo ✅ node_modules exists
    ) else (
        echo ❌ node_modules missing - need to run npm install
    )
    if exist "%~dp0wren-ui\.next" (
        echo ✅ .next build directory exists
    ) else (
        echo ❌ .next missing - need to run npm run build
    )
) else (
    echo ❌ wren-ui directory not found
)

echo.

REM 2. Check processes
echo 2. Running Processes:
echo ----------------------------------------
echo Node.js processes:
tasklist /fi "imagename eq node.exe" 2>nul | findstr node.exe
if %ERRORLEVEL% NEQ 0 echo   No Node.js processes running

echo.
echo Python processes:
tasklist /fi "imagename eq python.exe" 2>nul | findstr python.exe
if %ERRORLEVEL% NEQ 0 echo   No Python processes running

echo.

REM 3. Check ports
echo 3. Port Usage:
echo ----------------------------------------
echo Checking port 3000 (UI):
netstat -an | findstr :3000
if %ERRORLEVEL% NEQ 0 echo   Port 3000 is free (UI not running)

echo.
echo Checking port 5555 (AI Service):
netstat -an | findstr :5555
if %ERRORLEVEL% NEQ 0 echo   Port 5555 is free (AI Service not running)

echo.

REM 4. Test actual connectivity
echo 4. Service Connectivity Tests:
echo ----------------------------------------

echo Testing localhost:3000...
curl -s --connect-timeout 5 http://localhost:3000 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ UI is responding on port 3000
) else (
    echo ❌ UI is not responding on port 3000
)

echo Testing localhost:5555...
curl -s --connect-timeout 5 http://localhost:5555/health >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ AI Service is responding on port 5555
) else (
    echo ❌ AI Service is not responding on port 5555
)

echo Testing localhost:8080...
curl -s --connect-timeout 5 http://localhost:8080/health >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ Local Wren Engine is responding on port 8080
) else (
    echo ❌ Local Wren Engine is not responding on port 8080
)

echo Testing localhost:8000...
curl -s --connect-timeout 5 http://localhost:8000/health >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ Local Ibis Server is responding on port 8000
) else (
    echo ❌ Local Ibis Server is not responding on port 8000
)

echo Testing localhost:6333...
curl -s --connect-timeout 5 http://localhost:6333/health >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ Qdrant is responding on port 6333
) else (
    echo ❌ Qdrant is not responding on port 6333
)

echo.

REM 5. Check configuration files
echo 5. Configuration Files:
echo ----------------------------------------
if exist "%USERPROFILE%\.wrenai\config.yaml" (
    echo ✅ Main config file exists
) else (
    echo ❌ Main config file missing
)

if exist "%USERPROFILE%\.wrenai\.env" (
    echo ✅ Environment file exists
    echo Checking for API key...
    findstr "GEMINI_API_KEY" "%USERPROFILE%\.wrenai\.env" >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo ✅ GEMINI_API_KEY found in .env
    ) else (
        echo ❌ GEMINI_API_KEY not found in .env
    )
) else (
    echo ❌ Environment file missing
)

echo.

REM 6. Recommendations
echo 6. Recommendations:
echo ----------------------------------------

REM Check what needs to be fixed
set NEEDS_UI_INSTALL=0
set NEEDS_UI_BUILD=0
set NEEDS_CONFIG=0

if not exist "%~dp0wren-ui\node_modules" set NEEDS_UI_INSTALL=1
if not exist "%~dp0wren-ui\.next" set NEEDS_UI_BUILD=1
if not exist "%USERPROFILE%\.wrenai\.env" set NEEDS_CONFIG=1

if %NEEDS_UI_INSTALL% EQU 1 (
    echo 🔧 Run: fix-ui.bat (to install UI dependencies)
)

if %NEEDS_UI_BUILD% EQU 1 (
    echo 🔧 Run: cd wren-ui && npm run build (to build the UI)
)

if %NEEDS_CONFIG% EQU 1 (
    echo 🔧 Run: setup-dockerfree.bat (to create configuration)
)

REM Check if no services are running
netstat -an | findstr ":3000\|:5555\|:8080\|:8000\|:6333" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 🔧 No services appear to be running. Try: start-all-dockerfree.bat
)

echo.
echo 7. Quick Fix Commands:
echo ----------------------------------------
echo To fix the most common issues:
echo.
echo   fix-ui.bat                    # Fix UI installation and build
echo   setup-dockerfree.bat          # Setup configuration
echo   start-all-dockerfree.bat      # Start all services
echo.
echo To start services individually:
echo   start-qdrant-simple.bat       # Start Qdrant
echo   start-local-engine.bat        # Start Wren Engine
echo   start-local-ibis.bat          # Start Ibis Server
echo   start-ai-service.bat          # Start AI Service
echo   start-ui.bat                  # Start UI
echo.

echo ========================================
echo Diagnostic Complete
echo ========================================
echo.

set /p CONTINUE="Would you like to run the UI fix script now? (y/n): "
if /i "%CONTINUE%"=="y" (
    echo.
    echo Running UI fix script...
    call "%~dp0fix-ui.bat"
) else (
    echo.
    echo Press any key to exit...
    pause >nul
)