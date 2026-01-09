"""
PlantNanny API Server - Main Application
Uses Connexion framework with ASGI backend
"""
import argparse
import connexion
from connexion.middleware import MiddlewarePosition
from starlette.middleware.cors import CORSMiddleware
from pathlib import Path
import sys

# Add server directory to path for imports
server_dir = Path(__file__).parent
sys.path.insert(0, str(server_dir))


def create_app(seed_data: bool = False) -> connexion.AsyncApp:
    """Create and configure the Connexion application.
    
    Args:
        seed_data: If True, populate stores with fake development data.
    """
    if seed_data:
        from storage import seed_fake_data
        seed_fake_data()
    
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
    from starlette.middleware.base import BaseHTTPMiddleware
    from starlette.requests import Request

    logger = logging.getLogger("plant_nanny.server")
    if not logger.handlers:
        handler = logging.StreamHandler()
        formatter = logging.Formatter("%(asctime)s %(levelname)s %(name)s %(message)s")
        handler.setFormatter(formatter)
        logger.addHandler(handler)
    logger.setLevel(logging.INFO)

    # Simple request logging middleware
    class RequestLoggingMiddleware(BaseHTTPMiddleware):
        async def dispatch(self, request: Request, call_next):
            logger.info(f"--> {request.method} {request.url.path}")
            try:
                response = await call_next(request)
                logger.info(f"<-- {response.status_code} {request.method} {request.url.path}")
                return response
            except Exception as exc:
                logger.exception(f"Exception while handling {request.method} {request.url.path}: {exc}")
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
        help="Seed the database with fake development data",
    )
    parser.add_argument(
        "--host",
        default="0.0.0.0",
        help="Host to bind to (default: 0.0.0.0)",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=8080,
        help="Port to bind to (default: 8080)",
    )
    parser.add_argument(
        "--mqtt-broker",
        default="localhost",
        help="MQTT broker hostname (default: localhost)",
    )
    parser.add_argument(
        "--mqtt-port",
        type=int,
        default=1883,
        help="MQTT broker port (default: 1883)",
    )
    parser.add_argument(
        "--no-mqtt",
        action="store_true",
        help="Disable MQTT handler",
    )
    return parser.parse_args()


app = create_app()


if __name__ == "__main__":
    import uvicorn
    import asyncio
    from mqtt_handler import setup_mqtt_handler, shutdown_mqtt_handler
    
    args = parse_args()
    app = create_app(seed_data=args.seed)
    
    async def main():
        # Setup MQTT handler if not disabled
        if not args.no_mqtt:
            try:
                await setup_mqtt_handler(
                    broker_host=args.mqtt_broker,
                    broker_port=args.mqtt_port,
                )
            except Exception as e:
                import logging
                logging.getLogger("plant_nanny.mqtt").warning(
                    f"Failed to start MQTT handler: {e}. Continuing without MQTT."
                )
        
        # Run the server
        config = uvicorn.Config(app, host=args.host, port=args.port)
        server = uvicorn.Server(config)
        
        try:
            await server.serve()
        finally:
            await shutdown_mqtt_handler()
    
    asyncio.run(main())
