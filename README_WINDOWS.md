# 🚀 WrenAI Windows Setup (No Docker) with Gemini 2.5 Flash

Run WrenAI locally on Windows without Docker, powered by Google's Gemini 2.5 Flash model.

## ⚡ Quick Start

### 1. Prerequisites
- **Node.js 18+**: https://nodejs.org/
- **Python 3.12**: https://python.org/
- **Qdrant**: https://github.com/qdrant/qdrant/releases
- **Gemini API Key**: https://aistudio.google.com/

### 2. Automated Setup
```batch
# Clone the repository
git clone https://github.com/Canner/WrenAI.git
cd WrenAI

# Run the setup script
setup-windows.bat
```

### 3. Configure API Key
Edit `%USERPROFILE%\.wrenai\.env` and add your Gemini API key:
```env
GEMINI_API_KEY=your_actual_api_key_here
```

### 4. Start WrenAI
```batch
# Start all services
start-all.bat
```

### 5. Access WrenAI
Open http://localhost:3000 in your browser (wait 2-3 minutes for startup)

## 📁 What Gets Created

```
%USERPROFILE%\.wrenai\
├── config.yaml          # Gemini 2.5 Flash configuration
├── .env                  # Environment variables
├── data\                 # SQLite database and files
└── qdrant_data\         # Vector database storage
```

## 🔧 Manual Setup (Alternative)

If the automated setup doesn't work:

### 1. Create Configuration
```batch
mkdir %USERPROFILE%\.wrenai
mkdir %USERPROFILE%\.wrenai\data
copy config.gemini.yaml %USERPROFILE%\.wrenai\config.yaml
copy .env.template %USERPROFILE%\.wrenai\.env
```

### 2. Install Dependencies
```batch
# Python dependencies
cd wren-ai-service
pip install poetry
poetry install

# Node.js dependencies  
cd ..\wren-ui
npm install
npm run build
```

### 3. Start Services Manually
```batch
# Terminal 1: Start Qdrant
start-qdrant.bat

# Terminal 2: Start AI Service
start-ai-service.bat

# Terminal 3: Start UI
start-ui.bat
```

## 🎯 Service Architecture

| Service | Port | Purpose |
|---------|------|---------|
| **Wren UI** | 3000 | Web interface |
| **AI Service** | 5555 | Gemini-powered AI backend |
| **Qdrant** | 6333 | Vector database |

## 🔍 Troubleshooting

### Common Issues
- **API Key Error**: Check your Gemini API key in `.env`
- **Port Conflicts**: Use `netstat -an | findstr "LISTENING"` to check ports
- **Dependencies**: Ensure Node.js, Python, and Qdrant are installed

### Quick Fixes
```batch
# Reset everything
rmdir /s /q %USERPROFILE%\.wrenai
setup-windows.bat

# Check service status
netstat -an | findstr ":3000 :5555 :6333"

# View logs
# Check the command windows for each service
```

For detailed troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

## 📚 Documentation

- **[Complete Setup Guide](WINDOWS_SETUP_GUIDE.md)** - Detailed instructions
- **[Troubleshooting Guide](TROUBLESHOOTING.md)** - Common issues and solutions
- **[WrenAI Docs](https://docs.getwren.ai/)** - Official documentation

## 🎨 Features

- 🤖 **Gemini 2.5 Flash** - Latest Google AI model
- 💬 **Natural Language Queries** - Ask questions in plain English
- 📊 **Auto-Generated Charts** - Visual insights from your data
- 🔗 **Multiple Data Sources** - PostgreSQL, MySQL, BigQuery, and more
- 🚀 **No Docker Required** - Native Windows installation

## 🔧 Configuration

### Change AI Model
Edit `%USERPROFILE%\.wrenai\config.yaml`:
```yaml
models:
  - model: gemini/gemini-1.5-pro  # Alternative model
    alias: default
```

### Use Different Ports
Edit the batch files to change default ports:
- UI: Change `3000` in `start-ui.bat`
- AI Service: Change `5555` in `start-ai-service.bat`
- Qdrant: Change `6333` in `start-qdrant.bat`

### Connect Database
1. Start WrenAI
2. Go to http://localhost:3000
3. Click "Connect Data Source"
4. Choose your database type
5. Enter connection details

## 🆘 Support

- **GitHub Issues**: https://github.com/Canner/WrenAI/issues
- **Discord Community**: https://discord.gg/5DvshJqG8Z
- **Documentation**: https://docs.getwren.ai/

## 📝 License

This project is licensed under the AGPL-3.0 License - see the [LICENSE](LICENSE) file for details.

---

**Made with ❤️ by the WrenAI team**

🌟 **Star this repo** if it helped you!