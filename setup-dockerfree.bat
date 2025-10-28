@echo off
REM WrenAI Windows Setup Script (Docker-free Version)
REM This script sets up WrenAI to run locally on Windows without Docker

title WrenAI Windows Setup (Docker-free)

echo ========================================
echo WrenAI Windows Setup Script (Docker-free)
echo ========================================
echo.
echo This script will help you set up WrenAI locally on Windows
echo with Gemini 2.5 Flash integration (no Docker required).
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo NOTE: Not running as administrator. Some operations might require elevation.
) else (
    echo Running as administrator.
)
echo.

echo Step 1: Creating configuration directory...
if not exist "%USERPROFILE%\.wrenai" mkdir "%USERPROFILE%\.wrenai"
if not exist "%USERPROFILE%\.wrenai\data" mkdir "%USERPROFILE%\.wrenai\data"
if not exist "%USERPROFILE%\.wrenai\qdrant_data" mkdir "%USERPROFILE%\.wrenai\qdrant_data"
echo ✅ Configuration directory created at %USERPROFILE%\.wrenai

echo.
echo Step 2: Copying configuration files...
copy /Y "config.dockerfree.yaml" "%USERPROFILE%\.wrenai\config.yaml" >nul
copy /Y ".env.dockerfree" "%USERPROFILE%\.wrenai\.env" >nul
echo ✅ Docker-free configuration copied
echo ✅ Environment template copied
echo ⚠️  IMPORTANT: Edit %USERPROFILE%\.wrenai\.env and add your GEMINI_API_KEY

echo.
echo Step 3: Checking prerequisites...

REM Check Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js not found - please install Node.js 18+ from https://nodejs.org/
    set MISSING_DEPS=1
) else (
    for /f "tokens=*" %%i in ('node --version') do echo ✅ Node.js found: %%i
)

REM Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python not found - please install Python 3.12+ from https://python.org/
    set MISSING_DEPS=1
) else (
    for /f "tokens=*" %%i in ('python --version') do echo ✅ Python found: %%i
)

REM Check Poetry
poetry --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Poetry not found - will be installed automatically
    echo Installing Poetry...
    curl -sSL https://install.python-poetry.org | python -
    if %errorlevel% neq 0 (
        echo ❌ Failed to install Poetry automatically
        echo Please install Poetry manually from https://python-poetry.org/
        set MISSING_DEPS=1
    ) else (
        echo ✅ Poetry installed successfully
    )
) else (
    for /f "tokens=*" %%i in ('poetry --version') do echo ✅ Poetry found: %%i
)

REM Check Qdrant
qdrant --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Qdrant not found - please install Qdrant from https://qdrant.tech/
    set MISSING_DEPS=1
) else (
    for /f "tokens=*" %%i in ('qdrant --version') do echo ✅ Qdrant found: %%i
)

if defined MISSING_DEPS (
    echo.
    echo ❌ Some prerequisites are missing. Please install them and run this script again.
    pause
    exit /b 1
)

echo.
echo Step 4: Installing dependencies...

echo Installing Python dependencies...
cd wren-ai-service
call poetry install
if %errorlevel% neq 0 (
    echo ❌ Failed to install Python dependencies
    pause
    exit /b 1
)
echo ✅ Python dependencies installed

echo.
echo Installing Node.js dependencies...
cd ..\wren-ui
call npm install
if %errorlevel% neq 0 (
    echo ❌ Failed to install Node.js dependencies
    pause
    exit /b 1
)
echo ✅ Node.js dependencies installed

echo.
echo Setting up local services...

echo Setting up Local Wren Engine...
cd ..\local-wren-engine
python -m venv venv
call venv\Scripts\activate.bat
pip install -r requirements.txt
call venv\Scripts\deactivate.bat
echo ✅ Local Wren Engine setup complete

echo Setting up Local Ibis Server...
cd ..\local-ibis-server
python -m venv venv
call venv\Scripts\activate.bat
pip install -r requirements.txt
call venv\Scripts\deactivate.bat
echo ✅ Local Ibis Server setup complete

echo.
echo Building UI...
cd ..\wren-ui
call npm run build
if %errorlevel% neq 0 (
    echo ❌ Failed to build UI
    pause
    exit /b 1
)
echo ✅ UI built successfully

cd ..

echo.
echo ========================================
echo Setup Complete! 🎉
echo ========================================
echo.
echo Next steps:
echo 1. Edit %USERPROFILE%\.wrenai\.env and add your GEMINI_API_KEY
echo 2. Get your API key from: https://aistudio.google.com/
echo 3. Run start-all-dockerfree.bat to start WrenAI
echo.
echo Configuration files:
echo - Config: %USERPROFILE%\.wrenai\config.yaml
echo - Environment: %USERPROFILE%\.wrenai\.env
echo - Data: %USERPROFILE%\.wrenai\data\
echo.
echo Local Services (Docker-free):
echo - Local Wren Engine: http://localhost:8080
echo - Local Ibis Server: http://localhost:8000
echo - Qdrant Vector DB: http://localhost:6333
echo - AI Service: http://localhost:5555
echo - Web UI: http://localhost:3000
echo.
echo For detailed instructions, see WINDOWS_SETUP_GUIDE.md
echo.

set /p EDIT_ENV="Would you like to edit the .env file now? (y/n): "
if /i "%EDIT_ENV%"=="y" (
    notepad "%USERPROFILE%\.wrenai\.env"
)

echo.
echo Setup complete! Press any key to exit...
pause >nul