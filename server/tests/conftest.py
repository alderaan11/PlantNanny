"""
Pytest configuration and fixtures for PlantNanny server tests.

The tests will try to connect to PostgreSQL first, and fall back to SQLite if unavailable.

Usage:
    # With PostgreSQL (recommended for CI):
    export TEST_DATABASE_URL=postgresql+asyncpg://plantnanny:plantnanny_secret@localhost:5432/plantnanny_test
    cd server && pytest tests/ -v

    # With SQLite (for local development without PostgreSQL):
    export USE_SQLITE=1
    cd server && pytest tests/ -v
"""
import pytest
import asyncio
import os
import sys
import tempfile

# Add server directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def get_test_database_url() -> str:
    """Get the test database URL, preferring PostgreSQL but falling back to SQLite."""
    if os.getenv("USE_SQLITE", "").lower() in ("1", "true", "yes"):
        # Use SQLite with a temp file
        return "sqlite+aiosqlite:///./test_plantnanny.db"
    
    return os.getenv(
        "TEST_DATABASE_URL",
        "postgresql+asyncpg://plantnanny:plantnanny_secret@localhost:5432/plantnanny_test"
    )


TEST_DATABASE_URL = get_test_database_url()


def pytest_configure(config):
    """Configure pytest with custom markers."""
    config.addinivalue_line(
        "markers", "database: mark test as requiring database connection"
    )


@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for the test session."""
    policy = asyncio.get_event_loop_policy()
    loop = policy.new_event_loop()
    yield loop
    loop.close()


async def _check_database_connection(url: str) -> bool:
    """Check if we can connect to the database."""
    try:
        from database import init_db, close_db
        await init_db(url)
        await close_db()
        return True
    except Exception as e:
        print(f"\n⚠️  Database connection failed ({url.split('@')[-1] if '@' in url else url}): {e}")
        return False


async def _try_sqlite_fallback() -> str | None:
    """Try to use SQLite as a fallback."""
    sqlite_url = "sqlite+aiosqlite:///./test_plantnanny.db"
    try:
        # Try importing aiosqlite
        import aiosqlite
        if await _check_database_connection(sqlite_url):
            return sqlite_url
    except ImportError:
        print("\n⚠️  aiosqlite not installed. Run: pip install aiosqlite")
    return None


@pytest.fixture(scope="session")
async def database_url():
    """Get a working database URL, with automatic fallback to SQLite."""
    global TEST_DATABASE_URL
    
    # Try primary database
    if await _check_database_connection(TEST_DATABASE_URL):
        return TEST_DATABASE_URL
    
    # Try SQLite fallback
    if "postgresql" in TEST_DATABASE_URL:
        print("\n🔄 PostgreSQL not available, trying SQLite fallback...")
        sqlite_url = await _try_sqlite_fallback()
        if sqlite_url:
            TEST_DATABASE_URL = sqlite_url
            os.environ["DATABASE_URL"] = sqlite_url
            print(f"✅ Using SQLite: {sqlite_url}")
            return sqlite_url
    
    pytest.skip(
        "No database available for testing.\n"
        "Options:\n"
        "  1. Start PostgreSQL: docker-compose up -d postgres-test\n"
        "  2. Use SQLite: pip install aiosqlite && export USE_SQLITE=1\n"
        "  3. Set TEST_DATABASE_URL environment variable"
    )


@pytest.fixture(scope="session")
async def setup_database(database_url):
    """Initialize the test database once for the session."""
    from database import init_db, close_db
    
    # Set environment variable for database module
    os.environ["DATABASE_URL"] = database_url
    
    await init_db(database_url)
    yield
    await close_db()
    
    # Clean up SQLite file if used
    if "sqlite" in database_url:
        db_file = database_url.replace("sqlite+aiosqlite:///", "")
        if os.path.exists(db_file):
            os.remove(db_file)


@pytest.fixture(autouse=True)
async def clean_database(setup_database):
    """Clean all data before each test."""
    from database import get_session
    from sqlalchemy import text
    
    async with get_session() as session:
        # Delete in order respecting foreign keys
        await session.execute(text("DELETE FROM commands"))
        await session.execute(text("DELETE FROM readings"))
        await session.execute(text("DELETE FROM device_api_keys"))
        await session.execute(text("DELETE FROM devices"))
        await session.execute(text("DELETE FROM firmware"))
    yield

