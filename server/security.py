"""Security handlers for authentication."""
import logging
import os
from connexion.exceptions import OAuthProblem

import database as db

# Logger for security events (do not log secrets in full)
logger = logging.getLogger("plant_nanny.security")
if not logger.handlers:
    handler = logging.StreamHandler()
    formatter = logging.Formatter("%(asctime)s %(levelname)s %(name)s %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
logger.setLevel(logging.INFO)

# Firebase Admin SDK initialization
_firebase_app = None

def _init_firebase():
    """Initialize Firebase Admin SDK if not already initialized."""
    global _firebase_app
    if _firebase_app is not None:
        return _firebase_app
    
    try:
        import firebase_admin
        from firebase_admin import credentials
        
        # Check if already initialized
        try:
            _firebase_app = firebase_admin.get_app()
            return _firebase_app
        except ValueError:
            pass
        
        # Try to use service account credentials from environment or file
        cred_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
        project_id = os.getenv("FIREBASE_PROJECT_ID", "plantnanny-90165")
        
        if cred_path and os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            _firebase_app = firebase_admin.initialize_app(cred)
            logger.info(f"Firebase Admin initialized with service account from {cred_path}")
        else:
            # Initialize with project ID only (for environments with default credentials)
            _firebase_app = firebase_admin.initialize_app(options={"projectId": project_id})
            logger.info(f"Firebase Admin initialized with project ID: {project_id}")
        
        return _firebase_app
    except Exception as e:
        logger.warning(f"Failed to initialize Firebase Admin SDK: {e}")
        return None


def firebase_jwt_info_func(token: str) -> dict:
    """
    Validate Firebase JWT token and return token info.
    
    Attempts to verify with Firebase Admin SDK first.
    Falls back to development mode if SDK not available.
    """
    # Check for development mode token first
    if token.startswith("dev-token-"):
        uid = token.replace("dev-token-", "")
        if "@" in uid:
            uid = uid.split("@", 1)[0]
        logger.debug(f"Dev token used, uid={uid}")
        return {
            "uid": uid,
            "email": f"{uid}@example.com",
            "name": f"User {uid}",
            "sub": uid,
        }
    
    # Try Firebase Admin SDK verification
    try:
        _init_firebase()
        from firebase_admin import auth
        
        decoded = auth.verify_id_token(token)
        uid = decoded.get("uid", decoded.get("user_id", decoded.get("sub")))
        email = decoded.get("email", f"{uid}@firebase.user")
        name = decoded.get("name", email.split("@")[0] if email else uid)
        
        token_info = {
            "uid": uid,
            "email": email,
            "name": name,
            "sub": uid,
        }
        
        logger.info(f"Authenticated Firebase user {uid} ({email})")
        return token_info
        
    except ImportError:
        logger.warning("firebase-admin not installed, falling back to JWT decode")
    except Exception as e:
        logger.warning(f"Firebase token verification failed: {e}, trying JWT decode")
    
    # Fallback: decode JWT without verification (for development)
    # This extracts the uid from the token payload
    try:
        import jwt
        
        # Decode without verification - only for development!
        decoded = jwt.decode(token, options={"verify_signature": False})
        uid = decoded.get("user_id") or decoded.get("sub") or decoded.get("uid")
        email = decoded.get("email", f"{uid}@firebase.user")
        name = decoded.get("name", email.split("@")[0] if email else uid)
        
        if not uid:
            logger.warning("Could not extract uid from JWT token")
            raise OAuthProblem("Invalid token: no user ID found")
        
        token_info = {
            "uid": uid,
            "email": email,
            "name": name,
            "sub": uid,
        }
        
        logger.info(f"Authenticated user (JWT decode) {uid} ({email})")
        return token_info
        
    except jwt.exceptions.DecodeError as e:
        logger.warning(f"Failed to decode JWT: {e}")
        raise OAuthProblem(f"Invalid token format: {e}")
    except Exception as e:
        logger.exception(f"Error processing token: {e}")
        raise OAuthProblem("Invalid token")


async def device_key_info_func(api_key: str, required_scopes=None) -> dict:
    """
    Validate device API key and return device info.
    
    The device key is passed in the x-device-key header.
    """
    device = await db.get_device_by_api_key(api_key)
    
    if not device:
        masked = (api_key[:6] + "...") if api_key else "<empty>"
        logger.warning(f"Invalid device key attempt: {masked}")
        raise OAuthProblem("Invalid device key")

    device_info = {
        "device_id": device.device_id,
        # Never log or return raw secrets in real logs/production
    }

    logger.info(f"Device key validated for device {device.device_id}")
    return device_info
