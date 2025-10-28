# WrenAI Docker-Free Setup with Gemini 2.5 Flash

🚀 **Run WrenAI on Windows without Docker!**

This setup eliminates the need for Docker by replacing Docker containers with local Python services, making it perfect for Windows users who want to avoid Docker Desktop.

## ⚡ Quick Start

### 1. Prerequisites
- **Node.js 18+** ([Download](https://nodejs.org/))
- **Python 3.12+** ([Download](https://python.org/))
- **Poetry** ([Install](https://python-poetry.org/))
- **Qdrant** ([Download](https://qdrant.tech/))
- **Gemini API Key** ([Get Key](https://aistudio.google.com/))

### 2. One-Click Setup
```batch
setup-dockerfree.bat
```

### 3. Add Your API Key
Edit `%USERPROFILE%\.wrenai\.env`:
```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### 4. Start WrenAI
```batch
start-all-dockerfree.bat
```

### 5. Open WrenAI
🌐 **http://localhost:3000**

## 🏗️ Architecture

### Docker-Free Services

| Service | Port | Purpose | Status |
|---------|------|---------|--------|
| **Local Wren Engine** | 8080 | Semantic engine (replaces Java Docker) | ✅ Python FastAPI |
| **Local Ibis Server** | 8000 | Data processing (replaces Docker) | ✅ Python FastAPI |
| **Qdrant Vector DB** | 6333 | Vector database | ✅ Local binary |
| **WrenAI Service** | 5555 | Main AI service | ✅ Python Poetry |
| **WrenUI** | 3000 | Web interface | ✅ Node.js/React |

## 🎯 What's Different?

### Before (Docker Required)
```
Docker Desktop → wren-engine (Java) → ibis-server → WrenAI
```

### After (Docker-Free)
```
Local Python Services → Local Wren Engine → Local Ibis Server → WrenAI
```

## 📁 File Structure

```
WrenAI/
├── local-wren-engine/          # Python replacement for Java wren-engine
│   ├── app.py                  # FastAPI server with MDL endpoints
│   └── requirements.txt        # Python dependencies
├── local-ibis-server/          # Python replacement for ibis-server
│   ├── app.py                  # FastAPI server with data endpoints
│   └── requirements.txt        # Python dependencies
├── config.dockerfree.yaml     # Docker-free configuration
├── .env.dockerfree            # Environment template
├── setup-dockerfree.bat       # One-click setup script
├── start-all-dockerfree.bat   # Start all services
├── start-local-engine.bat     # Start wren engine
├── start-local-ibis.bat       # Start ibis server
└── DOCKER_FREE_SETUP.md       # Detailed documentation
```

## 🔧 Manual Setup

If you prefer manual setup:

```batch
# 1. Create directories
mkdir %USERPROFILE%\.wrenai\data
mkdir %USERPROFILE%\.wrenai\qdrant_data

# 2. Copy configs
copy config.dockerfree.yaml %USERPROFILE%\.wrenai\config.yaml
copy .env.dockerfree %USERPROFILE%\.wrenai\.env

# 3. Install dependencies
cd wren-ai-service && poetry install
cd ..\wren-ui && npm install && npm run build

# 4. Setup local services
cd ..\local-wren-engine && python -m venv venv && venv\Scripts\activate && pip install -r requirements.txt
cd ..\local-ibis-server && python -m venv venv && venv\Scripts\activate && pip install -r requirements.txt
```

## 🧪 Testing Local Services

Test the local services directly:

```batch
# Health checks
curl http://localhost:8080/health  # Local Wren Engine
curl http://localhost:8000/health  # Local Ibis Server
curl http://localhost:6333/health  # Qdrant
curl http://localhost:5555/health  # WrenAI Service

# API endpoints
curl http://localhost:8080/v1/mdl/schema      # Get schema from Wren Engine
curl http://localhost:8000/v3/connector/test/schema  # Get schema from Ibis Server
```

## 🎨 Customization

### Adding Real Database Connections

The local services currently return mock data. To connect to real databases:

1. **Edit `local-ibis-server/app.py`** - Add your database connection logic
2. **Edit `local-wren-engine/app.py`** - Add real MDL processing
3. **Update configuration** - Add your database credentials

### Extending API Endpoints

Both services use FastAPI, making it easy to add new endpoints:

```python
@app.post("/v1/custom/endpoint")
async def custom_endpoint(request: CustomRequest):
    # Your logic here
    return {"result": "success"}
```

## 🚨 Troubleshooting

### Services Won't Start
```batch
# Check if ports are in use
netstat -an | findstr :8080
netstat -an | findstr :8000

# Kill existing processes
taskkill /f /im python.exe
taskkill /f /im node.exe
```

### API Key Issues
1. Verify your key at [Google AI Studio](https://aistudio.google.com/)
2. Update `%USERPROFILE%\.wrenai\.env`
3. Restart services

### Dependencies Missing
```batch
# Reinstall Python deps
cd local-wren-engine
venv\Scripts\activate
pip install --upgrade -r requirements.txt

# Reinstall Node deps
cd ..\wren-ui
npm install --force
```

## ✅ Advantages

- ✅ **No Docker Required** - Eliminates Docker Desktop dependency
- ✅ **Faster Startup** - Local services start faster than containers
- ✅ **Easier Debugging** - Direct access to logs and code
- ✅ **Lower Resource Usage** - No Docker overhead
- ✅ **Windows Native** - Better Windows integration
- ✅ **Simplified Development** - Easier to modify and extend

## 📚 Documentation

- **[DOCKER_FREE_SETUP.md](DOCKER_FREE_SETUP.md)** - Comprehensive setup guide
- **[Original README](README.md)** - Standard Docker setup
- **[Configuration Guide](config.gemini.yaml)** - Gemini configuration

## 🤝 Contributing

This Docker-free setup is designed to make WrenAI more accessible on Windows. Contributions welcome:

1. **Improve local services** - Add more realistic data processing
2. **Add database connectors** - Support more data sources
3. **Enhance documentation** - Help others get started
4. **Report issues** - Help us improve the setup

## 📄 License

Same as WrenAI main project.

---

**Happy coding with WrenAI! 🎉**