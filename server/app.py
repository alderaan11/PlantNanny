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
    return parser.parse_args()


app = create_app()


if __name__ == "__main__":
    import uvicorn
    args = parse_args()
    app = create_app(seed_data=args.seed)
    uvicorn.run(app, host=args.host, port=args.port)
