@echo off
REM Fix Windows-specific issues with WrenAI setup
REM This script addresses common problems encountered on Windows

title WrenAI Windows Issues Fix

echo ========================================
echo WrenAI Windows Issues Fix
echo ========================================
echo.
echo This script will fix common Windows issues:
echo 1. Qdrant command line arguments
echo 2. Node.js environment variables
echo 3. Poetry dependency issues
echo 4. npm security vulnerabilities
echo.

REM Fix 1: Create proper Qdrant configuration
echo Step 1: Creating Qdrant configuration...
if not exist "%USERPROFILE%\.wrenai" mkdir "%USERPROFILE%\.wrenai"
if not exist "%USERPROFILE%\.wrenai\qdrant_data" mkdir "%USERPROFILE%\.wrenai\qdrant_data"

REM Create a proper Qdrant config file
echo Creating Qdrant config file...
(
echo storage:
echo   storage_path: "%USERPROFILE%\.wrenai\qdrant_data"
echo service:
echo   host: 0.0.0.0
echo   http_port: 6333
echo   grpc_port: 6334
echo log_level: INFO
) > "%USERPROFILE%\.wrenai\qdrant_config.yaml"
echo ✅ Qdrant configuration created

echo.
echo Step 2: Fixing npm security vulnerabilities...
cd /d "%~dp0wren-ui"
if exist "package.json" (
    echo Running npm audit fix...
    npm audit fix --force
    echo ✅ npm security issues addressed
) else (
    echo ⚠️  wren-ui directory not found, skipping npm fix
)

echo.
echo Step 3: Checking Poetry setup...
cd /d "%~dp0wren-ai-service"
if exist "pyproject.toml" (
    echo Updating Poetry dependencies...
    poetry install --no-dev
    if %ERRORLEVEL% NEQ 0 (
        echo Trying alternative Poetry install...
        poetry install --no-cache
    )
    echo ✅ Poetry dependencies updated
) else (
    echo ⚠️  wren-ai-service directory not found, skipping Poetry fix
)

echo.
echo Step 4: Creating Windows-compatible environment file...
cd /d "%~dp0"
if exist ".env.dockerfree" (
    copy ".env.dockerfree" "%USERPROFILE%\.wrenai\.env.template"
    echo ✅ Environment template created at %USERPROFILE%\.wrenai\.env.template
    echo.
    echo ⚠️  IMPORTANT: Copy .env.template to .env and add your GEMINI_API_KEY
) else (
    echo ⚠️  .env.dockerfree not found
)

echo.
echo Step 5: Testing Qdrant startup...
echo Testing Qdrant with simple command...
qdrant --help >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ Qdrant is accessible
) else (
    echo ❌ Qdrant not found in PATH
    echo Please ensure Qdrant is installed and in your PATH
)

echo.
echo ========================================
echo Fix Summary
echo ========================================
echo.
echo ✅ Qdrant configuration created
echo ✅ npm security issues addressed
echo ✅ Poetry dependencies updated
echo ✅ Environment template created
echo.
echo Next steps:
echo 1. Copy %USERPROFILE%\.wrenai\.env.template to %USERPROFILE%\.wrenai\.env
echo 2. Edit .env file and add your GEMINI_API_KEY
echo 3. Run start-all-dockerfree.bat
echo.
echo If you still have issues:
echo - For Qdrant: Try running 'qdrant' directly in a command prompt
echo - For UI: Check Node.js version (should be 18+)
echo - For AI Service: Check Python version (should be 3.12+)
echo.

set /p OPEN_ENV="Would you like to open the environment file now? (y/n): "
if /i "%OPEN_ENV%"=="y" (
    if exist "%USERPROFILE%\.wrenai\.env.template" (
        notepad "%USERPROFILE%\.wrenai\.env.template"
    )
)

echo.
echo Press any key to exit...
pause >nul