#!/usr/bin/env python3
"""
Local Ibis Server - Docker-free replacement for wren-engine-ibis
This provides a minimal implementation of the ibis-server API endpoints
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
logger = logging.getLogger("local-ibis-server")

app = FastAPI(
    title="Local Ibis Server",
    description="Docker-free replacement for wren-engine-ibis",
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
class QueryRequest(BaseModel):
    sql: str
    manifestStr: Optional[str] = None
    connectionInfo: Optional[Dict[str, Any]] = None

class DryPlanRequest(BaseModel):
    sql: str
    manifestStr: Optional[str] = None

# Global state
connection_info = {}
manifest = {}

@app.on_event("startup")
async def startup_event():
    """Initialize the server with default configuration"""
    global connection_info, manifest
    
    # Load default connection info if available
    config_path = os.getenv("CONFIG_PATH", "")
    if config_path and os.path.exists(config_path):
        try:
            with open(config_path, 'r') as f:
                config = json.load(f)
                connection_info = config.get("connection_info", {})
                manifest = config.get("manifest", {})
        except Exception as e:
            logger.warning(f"Could not load config from {config_path}: {e}")
    
    logger.info("Local Ibis Server started successfully")
    logger.info(f"Server running on http://localhost:{os.getenv('PORT', 8000)}")

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "Local Ibis Server",
        "status": "running",
        "version": "1.0.0",
        "description": "Docker-free replacement for wren-engine-ibis"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "local-ibis-server"}

@app.post("/v3/connector/{data_source}/query")
async def query_data(
    data_source: str,
    request: QueryRequest,
    dryRun: bool = Query(False),
    limit: int = Query(500)
):
    """
    Execute SQL query against the data source
    This is a simplified implementation that returns mock data for demonstration
    """
    logger.info(f"Query request for {data_source}: dryRun={dryRun}, limit={limit}")
    logger.debug(f"SQL: {request.sql}")
    
    try:
        if dryRun:
            # For dry run, just validate the SQL syntax (simplified)
            if not request.sql or not request.sql.strip():
                raise HTTPException(status_code=400, detail="Empty SQL query")
            
            # Return success for dry run
            return {"status": "valid", "message": "SQL syntax is valid"}
        
        else:
            # For actual query execution, return mock data
            # In a real implementation, this would execute against the actual database
            mock_data = {
                "columns": ["id", "name", "value", "created_at"],
                "data": [
                    [1, "Sample Item 1", 100.50, "2023-10-28T10:00:00Z"],
                    [2, "Sample Item 2", 250.75, "2023-10-28T11:00:00Z"],
                    [3, "Sample Item 3", 75.25, "2023-10-28T12:00:00Z"]
                ],
                "rowCount": 3,
                "executionTime": "0.045s"
            }
            
            # Apply limit
            if limit and limit < len(mock_data["data"]):
                mock_data["data"] = mock_data["data"][:limit]
                mock_data["rowCount"] = len(mock_data["data"])
            
            return mock_data
            
    except Exception as e:
        logger.error(f"Query execution failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/v3/connector/{data_source}/dry-plan")
async def dry_plan(data_source: str, request: DryPlanRequest):
    """
    Validate SQL query plan without execution
    """
    logger.info(f"Dry plan request for {data_source}")
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
        
        return {"status": "valid", "message": "Query plan is valid"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Dry plan failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/v3/connector/{data_source}/functions")
async def get_functions(data_source: str):
    """
    Get available functions for the data source
    """
    logger.info(f"Functions request for {data_source}")
    
    # Return common SQL functions
    functions = [
        "COUNT", "SUM", "AVG", "MIN", "MAX",
        "UPPER", "LOWER", "LENGTH", "SUBSTRING",
        "DATE", "NOW", "YEAR", "MONTH", "DAY",
        "COALESCE", "CASE", "CAST", "CONVERT"
    ]
    
    return functions

@app.get("/v3/connector/{data_source}/schema")
async def get_schema(data_source: str):
    """
    Get schema information for the data source
    """
    logger.info(f"Schema request for {data_source}")
    
    # Return mock schema
    schema = {
        "tables": [
            {
                "name": "customers",
                "columns": [
                    {"name": "id", "type": "INTEGER", "nullable": False},
                    {"name": "name", "type": "VARCHAR", "nullable": False},
                    {"name": "email", "type": "VARCHAR", "nullable": True},
                    {"name": "created_at", "type": "TIMESTAMP", "nullable": False}
                ]
            },
            {
                "name": "orders",
                "columns": [
                    {"name": "id", "type": "INTEGER", "nullable": False},
                    {"name": "customer_id", "type": "INTEGER", "nullable": False},
                    {"name": "amount", "type": "DECIMAL", "nullable": False},
                    {"name": "status", "type": "VARCHAR", "nullable": False},
                    {"name": "created_at", "type": "TIMESTAMP", "nullable": False}
                ]
            }
        ]
    }
    
    return schema

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    host = os.getenv("HOST", "0.0.0.0")
    
    logger.info(f"Starting Local Ibis Server on {host}:{port}")
    
    uvicorn.run(
        "app:app",
        host=host,
        port=port,
        reload=True,
        log_level="info"
    )