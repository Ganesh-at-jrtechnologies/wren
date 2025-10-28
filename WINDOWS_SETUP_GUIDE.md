# WrenAI Local Setup Guide for Windows (Without Docker)

This guide will help you set up WrenAI locally on Windows without using Docker, configured to use Google's Gemini 2.5 Flash model.

## Prerequisites

### 1. Install Required Software

#### Node.js (v18 or higher)
- Download from: https://nodejs.org/
- Choose the LTS version
- Verify installation: `node --version` and `npm --version`

#### Python 3.12
- Download from: https://www.python.org/downloads/
- **Important**: Make sure to check "Add Python to PATH" during installation
- Verify installation: `python --version`

#### Git
- Download from: https://git-scm.com/download/win
- Use default settings during installation

#### PostgreSQL (Optional - for production databases)
- Download from: https://www.postgresql.org/download/windows/
- Remember the password you set for the postgres user

### 2. Install Qdrant Vector Database

#### Option A: Using Pre-built Binary (Recommended)
1. Download Qdrant for Windows from: https://github.com/qdrant/qdrant/releases
2. Extract to a folder like `C:\qdrant`
3. Create a batch file `start-qdrant.bat`:
```batch
@echo off
cd /d C:\qdrant
qdrant.exe
```

#### Option B: Using Rust (if you have Rust installed)
```bash
cargo install qdrant
```

### 3. Get Your Gemini API Key
1. Go to https://aistudio.google.com/
2. Create a new API key
3. Save it securely - you'll need it later

## Setup Instructions

### Step 1: Clone and Prepare WrenAI

```bash
git clone https://github.com/Canner/WrenAI.git
cd WrenAI
```

### Step 2: Create Configuration Directory

```bash
# Create the .wrenai directory in your user home
mkdir %USERPROFILE%\.wrenai
mkdir %USERPROFILE%\.wrenai\data
```

### Step 3: Configure Gemini 2.5 Flash

1. Copy the Gemini configuration file:
```bash
copy config.gemini.yaml %USERPROFILE%\.wrenai\config.yaml
```

2. Create environment file `%USERPROFILE%\.wrenai\.env`:
```env
# Gemini API Configuration
GEMINI_API_KEY=your_gemini_api_key_here

# Service Configuration
WREN_ENGINE_ENDPOINT=http://localhost:8080
WREN_AI_ENDPOINT=http://localhost:5555
IBIS_SERVER_ENDPOINT=http://localhost:8000
QDRANT_HOST=localhost

# Database Configuration (SQLite for development)
DB_TYPE=sqlite
SQLITE_FILE=%USERPROFILE%\.wrenai\data\db.sqlite3

# Telemetry (optional)
TELEMETRY_ENABLED=false
POSTHOG_API_KEY=
POSTHOG_HOST=

# Development Settings
PYTHONUNBUFFERED=1
CONFIG_PATH=%USERPROFILE%\.wrenai\config.yaml
```

### Step 4: Set Up Wren AI Service (Python Backend)

```bash
cd wren-ai-service

# Install Poetry (Python package manager)
pip install poetry

# Install dependencies
poetry install

# Activate the virtual environment
poetry shell
```

### Step 5: Set Up Wren UI (Frontend)

Open a new command prompt:

```bash
cd WrenAI\wren-ui

# Install dependencies
npm install
# or if you prefer yarn:
yarn install

# Build the application
npm run build
# or with yarn:
yarn build
```

### Step 6: Create Startup Scripts

Create these batch files in the WrenAI root directory:

#### `start-qdrant.bat`
```batch
@echo off
echo Starting Qdrant Vector Database...
cd /d C:\qdrant
start "Qdrant" qdrant.exe
echo Qdrant started on http://localhost:6333
timeout /t 3
```

#### `start-ai-service.bat`
```batch
@echo off
echo Starting Wren AI Service...
cd /d "%~dp0wren-ai-service"
poetry run python -m src.main
```

#### `start-ui.bat`
```batch
@echo off
echo Starting Wren UI...
cd /d "%~dp0wren-ui"
set DB_TYPE=sqlite
set SQLITE_FILE=%USERPROFILE%\.wrenai\data\db.sqlite3
set WREN_AI_ENDPOINT=http://localhost:5555
set IBIS_SERVER_ENDPOINT=http://localhost:8000
set NEXT_PUBLIC_TELEMETRY_ENABLED=false
npm start
```

#### `start-all.bat` (Master startup script)
```batch
@echo off
echo ========================================
echo Starting WrenAI with Gemini 2.5 Flash
echo ========================================

echo.
echo 1. Starting Qdrant Vector Database...
call start-qdrant.bat

echo.
echo 2. Waiting for Qdrant to initialize...
timeout /t 10

echo.
echo 3. Starting AI Service...
start "Wren AI Service" cmd /k start-ai-service.bat

echo.
echo 4. Waiting for AI Service to initialize...
timeout /t 15

echo.
echo 5. Starting UI...
start "Wren UI" cmd /k start-ui.bat

echo.
echo ========================================
echo WrenAI is starting up!
echo ========================================
echo.
echo Services will be available at:
echo - UI: http://localhost:3000
echo - AI Service: http://localhost:5555
echo - Qdrant: http://localhost:6333
echo.
echo Wait a few minutes for all services to fully start.
echo Check the individual command windows for any errors.
echo.
pause
```

## Starting WrenAI

### Method 1: Using the Master Script
1. Double-click `start-all.bat`
2. Wait for all services to start (2-3 minutes)
3. Open http://localhost:3000 in your browser

### Method 2: Manual Startup (for debugging)
1. Start Qdrant: Run `start-qdrant.bat`
2. Start AI Service: Run `start-ai-service.bat`
3. Start UI: Run `start-ui.bat`
4. Open http://localhost:3000 in your browser

## Troubleshooting

### Common Issues

#### 1. Port Conflicts
If you get port conflicts, modify the ports in the batch files:
- Qdrant: Default 6333
- AI Service: Default 5555  
- UI: Default 3000

#### 2. Python/Poetry Issues
```bash
# If poetry is not found
pip install --user poetry
# Add %APPDATA%\Python\Scripts to your PATH

# If dependencies fail to install
poetry install --no-dev
```

#### 3. Node.js Issues
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
rmdir /s node_modules
npm install
```

#### 4. Gemini API Issues
- Verify your API key is correct
- Check if you have sufficient quota
- Ensure the API key has the necessary permissions

#### 5. Database Issues
The setup uses SQLite by default. The database file will be created automatically at `%USERPROFILE%\.wrenai\data\db.sqlite3`.

### Logs and Debugging

- AI Service logs: Check the command window running `start-ai-service.bat`
- UI logs: Check the command window running `start-ui.bat`
- Qdrant logs: Check the Qdrant command window

## Configuration Customization

### Changing Models
Edit `%USERPROFILE%\.wrenai\config.yaml` to use different Gemini models:
- `gemini/gemini-2.0-flash-exp` (Latest experimental)
- `gemini/gemini-1.5-pro`
- `gemini/gemini-1.5-flash`

### Adding Data Sources
Once WrenAI is running, you can connect to various databases through the UI:
- PostgreSQL
- MySQL
- BigQuery
- DuckDB
- And more...

## Performance Tips

1. **Use SSD**: Store the `.wrenai` directory on an SSD for better performance
2. **Memory**: Ensure you have at least 8GB RAM available
3. **Antivirus**: Add exclusions for the WrenAI directories to avoid scanning delays

## Security Notes

1. Keep your Gemini API key secure
2. Don't commit the `.env` file to version control
3. Use environment variables for production deployments
4. Consider using a reverse proxy for production use

## Next Steps

1. Connect your first data source
2. Create your first semantic model
3. Ask questions in natural language
4. Explore the GenBI features

For more information, visit the [WrenAI Documentation](https://docs.getwren.ai/).