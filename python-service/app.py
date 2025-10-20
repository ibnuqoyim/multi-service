import json
from flask import Flask, jsonify
import os
import requests
import logging
from dataclasses import dataclass
from typing import Optional
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class Config:
    """Configuration class to hold all application settings"""
    port: int
    php_api_url: str
    go_service_url: str
    
    def __post_init__(self):
        """Log configuration after initialization"""
        logger.info("Configuration loaded:")
        logger.info(f"  PORT: {self.port}")
        logger.info(f"  PHP_API_URL: {self.php_api_url}")
        logger.info(f"  GO_SERVICE_URL: {self.go_service_url}")

def load_config() -> Config:
    """Load configuration from environment variables and .env file"""
    # Load .env file
    if load_dotenv():
        logger.info("Successfully loaded .env file")
    else:
        logger.warning("Warning: Could not load .env file, using system environment variables")
    
    # Create config object with environment variables and defaults
    config = Config(
        port=int(os.getenv("PORT", "8085")),
        php_api_url=os.getenv("PHP_API_URL", "http://localhost:8089/users"),
        go_service_url=os.getenv("GO_SERVICE_URL", "http://localhost:8088/ping")
    )
    
    return config

def call_services():
    """Call both PHP API and Go service"""
    config = app.config['APP_CONFIG']
    
    logger.info(f"Calling PHP API: {config.php_api_url}")
    logger.info(f"Calling Go service: {config.go_service_url}")
    
    try:
        # Call PHP API
        php_response = requests.get(config.php_api_url, timeout=10)
        php_data = {
            "status_code": php_response.status_code,
            "response": php_response.json()
        }
    except requests.RequestException as e:
        logger.error(f"Error calling PHP API: {e}")
        php_data = {
            "status_code": 500,
            "error": str(e)
        }
    
    try:
        # Call Go service
        go_response = requests.get(config.go_service_url, timeout=10)
        go_data = {
            "status_code": go_response.status_code,
            "response": go_response.json() if go_response.headers.get('content-type') == 'application/json' else go_response.text
        }
    except requests.RequestException as e:
        logger.error(f"Error calling Go service: {e}")
        go_data = {
            "status_code": 500,
            "error": str(e)
        }
    
    logger.info("Response from PHP API and Go service:")
    logger.info(json.dumps({
        "php_api": php_data,
        "go_service": go_data,
        "timestamp": requests.utils.default_headers()['User-Agent']
    }))

def create_app(config: Config) -> Flask:
    """Create Flask application with configuration"""
    app = Flask(__name__)
    app.config['APP_CONFIG'] = config
    
    @app.route('/hello')
    def hello():
        """Health check endpoint"""
        return jsonify({
            "message": "Hello from Python service",
        })

    # @app.route('/call')
    
    
    return app

if __name__ == "__main__":
    logger.info("Starting Python service...")
    
    # Load configuration
    config = load_config()
    
    # Create Flask app with config
    app = create_app(config)
    
    logger.info(f"Python service starting on port {config.port}")

    # call php api and go service
    call_services()
    
    # Run the application
    app.run(host="0.0.0.0", port=config.port, debug=False)
