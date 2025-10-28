# Windows Troubleshooting Guide for WrenAI

This guide addresses common Windows-specific issues when running WrenAI.

## 🚨 Common Issues and Solutions

### 1. Qdrant Error: `unexpected argument '--storage-path' found`

**Problem**: Qdrant 1.15.5+ changed command line arguments.

**Solution**:
```batch
# Use the fixed startup script
start-qdrant-simple.bat

# Or set environment variables manually:
set QDRANT__STORAGE__STORAGE_PATH=%USERPROFILE%\.wrenai\qdrant_data
qdrant
```

**Alternative**: Use environment variables instead of command line arguments:
- `QDRANT__STORAGE__STORAGE_PATH` - Sets storage path
- `QDRANT__SERVICE__HTTP_PORT` - Sets HTTP port (default 6333)
- `QDRANT__SERVICE__GRPC_PORT` - Sets gRPC port (default 6334)

### 2. UI Error: `'TZ' is not recognized as an internal or external command`

**Problem**: Unix-style environment variable syntax doesn't work on Windows.

**Solution**: The startup script now uses Windows format:
```batch
set TZ=UTC
npm start
```

**Fixed in**: `start-ui.bat` (updated version)

### 3. Poetry Error: `The syntax of the command is incorrect`

**Problem**: Poetry command syntax issues on Windows.

**Solution**: Use the updated AI service script:
```batch
poetry install --no-dev
```

**Fixed in**: `start-ai-service.bat` (updated version)

### 4. npm Security Vulnerabilities

**Problem**: npm audit shows high severity vulnerabilities.

**Solution**: Run the fix automatically:
```batch
npm audit fix --force
```

**Fixed in**: `start-ui.bat` now includes automatic security fixes.

## 🔧 Quick Fix Script

Run this script to fix all common issues:
```batch
fix-windows-issues.bat
```

This script will:
- Create proper Qdrant configuration
- Fix npm security issues
- Update Poetry dependencies
- Create Windows-compatible environment files

## 🛠️ Manual Fixes

### Fix Qdrant Manually

1. **Create data directory**:
   ```batch
   mkdir %USERPROFILE%\.wrenai\qdrant_data
   ```

2. **Use environment variables**:
   ```batch
   set QDRANT__STORAGE__STORAGE_PATH=%USERPROFILE%\.wrenai\qdrant_data
   qdrant
   ```

3. **Or use the simple startup script**:
   ```batch
   start-qdrant-simple.bat
   ```

### Fix UI Environment Variables

1. **Edit `start-ui.bat`** and ensure it has:
   ```batch
   set TZ=UTC
   set DB_TYPE=sqlite
   set SQLITE_FILE=%USERPROFILE%\.wrenai\data\db.sqlite3
   ```

2. **Or set manually before starting**:
   ```batch
   set TZ=UTC
   cd wren-ui
   npm start
   ```

### Fix Poetry Dependencies

1. **Clear Poetry cache**:
   ```batch
   cd wren-ai-service
   poetry cache clear --all pypi
   poetry install --no-dev
   ```

2. **If still failing, try**:
   ```batch
   poetry install --no-cache --no-dev
   ```

### Fix npm Security Issues

1. **Run audit fix**:
   ```batch
   cd wren-ui
   npm audit fix --force
   ```

2. **If issues persist**:
   ```batch
   npm install --force
   npm audit fix --force
   ```

## 🔍 Diagnostic Commands

Use these commands to diagnose issues:

### Check Tool Versions
```batch
qdrant --version
python --version
poetry --version
node --version
npm --version
```

### Test Individual Services
```batch
# Test Qdrant
curl http://localhost:6333/health

# Test Local Wren Engine
curl http://localhost:8080/health

# Test Local Ibis Server
curl http://localhost:8000/health
```

### Check Ports
```batch
# See what's using ports
netstat -an | findstr :6333
netstat -an | findstr :8080
netstat -an | findstr :8000
netstat -an | findstr :5555
netstat -an | findstr :3000
```

### Kill Processes
```batch
# Kill all Python processes
taskkill /f /im python.exe

# Kill all Node processes
taskkill /f /im node.exe

# Kill Qdrant
taskkill /f /im qdrant.exe
```

## 📋 Step-by-Step Recovery

If everything is broken, follow these steps:

### 1. Clean Start
```batch
# Kill all processes
taskkill /f /im python.exe
taskkill /f /im node.exe
taskkill /f /im qdrant.exe

# Clean directories
rmdir /s /q "%USERPROFILE%\.wrenai"
```

### 2. Run Fix Script
```batch
fix-windows-issues.bat
```

### 3. Configure API Key
```batch
# Copy template to actual env file
copy "%USERPROFILE%\.wrenai\.env.template" "%USERPROFILE%\.wrenai\.env"

# Edit and add your GEMINI_API_KEY
notepad "%USERPROFILE%\.wrenai\.env"
```

### 4. Test Individual Services

**Start Qdrant**:
```batch
start-qdrant-simple.bat
```

**Start Local Services**:
```batch
start-local-engine.bat
start-local-ibis.bat
```

**Start AI Service**:
```batch
start-ai-service.bat
```

**Start UI**:
```batch
start-ui.bat
```

### 5. Verify Everything Works
```batch
# Check all services
curl http://localhost:6333/health
curl http://localhost:8080/health
curl http://localhost:8000/health
curl http://localhost:5555/health
curl http://localhost:3000
```

## 🎯 Your Specific Issues

Based on your error messages:

### Issue 1: Qdrant `--storage-path` Error
**Fixed**: Use `start-qdrant-simple.bat` which uses environment variables instead.

### Issue 2: UI `TZ` Error
**Fixed**: Updated `start-ui.bat` to use Windows environment variable syntax.

### Issue 3: Poetry Syntax Error
**Fixed**: Updated `start-ai-service.bat` with proper Poetry commands.

### Issue 4: npm Audit Warnings
**Fixed**: Added automatic `npm audit fix` to startup scripts.

## 🚀 Recommended Startup Sequence

1. **Run the fix script first**:
   ```batch
   fix-windows-issues.bat
   ```

2. **Configure your API key**:
   ```batch
   copy "%USERPROFILE%\.wrenai\.env.template" "%USERPROFILE%\.wrenai\.env"
   notepad "%USERPROFILE%\.wrenai\.env"
   # Add: GEMINI_API_KEY=your_key_here
   ```

3. **Start services individually to test**:
   ```batch
   start-qdrant-simple.bat          # Terminal 1
   start-local-engine.bat           # Terminal 2  
   start-local-ibis.bat             # Terminal 3
   start-ai-service.bat             # Terminal 4
   start-ui.bat                     # Terminal 5
   ```

4. **Or use the all-in-one script**:
   ```batch
   start-all-dockerfree.bat
   ```

## 📞 Still Having Issues?

If you're still having problems:

1. **Check the error logs** in each command window
2. **Verify all prerequisites** are installed correctly
3. **Try the manual fixes** above
4. **Run services one by one** to isolate the problem
5. **Check Windows Defender/Antivirus** isn't blocking the services

The most common issue is the Qdrant command line change - use `start-qdrant-simple.bat` instead of the original script.