@echo off
echo ========================================
echo WrenAI Services Debug Tool
echo ========================================
echo.

echo Checking which ports are actually in use...
echo.

echo Port 3000 (UI):
netstat -an | findstr :3000
if %ERRORLEVEL% NEQ 0 echo   No service listening on port 3000

echo.
echo Port 5555 (AI Service):
netstat -an | findstr :5555
if %ERRORLEVEL% NEQ 0 echo   No service listening on port 5555

echo.
echo Port 8080 (Wren Engine):
netstat -an | findstr :8080
if %ERRORLEVEL% NEQ 0 echo   No service listening on port 8080

echo.
echo Port 8000 (Ibis Server):
netstat -an | findstr :8000
if %ERRORLEVEL% NEQ 0 echo   No service listening on port 8000

echo.
echo Port 6333 (Qdrant):
netstat -an | findstr :6333
if %ERRORLEVEL% NEQ 0 echo   No service listening on port 6333

echo.
echo ========================================
echo Process Check
echo ========================================
echo.

echo Python processes:
tasklist /fi "imagename eq python.exe" 2>nul | findstr python.exe
if %ERRORLEVEL% NEQ 0 echo   No Python processes running

echo.
echo Node.js processes:
tasklist /fi "imagename eq node.exe" 2>nul | findstr node.exe
if %ERRORLEVEL% NEQ 0 echo   No Node.js processes running

echo.
echo Qdrant processes:
tasklist /fi "imagename eq qdrant.exe" 2>nul | findstr qdrant.exe
if %ERRORLEVEL% NEQ 0 echo   No Qdrant processes running

echo.
echo ========================================
echo Service Health Checks
echo ========================================
echo.

echo Testing Qdrant (http://localhost:6333/health):
curl -s http://localhost:6333/health 2>nul
if %ERRORLEVEL% NEQ 0 echo   ❌ Qdrant not responding

echo.
echo Testing Local Wren Engine (http://localhost:8080/health):
curl -s http://localhost:8080/health 2>nul
if %ERRORLEVEL% NEQ 0 echo   ❌ Local Wren Engine not responding

echo.
echo Testing Local Ibis Server (http://localhost:8000/health):
curl -s http://localhost:8000/health 2>nul
if %ERRORLEVEL% NEQ 0 echo   ❌ Local Ibis Server not responding

echo.
echo Testing AI Service (http://localhost:5555/health):
curl -s http://localhost:5555/health 2>nul
if %ERRORLEVEL% NEQ 0 echo   ❌ AI Service not responding

echo.
echo Testing UI (http://localhost:3000):
curl -s http://localhost:3000 2>nul | findstr "html\|HTML" >nul
if %ERRORLEVEL% EQU 0 (
    echo   ✅ UI is responding with HTML content
) else (
    echo   ❌ UI not responding or not serving HTML
)

echo.
echo ========================================
echo Recommendations
echo ========================================
echo.

REM Check if UI directory exists and has the right files
if exist "%~dp0wren-ui\package.json" (
    echo ✅ UI directory and package.json found
) else (
    echo ❌ UI directory or package.json missing
)

if exist "%~dp0wren-ui\.next" (
    echo ✅ UI build directory (.next) exists
) else (
    echo ❌ UI not built - run 'npm run build' in wren-ui directory
)

if exist "%~dp0wren-ui\node_modules" (
    echo ✅ UI dependencies installed
) else (
    echo ❌ UI dependencies missing - run 'npm install' in wren-ui directory
)

echo.
echo Press any key to exit...
pause >nul