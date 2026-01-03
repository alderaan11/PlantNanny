"""Security handlers for authentication."""
import logging
from connexion.exceptions import OAuthProblem

from storage import device_keys

# Logger for security events (do not log secrets in full)
logger = logging.getLogger("plant_nanny.security")
if not logger.handlers:
    handler = logging.StreamHandler()
    formatter = logging.Formatter("%(asctime)s %(levelname)s %(name)s %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
logger.setLevel(logging.INFO)


def firebase_jwt_info_func(token: str) -> dict:
    """
    Validate Firebase JWT token and return token info.
    
    In production, this should verify the token with Firebase Admin SDK:
    - Verify signature
    - Check expiration
    - Extract user claims
    
    For development, we accept tokens and extract minimal info.
    """
    # TODO: Implement real Firebase token validation
    # Example with firebase-admin:
    # from firebase_admin import auth
    # try:
    #     decoded = auth.verify_id_token(token)
    #     return decoded
    # except Exception as e:
    #     logger.exception("Error verifying firebase token")
    #     raise OAuthProblem(f"Invalid token: {e}")

    try:
        # Development mode: accept any token and create mock user info
        # Token format for dev: "dev-token-{uid}" or any bearer token
        if token.startswith("dev-token-"):
            uid = token.replace("dev-token-", "")
            # Normalize uid: allow users to sign in with full email (e.g. test-user@example.com)
            if "@" in uid:
                short_uid = uid.split("@", 1)[0]
                logger.debug(f"Dev token used, uid={uid} -> normalized {short_uid}")
                uid = short_uid
            else:
                logger.debug(f"Dev token used, uid={uid}")
        else:
            uid = "test-user"
            logger.debug("Non-dev token received, using default test user")

        token_info = {
            "uid": uid,
            "email": f"{uid}@example.com",
            "name": f"User {uid}",
            "sub": uid,
        }

        logger.info(f"Authenticated user {token_info['uid']} ({token_info['email']})")
        return token_info
    except Exception:
        logger.exception("Error processing token")
        raise OAuthProblem("Invalid token")


def device_key_info_func(api_key: str, required_scopes=None) -> dict:
    """
    Validate device API key and return device info.
    
    The device key is passed in the x-device-key header.
    """
    if api_key not in device_keys:
        masked = (api_key[:6] + "...") if api_key else "<empty>"
        logger.warning(f"Invalid device key attempt: {masked}")
        raise OAuthProblem("Invalid device key")

    device_id = device_keys[api_key]
    device_info = {
        "device_id": device_id,
        # Never log or return raw secrets in real logs/production
    }

    logger.info(f"Device key validated for device {device_id}")
    return device_info
