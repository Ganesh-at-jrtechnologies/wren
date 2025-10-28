# WrenAI Docker-Free Setup Guide

This guide explains how to run WrenAI on Windows without Docker, using local Python services and Gemini 2.5 Flash.

## Overview

This Docker-free setup replaces the Docker containers with local Python services:

- **Local Wren Engine** (Python FastAPI) replaces the Java Docker container
- **Local Ibis Server** (Python FastAPI) replaces the Docker ibis-server
- **Qdrant** runs as a local binary (no Docker)
- **WrenAI Service** and **WrenUI** run locally as before

## Prerequisites

Before starting, ensure you have:

1. **Node.js 18+** - Download from [nodejs.org](https://nodejs.org/)
2. **Python 3.12+** - Download from [python.org](https://python.org/)
3. **Poetry** - Install from [python-poetry.org](https://python-poetry.org/)
4. **Qdrant** - Download from [qdrant.tech](https://qdrant.tech/)
5. **Gemini API Key** - Get from [Google AI Studio](https://aistudio.google.com/)

## Quick Setup

### 1. Run the Setup Script

```batch
setup-dockerfree.bat
```

This script will:
- Create configuration directories
- Copy Docker-free configuration files
- Install all dependencies
- Set up local services
- Build the UI

### 2. Configure Your API Key

Edit `%USERPROFILE%\.wrenai\.env` and add your Gemini API key:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### 3. Start All Services

```batch
start-all-dockerfree.bat
```

This will start all services in separate windows:
- Qdrant Vector Database (port 6333)
- Local Wren Engine (port 8080)
- Local Ibis Server (port 8000)
- WrenAI Service (port 5555)
- WrenUI (port 3000)

### 4. Access WrenAI

Open your browser and go to: http://localhost:3000

## Manual Setup

If you prefer to set up manually:

### 1. Create Configuration Directory

```batch
mkdir %USERPROFILE%\.wrenai
mkdir %USERPROFILE%\.wrenai\data
mkdir %USERPROFILE%\.wrenai\qdrant_data
```

### 2. Copy Configuration Files

```batch
copy config.dockerfree.yaml %USERPROFILE%\.wrenai\config.yaml
copy .env.dockerfree %USERPROFILE%\.wrenai\.env
```

### 3. Install Dependencies

```batch
cd wren-ai-service
poetry install

cd ..\wren-ui
npm install
npm run build
```

### 4. Set Up Local Services

```batch
cd local-wren-engine
python -m venv venv
venv\Scripts\activate.bat
pip install -r requirements.txt
deactivate

cd ..\local-ibis-server
python -m venv venv
venv\Scripts\activate.bat
pip install -r requirements.txt
deactivate
```

### 5. Start Services Individually

Start each service in a separate command window:

```batch
# Terminal 1: Qdrant
start-qdrant.bat

# Terminal 2: Local Wren Engine
start-local-engine.bat

# Terminal 3: Local Ibis Server
start-local-ibis.bat

# Terminal 4: WrenAI Service
start-ai-service.bat

# Terminal 5: WrenUI
start-ui.bat
```

## Service Architecture

### Local Services (Docker-free)

| Service | Port | Purpose | Replaces |
|---------|------|---------|----------|
| Local Wren Engine | 8080 | Semantic engine for MDL operations | Java wren-engine Docker container |
| Local Ibis Server | 8000 | Data processing and SQL execution | ibis-server Docker container |
| Qdrant | 6333 | Vector database for embeddings | Qdrant Docker container |
| WrenAI Service | 5555 | Main AI service with LLM integration | N/A (already local) |
| WrenUI | 3000 | Web interface | N/A (already local) |

### API Endpoints

#### Local Wren Engine (http://localhost:8080)
- `GET /health` - Health check
- `GET/POST /v1/mdl/dry-run` - Validate SQL queries
- `GET/POST /v1/mdl/preview` - Execute SQL queries with preview
- `GET /v1/mdl/manifest` - Get current manifest
- `POST /v1/mdl/manifest` - Update manifest
- `GET /v1/mdl/schema` - Get schema information

#### Local Ibis Server (http://localhost:8000)
- `GET /health` - Health check
- `POST /v3/connector/{data_source}/query` - Execute SQL queries
- `POST /v3/connector/{data_source}/dry-plan` - Validate query plans
- `GET /v3/connector/{data_source}/functions` - Get available functions
- `GET /v3/connector/{data_source}/schema` - Get schema information

## Configuration

### Main Configuration (`%USERPROFILE%\.wrenai\config.yaml`)

The Docker-free configuration uses local service endpoints:

```yaml
type: llm
provider: litellm_llm
models:
  - model: gemini/gemini-2.0-flash-exp
    alias: default
    timeout: 120
    kwargs:
      n: 1
      temperature: 0

---
type: local_services
config:
  wren_engine:
    host: localhost
    port: 8080
    endpoint: http://localhost:8080
  ibis_server:
    host: localhost
    port: 8000
    endpoint: http://localhost:8000
```

### Environment Variables (`%USERPROFILE%\.wrenai\.env`)

Key environment variables for Docker-free setup:

```env
# Required
GEMINI_API_KEY=your_gemini_api_key_here

# Local service endpoints
WREN_ENGINE_ENDPOINT=http://localhost:8080
IBIS_SERVER_ENDPOINT=http://localhost:8000
QDRANT_HOST=localhost
QDRANT_PORT=6333

# Local service configuration
LOCAL_WREN_ENGINE_HOST=localhost
LOCAL_WREN_ENGINE_PORT=8080
LOCAL_IBIS_SERVER_HOST=localhost
LOCAL_IBIS_SERVER_PORT=8000
```

## Troubleshooting

### Common Issues

#### Services Won't Start

1. **Check if ports are in use:**
   ```batch
   netstat -an | findstr :8080
   netstat -an | findstr :8000
   netstat -an | findstr :6333
   ```

2. **Kill existing processes:**
   ```batch
   taskkill /f /im python.exe
   taskkill /f /im node.exe
   taskkill /f /im qdrant.exe
   ```

#### API Key Issues

1. **Verify your Gemini API key:**
   - Go to [Google AI Studio](https://aistudio.google.com/)
   - Generate a new API key if needed
   - Update `%USERPROFILE%\.wrenai\.env`

2. **Test API key:**
   ```batch
   curl -H "Authorization: Bearer YOUR_API_KEY" https://generativelanguage.googleapis.com/v1/models
   ```

#### Local Services Not Responding

1. **Check service logs:**
   - Look at the command windows for error messages
   - Check log files in `%USERPROFILE%\.wrenai\logs\`

2. **Restart individual services:**
   ```batch
   # Stop the service (Ctrl+C in its window)
   # Then restart:
   start-local-engine.bat
   start-local-ibis.bat
   ```

#### Dependencies Missing

1. **Reinstall Python dependencies:**
   ```batch
   cd local-wren-engine
   venv\Scripts\activate.bat
   pip install --upgrade -r requirements.txt
   deactivate
   ```

2. **Reinstall Node.js dependencies:**
   ```batch
   cd wren-ui
   npm install --force
   npm run build
   ```

### Service Health Checks

Test if services are running correctly:

```batch
# Qdrant
curl http://localhost:6333/health

# Local Wren Engine
curl http://localhost:8080/health

# Local Ibis Server
curl http://localhost:8000/health

# WrenAI Service
curl http://localhost:5555/health

# WrenUI
curl http://localhost:3000
```

## Advantages of Docker-Free Setup

1. **No Docker Required** - Eliminates Docker Desktop dependency
2. **Faster Startup** - Local services start faster than containers
3. **Easier Debugging** - Direct access to service logs and code
4. **Lower Resource Usage** - No Docker overhead
5. **Windows Native** - Better integration with Windows environment
6. **Simplified Development** - Easier to modify and extend services

## Limitations

1. **Mock Data** - Local services return mock data for demonstration
2. **Simplified Logic** - Some advanced features may not be fully implemented
3. **No Production Use** - This setup is for development and testing only

## Extending the Local Services

### Adding Real Database Connections

To connect to real databases, modify the local services:

1. **Edit `local-ibis-server/app.py`:**
   ```python
   # Add database connection logic
   import sqlalchemy
   
   # Replace mock data with real database queries
   ```

2. **Edit `local-wren-engine/app.py`:**
   ```python
   # Add real MDL processing logic
   # Connect to actual data sources
   ```

### Adding New Endpoints

Both local services use FastAPI, making it easy to add new endpoints:

```python
@app.post("/v1/custom/endpoint")
async def custom_endpoint(request: CustomRequest):
    # Your custom logic here
    return {"result": "success"}
```

## Support

For issues with this Docker-free setup:

1. Check the troubleshooting section above
2. Review service logs in command windows
3. Test individual services using the health check endpoints
4. Ensure all prerequisites are properly installed

For general WrenAI issues, refer to the main documentation and GitHub repository.