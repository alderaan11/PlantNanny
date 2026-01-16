"""
PlantNanny API Server - Main Application
Uses Connexion framework with ASGI backend
"""
import argparse
import os
import connexion
from connexion.middleware import MiddlewarePosition
from starlette.middleware.cors import CORSMiddleware
from pathlib import Path
import sys

# Add server directory to path for imports
server_dir = Path(__file__).parent
sys.path.insert(0, str(server_dir))

# Load .env file if python-dotenv is available
try:
    from dotenv import load_dotenv
    env_file = server_dir / ".env"
    if env_file.exists():
        load_dotenv(env_file)
except ImportError:
    pass


def create_app() -> connexion.AsyncApp:
    """Create and configure the Connexion application."""
    
    app = connexion.AsyncApp(
        __name__,
        specification_dir=str(Path(__file__).parent.parent / "api"),
    )
    
    # Add CORS middleware to allow cross-origin requests
    app.add_middleware(
        CORSMiddleware,
        position=MiddlewarePosition.BEFORE_EXCEPTION,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    # Add the API specification
    app.add_api(
        "plant_nanny_api.yaml",
        strict_validation=True,
        validate_responses=False,  # Disable for development
        pythonic_params=True,
    )
    
    # Setup logging for the server so errors, NotFound, and other HTTP issues are logged with details
    import logging
    from starlette.responses import JSONResponse
    from starlette.exceptions import HTTPException as StarletteHTTPException

    logger = logging.getLogger("plant_nanny.server")
    if not logger.handlers:
        handler = logging.StreamHandler()
        formatter = logging.Formatter("%(asctime)s %(levelname)s %(name)s %(message)s")
        handler.setFormatter(formatter)
        logger.addHandler(handler)
    logger.setLevel(logging.INFO)

    # Simple request logging middleware using pure ASGI (avoids BaseHTTPMiddleware issues)
    class RequestLoggingMiddleware:
        def __init__(self, app):
            self.app = app

        async def __call__(self, scope, receive, send):
            if scope["type"] != "http":
                await self.app(scope, receive, send)
                return
            
            path = scope.get("path", "")
            method = scope.get("method", "")
            logger.info(f"--> {method} {path}")
            
            status_code = None
            
            async def send_wrapper(message):
                nonlocal status_code
                if message["type"] == "http.response.start":
                    status_code = message.get("status", 0)
                await send(message)
            
            try:
                await self.app(scope, receive, send_wrapper)
                logger.info(f"<-- {status_code} {method} {path}")
            except Exception as exc:
                logger.exception(f"Exception while handling {method} {path}: {exc}")
                raise

    # Add middleware to the Connexion app (positioned before exception handling)
    app.add_middleware(RequestLoggingMiddleware, position=MiddlewarePosition.BEFORE_EXCEPTION)

    # Exception handlers to log details and return JSON body
    async def http_exception_handler(request, exc):
        status = getattr(exc, "status_code", None)
        detail = getattr(exc, "detail", str(exc))
        logger.warning(f"HTTP error {status} on {request.method} {request.url.path}: {detail}")
        return JSONResponse({"error": str(detail), "status": status}, status_code=status or 500)

    async def exception_handler(request, exc):
        logger.exception(f"Unhandled exception on {request.method} {request.url.path}: {exc}")
        return JSONResponse({"error": "Internal server error"}, status_code=500)

    # Register handlers on the underlying Starlette app (Connexion AsyncApp wraps a Starlette app)
    # Connexion exposes the underlying Starlette app in different ways depending on version; try common attributes.
    starlette_app = getattr(app, "app", None) or getattr(app, "asgi_app", None) or app
    if hasattr(starlette_app, "add_exception_handler"):
        starlette_app.add_exception_handler(StarletteHTTPException, http_exception_handler)
        starlette_app.add_exception_handler(Exception, exception_handler)
    else:
        logger.warning("Could not find Starlette app to register exception handlers; skipping registration")

    return app


def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description="PlantNanny API Server")
    parser.add_argument(
        "--seed",
        action="store_true",
        default=os.getenv("DEV_SEED_DATA", "").lower() == "true",
        help="Seed the database with fake development data",
    )
    parser.add_argument(
        "--host",
        default=os.getenv("SERVER_HOST", "0.0.0.0"),
        help="Host to bind to (default: 0.0.0.0)",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=int(os.getenv("SERVER_PORT", "8080")),
        help="Port to bind to (default: 8080)",
    )
    parser.add_argument(
        "--mqtt-broker",
        default=os.getenv("MQTT_BROKER_HOST", "localhost"),
        help="MQTT broker hostname (default: localhost)",
    )
    parser.add_argument(
        "--mqtt-port",
        type=int,
        default=int(os.getenv("MQTT_BROKER_PORT", "1883")),
        help="MQTT broker port (default: 1883)",
    )
    parser.add_argument(
        "--mqtt-username",
        default=os.getenv("MQTT_USERNAME"),
        help="MQTT username for authentication",
    )
    parser.add_argument(
        "--mqtt-password",
        default=os.getenv("MQTT_PASSWORD"),
        help="MQTT password for authentication",
    )
    parser.add_argument(
        "--no-mqtt",
        action="store_true",
        default=os.getenv("MQTT_DISABLED", "").lower() == "true",
        help="Disable MQTT handler",
    )
    return parser.parse_args()


app = create_app()


if __name__ == "__main__":
    import uvicorn
    import asyncio
    import logging
    from mqtt_handler import setup_mqtt_handler, shutdown_mqtt_handler
    import database as db
    
    args = parse_args()
    app = create_app()
    
    logger = logging.getLogger("plant_nanny.server")
    
    async def main():
        # Initialize database connection
        try:
            await db.init_db()
            logger.info("Database initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize database: {e}")
            raise
        
        # Seed database if requested
        if args.seed:
            try:
                await db.seed_fake_data()
                logger.info("Database seeded with fake data")
            except Exception as e:
                logger.warning(f"Failed to seed database (may already have data): {e}")
        
        # Setup MQTT handler if not disabled
        if not args.no_mqtt:
            try:
                await setup_mqtt_handler(
                    broker_host=args.mqtt_broker,
                    broker_port=args.mqtt_port,
                    username=args.mqtt_username,
                    password=args.mqtt_password,
                )
            except Exception as e:
                logger.warning(
                    f"Failed to start MQTT handler: {e}. Continuing without MQTT."
                )
        
        # Run the server
        config = uvicorn.Config(app, host=args.host, port=args.port)
        server = uvicorn.Server(config)
        
        try:
            await server.serve()
        finally:
            await shutdown_mqtt_handler()
            await db.close_db()
            logger.info("Database connection closed")
    
    asyncio.run(main())
