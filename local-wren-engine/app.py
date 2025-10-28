#!/usr/bin/env python3
"""
Local Wren Engine - Docker-free replacement for wren-engine
This provides a minimal implementation of the wren-engine API endpoints
that WrenAI needs to function without Docker.
"""

import os
import json
import base64
import logging
from typing import Dict, Any, Optional
from pathlib import Path

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("local-wren-engine")

app = FastAPI(
    title="Local Wren Engine",
    description="Docker-free replacement for wren-engine",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request models
class MDLRequest(BaseModel):
    manifest: Optional[Dict[str, Any]] = None
    sql: str
    limit: Optional[int] = 500

# Global state
manifest_data = {}

@app.on_event("startup")
async def startup_event():
    """Initialize the server with default configuration"""
    global manifest_data
    
    # Load default manifest if available
    config_path = os.getenv("CONFIG_PATH", "")
    if config_path and os.path.exists(config_path):
        try:
            with open(config_path, 'r') as f:
                config = json.load(f)
                manifest_data = config.get("manifest", {})
        except Exception as e:
            logger.warning(f"Could not load config from {config_path}: {e}")
    
    logger.info("Local Wren Engine started successfully")
    logger.info(f"Server running on http://localhost:{os.getenv('PORT', 8080)}")

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "Local Wren Engine",
        "status": "running",
        "version": "1.0.0",
        "description": "Docker-free replacement for wren-engine"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "local-wren-engine"}

@app.get("/v1/mdl/dry-run")
async def dry_run(request: MDLRequest):
    """
    Validate SQL query without execution (dry run)
    """
    logger.info("Dry run request received")
    logger.debug(f"SQL: {request.sql}")
    
    try:
        # Simplified validation - check for basic SQL structure
        sql_lower = request.sql.lower().strip()
        
        if not sql_lower:
            raise HTTPException(status_code=400, detail="Empty SQL query")
        
        # Basic SQL validation
        valid_starts = ['select', 'with', 'show', 'describe', 'explain']
        if not any(sql_lower.startswith(start) for start in valid_starts):
            raise HTTPException(status_code=400, detail="Invalid SQL query")
        
        return {"status": "valid", "message": "SQL query is valid"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Dry run failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/v1/mdl/preview")
async def preview_query(request: MDLRequest):
    """
    Execute SQL query and return preview results
    """
    logger.info("Preview request received")
    logger.debug(f"SQL: {request.sql}")
    
    try:
        # For preview, return mock data
        # In a real implementation, this would execute against the actual database
        mock_data = {
            "columns": [
                {"name": "id", "type": "INTEGER"},
                {"name": "name", "type": "VARCHAR"},
                {"name": "value", "type": "DECIMAL"},
                {"name": "created_at", "type": "TIMESTAMP"}
            ],
            "data": [
                [1, "Sample Product A", 299.99, "2023-10-28T10:00:00Z"],
                [2, "Sample Product B", 149.50, "2023-10-28T11:00:00Z"],
                [3, "Sample Product C", 89.99, "2023-10-28T12:00:00Z"],
                [4, "Sample Product D", 199.99, "2023-10-28T13:00:00Z"],
                [5, "Sample Product E", 349.99, "2023-10-28T14:00:00Z"]
            ],
            "rowCount": 5,
            "executionTime": "0.032s",
            "sql": request.sql
        }
        
        # Apply limit
        limit = request.limit or 500
        if limit and limit < len(mock_data["data"]):
            mock_data["data"] = mock_data["data"][:limit]
            mock_data["rowCount"] = len(mock_data["data"])
        
        return mock_data
        
    except Exception as e:
        logger.error(f"Preview execution failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/v1/mdl/dry-run")
async def dry_run_post(request: MDLRequest):
    """
    Validate SQL query without execution (dry run) - POST version
    """
    return await dry_run(request)

@app.post("/v1/mdl/preview")
async def preview_query_post(request: MDLRequest):
    """
    Execute SQL query and return preview results - POST version
    """
    return await preview_query(request)

@app.get("/v1/mdl/manifest")
async def get_manifest():
    """
    Get the current manifest
    """
    logger.info("Manifest request received")
    return manifest_data

@app.post("/v1/mdl/manifest")
async def update_manifest(manifest: Dict[str, Any]):
    """
    Update the manifest
    """
    global manifest_data
    logger.info("Manifest update request received")
    manifest_data = manifest
    return {"status": "success", "message": "Manifest updated"}

@app.get("/v1/mdl/schema")
async def get_schema():
    """
    Get schema information
    """
    logger.info("Schema request received")
    
    # Return mock schema based on manifest or default
    schema = {
        "models": [
            {
                "name": "customers",
                "columns": [
                    {"name": "id", "type": "INTEGER", "primaryKey": True},
                    {"name": "name", "type": "VARCHAR", "nullable": False},
                    {"name": "email", "type": "VARCHAR", "nullable": True},
                    {"name": "created_at", "type": "TIMESTAMP", "nullable": False}
                ]
            },
            {
                "name": "orders",
                "columns": [
                    {"name": "id", "type": "INTEGER", "primaryKey": True},
                    {"name": "customer_id", "type": "INTEGER", "nullable": False},
                    {"name": "amount", "type": "DECIMAL", "nullable": False},
                    {"name": "status", "type": "VARCHAR", "nullable": False},
                    {"name": "created_at", "type": "TIMESTAMP", "nullable": False}
                ]
            },
            {
                "name": "products",
                "columns": [
                    {"name": "id", "type": "INTEGER", "primaryKey": True},
                    {"name": "name", "type": "VARCHAR", "nullable": False},
                    {"name": "price", "type": "DECIMAL", "nullable": False},
                    {"name": "category", "type": "VARCHAR", "nullable": True},
                    {"name": "created_at", "type": "TIMESTAMP", "nullable": False}
                ]
            }
        ],
        "relationships": [
            {
                "name": "customer_orders",
                "from": "orders.customer_id",
                "to": "customers.id",
                "type": "many-to-one"
            }
        ]
    }
    
    return schema

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    host = os.getenv("HOST", "0.0.0.0")
    
    logger.info(f"Starting Local Wren Engine on {host}:{port}")
    
    uvicorn.run(
        "app:app",
        host=host,
        port=port,
        reload=True,
        log_level="info"
    )