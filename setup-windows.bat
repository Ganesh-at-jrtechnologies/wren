@echo off
title WrenAI Windows Setup

echo ========================================
echo WrenAI Windows Setup Script
echo ========================================
echo.
echo This script will help you set up WrenAI locally on Windows
echo with Gemini 2.5 Flash integration (no Docker required).
echo.

REM Check if running as administrator (optional but recommended)
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo NOTE: Not running as administrator. Some operations might require elevation.
    echo.
)

echo Step 1: Creating configuration directory...
if not exist "%USERPROFILE%\.wrenai" mkdir "%USERPROFILE%\.wrenai"
if not exist "%USERPROFILE%\.wrenai\data" mkdir "%USERPROFILE%\.wrenai\data"
if not exist "%USERPROFILE%\.wrenai\qdrant_data" mkdir "%USERPROFILE%\.wrenai\qdrant_data"
echo ✅ Configuration directory created at %USERPROFILE%\.wrenai

echo.
echo Step 2: Copying configuration files...
if exist "config.gemini.yaml" (
    copy "config.gemini.yaml" "%USERPROFILE%\.wrenai\config.yaml" >nul
    echo ✅ Gemini configuration copied
) else (
    echo ❌ config.gemini.yaml not found in current directory
    echo    Please ensure you're running this from the WrenAI root directory
    pause
    exit /b 1
)

if exist ".env.template" (
    if not exist "%USERPROFILE%\.wrenai\.env" (
        copy ".env.template" "%USERPROFILE%\.wrenai\.env" >nul
        echo ✅ Environment template copied
        echo ⚠️  IMPORTANT: Edit %USERPROFILE%\.wrenai\.env and add your GEMINI_API_KEY
    ) else (
        echo ℹ️  Environment file already exists, skipping...
    )
) else (
    echo ❌ .env.template not found
)

echo.
echo Step 3: Checking prerequisites...

REM Check Node.js
where node >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo ✅ Node.js found: %NODE_VERSION%
) else (
    echo ❌ Node.js not found
    echo    Download from: https://nodejs.org/
    set MISSING_DEPS=1
)

REM Check Python
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('python --version') do set PYTHON_VERSION=%%i
    echo ✅ Python found: %PYTHON_VERSION%
) else (
    echo ❌ Python not found
    echo    Download from: https://python.org/
    set MISSING_DEPS=1
)

REM Check Poetry
where poetry >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo ✅ Poetry found
) else (
    echo ⚠️  Poetry not found - will be installed automatically
)

REM Check Qdrant
where qdrant >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo ✅ Qdrant found
) else (
    echo ❌ Qdrant not found
    echo    Download from: https://github.com/qdrant/qdrant/releases
    echo    Or install via Rust: cargo install qdrant
    set MISSING_DEPS=1
)

if defined MISSING_DEPS (
    echo.
    echo ❌ Some prerequisites are missing. Please install them first.
    echo    See WINDOWS_SETUP_GUIDE.md for detailed instructions.
    pause
    exit /b 1
)

echo.
echo Step 4: Installing dependencies...

echo Installing Python dependencies...
cd wren-ai-service
where poetry >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Installing Poetry...
    pip install poetry
)
poetry install --no-dev
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to install Python dependencies
    pause
    exit /b 1
)
cd ..
echo ✅ Python dependencies installed

echo Installing Node.js dependencies...
cd wren-ui
npm install
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to install Node.js dependencies
    pause
    exit /b 1
)
echo ✅ Node.js dependencies installed

echo Building UI...
npm run build
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to build UI
    pause
    exit /b 1
)
cd ..
echo ✅ UI built successfully

echo.
echo ========================================
echo Setup Complete! 🎉
echo ========================================
echo.
echo Next steps:
echo 1. Edit %USERPROFILE%\.wrenai\.env and add your GEMINI_API_KEY
echo 2. Get your API key from: https://aistudio.google.com/
echo 3. Run start-all.bat to start WrenAI
echo.
echo Configuration files:
echo - Config: %USERPROFILE%\.wrenai\config.yaml
echo - Environment: %USERPROFILE%\.wrenai\.env
echo - Data: %USERPROFILE%\.wrenai\data\
echo.
echo For detailed instructions, see WINDOWS_SETUP_GUIDE.md
echo.

REM Ask if user wants to open the .env file for editing
set /p EDIT_ENV="Would you like to edit the .env file now? (y/n): "
if /i "%EDIT_ENV%"=="y" (
    if exist "%USERPROFILE%\.wrenai\.env" (
        notepad "%USERPROFILE%\.wrenai\.env"
    )
)

echo.
echo Setup complete! Press any key to exit...
pause >nul