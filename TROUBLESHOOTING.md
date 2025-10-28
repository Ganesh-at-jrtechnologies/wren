# WrenAI Windows Troubleshooting Guide

This guide covers common issues you might encounter when running WrenAI locally on Windows without Docker.

## Quick Diagnostics

### Check Service Status
```batch
# Check if services are running on their ports
netstat -an | findstr "LISTENING" | findstr ":3000 :5555 :6333"
```

### Check Logs
- **AI Service**: Check the command window running `start-ai-service.bat`
- **UI**: Check the command window running `start-ui.bat`  
- **Qdrant**: Check the command window running `start-qdrant.bat`

## Common Issues and Solutions

### 1. "GEMINI_API_KEY not found" or API Authentication Errors

**Symptoms:**
- AI Service fails to start
- Error messages about missing or invalid API key
- 401 Unauthorized errors

**Solutions:**
1. **Check your API key:**
   ```batch
   # Open your environment file
   notepad %USERPROFILE%\.wrenai\.env
   ```
   - Ensure `GEMINI_API_KEY=your_actual_api_key` (no quotes)
   - Get a new key from https://aistudio.google.com/

2. **Verify API key permissions:**
   - Ensure the API key has access to Gemini models
   - Check your Google AI Studio quota

3. **Test the API key:**
   ```python
   # Test script - save as test_gemini.py
   import os
   from litellm import completion
   
   os.environ["GEMINI_API_KEY"] = "your_api_key_here"
   
   response = completion(
       model="gemini/gemini-2.0-flash-exp",
       messages=[{"role": "user", "content": "Hello!"}]
   )
   print(response.choices[0].message.content)
   ```

### 2. Port Conflicts

**Symptoms:**
- "Port already in use" errors
- Services fail to start
- Connection refused errors

**Solutions:**
1. **Find what's using the ports:**
   ```batch
   netstat -ano | findstr ":3000"
   netstat -ano | findstr ":5555"
   netstat -ano | findstr ":6333"
   ```

2. **Kill conflicting processes:**
   ```batch
   # Replace PID with the actual process ID
   taskkill /PID 1234 /F
   ```

3. **Use different ports:**
   Edit the batch files to use different ports:
   ```batch
   # In start-ui.bat, change:
   set PORT=3001
   
   # In start-ai-service.bat, add:
   set WREN_AI_SERVICE_PORT=5556
   
   # Update config.yaml endpoints accordingly
   ```

### 3. Python/Poetry Issues

**Symptoms:**
- "Poetry not found"
- "Python not found"
- Dependency installation failures

**Solutions:**
1. **Install/Reinstall Poetry:**
   ```batch
   pip install --user poetry
   # Add %APPDATA%\Python\Scripts to PATH
   ```

2. **Clear Poetry cache:**
   ```batch
   poetry cache clear --all pypi
   poetry install --no-cache
   ```

3. **Use pip directly (fallback):**
   ```batch
   cd wren-ai-service
   pip install -r requirements.txt  # if available
   # Or install key packages manually:
   pip install fastapi uvicorn litellm qdrant-client
   ```

4. **Python version issues:**
   - Ensure Python 3.12 is installed
   - Check: `python --version`
   - If multiple Python versions, use: `py -3.12`

### 4. Node.js/NPM Issues

**Symptoms:**
- "Node not found"
- NPM install failures
- Build errors

**Solutions:**
1. **Clear NPM cache:**
   ```batch
   npm cache clean --force
   ```

2. **Delete and reinstall node_modules:**
   ```batch
   cd wren-ui
   rmdir /s /q node_modules
   del package-lock.json
   npm install
   ```

3. **Use Yarn instead:**
   ```batch
   npm install -g yarn
   yarn install
   yarn build
   ```

4. **Memory issues during build:**
   ```batch
   # Increase Node.js memory limit
   set NODE_OPTIONS=--max-old-space-size=8192
   npm run build
   ```

### 5. Qdrant Issues

**Symptoms:**
- "Qdrant not found"
- Vector database connection errors
- Indexing failures

**Solutions:**
1. **Install Qdrant:**
   - Download from: https://github.com/qdrant/qdrant/releases
   - Or install via Rust: `cargo install qdrant`

2. **Check Qdrant is running:**
   ```batch
   curl http://localhost:6333/health
   # Or open in browser: http://localhost:6333/dashboard
   ```

3. **Clear Qdrant data (if corrupted):**
   ```batch
   rmdir /s /q "%USERPROFILE%\.wrenai\qdrant_data"
   mkdir "%USERPROFILE%\.wrenai\qdrant_data"
   ```

4. **Alternative: Use in-memory Qdrant:**
   Edit `config.yaml`:
   ```yaml
   type: document_store
   provider: qdrant
   location: ":memory:"
   ```

### 6. Database Issues

**Symptoms:**
- SQLite errors
- Database connection failures
- Migration errors

**Solutions:**
1. **Reset SQLite database:**
   ```batch
   del "%USERPROFILE%\.wrenai\data\db.sqlite3"
   # Database will be recreated on next startup
   ```

2. **Check database permissions:**
   ```batch
   # Ensure the data directory is writable
   icacls "%USERPROFILE%\.wrenai\data" /grant %USERNAME%:F
   ```

3. **Use PostgreSQL instead:**
   - Install PostgreSQL
   - Update `.env`:
     ```env
     DB_TYPE=postgres
     DB_HOST=localhost
     DB_PORT=5432
     DB_NAME=wrenai
     DB_USER=postgres
     DB_PASSWORD=your_password
     ```

### 7. Configuration Issues

**Symptoms:**
- "Config file not found"
- Invalid configuration errors
- Service startup failures

**Solutions:**
1. **Verify config file location:**
   ```batch
   dir "%USERPROFILE%\.wrenai\config.yaml"
   ```

2. **Validate YAML syntax:**
   - Use an online YAML validator
   - Check for proper indentation (spaces, not tabs)

3. **Reset to default config:**
   ```batch
   copy config.gemini.yaml "%USERPROFILE%\.wrenai\config.yaml"
   ```

### 8. Network/Firewall Issues

**Symptoms:**
- Services can't communicate
- Timeout errors
- Connection refused

**Solutions:**
1. **Check Windows Firewall:**
   - Allow Python, Node.js, and Qdrant through firewall
   - Or temporarily disable firewall for testing

2. **Check antivirus:**
   - Add WrenAI directories to antivirus exclusions
   - Temporarily disable real-time protection

3. **Use localhost instead of 127.0.0.1:**
   - Some systems have issues with 127.0.0.1
   - Update all configs to use `localhost`

### 9. Performance Issues

**Symptoms:**
- Slow responses
- High memory usage
- Timeouts

**Solutions:**
1. **Increase timeouts:**
   Edit `config.yaml`:
   ```yaml
   settings:
     engine_timeout: 60
   ```

2. **Reduce batch sizes:**
   ```yaml
   settings:
     column_indexing_batch_size: 25
     table_column_retrieval_size: 50
   ```

3. **Monitor resource usage:**
   ```batch
   # Check memory usage
   tasklist /fi "imagename eq python.exe"
   tasklist /fi "imagename eq node.exe"
   ```

### 10. Model/API Issues

**Symptoms:**
- "Model not found" errors
- Slow AI responses
- Rate limiting errors

**Solutions:**
1. **Check model availability:**
   - Verify `gemini-2.0-flash-exp` is available
   - Try fallback models: `gemini-1.5-pro`, `gemini-1.5-flash`

2. **Handle rate limits:**
   Edit `config.yaml`:
   ```yaml
   models:
     - model: gemini/gemini-2.0-flash-exp
       timeout: 300  # Increase timeout
       kwargs:
         temperature: 0
         max_tokens: 2048  # Reduce if needed
   ```

3. **Monitor API usage:**
   - Check Google AI Studio dashboard
   - Monitor quota and billing

## Advanced Troubleshooting

### Enable Debug Logging

1. **AI Service debug:**
   Edit `config.yaml`:
   ```yaml
   settings:
     logging_level: DEBUG
   ```

2. **UI debug:**
   Set environment variable:
   ```batch
   set DEBUG=*
   ```

### Check Service Dependencies

```batch
# Create a simple health check script
echo @echo off > health_check.bat
echo echo Checking Qdrant... >> health_check.bat
echo curl -s http://localhost:6333/health >> health_check.bat
echo echo Checking AI Service... >> health_check.bat
echo curl -s http://localhost:5555/health >> health_check.bat
echo echo Checking UI... >> health_check.bat
echo curl -s http://localhost:3000/api/health >> health_check.bat
```

### Reset Everything

If all else fails, complete reset:

```batch
# Stop all services (Ctrl+C in each window)

# Remove all data
rmdir /s /q "%USERPROFILE%\.wrenai"

# Re-run setup
setup-windows.bat
```

## Getting Help

If you're still having issues:

1. **Check the logs** in each service window
2. **Search GitHub issues**: https://github.com/Canner/WrenAI/issues
3. **Join Discord**: https://discord.gg/5DvshJqG8Z
4. **Create a new issue** with:
   - Your Windows version
   - Error messages
   - Steps to reproduce
   - Log files

## Useful Commands

```batch
# Check all WrenAI processes
tasklist | findstr "python node qdrant"

# Kill all WrenAI processes
taskkill /f /im python.exe
taskkill /f /im node.exe
taskkill /f /im qdrant.exe

# Check disk space
dir "%USERPROFILE%\.wrenai" /-c

# Check network connectivity
ping localhost
telnet localhost 6333
telnet localhost 5555
telnet localhost 3000
```