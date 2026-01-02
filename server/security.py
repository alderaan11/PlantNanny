"""Security handlers for authentication."""
from connexion.exceptions import OAuthProblem

from storage import device_keys


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
    #     raise OAuthProblem(f"Invalid token: {e}")
    
    # Development mode: accept any token and create mock user info
    # Token format for dev: "dev-token-{uid}" or any bearer token
    if token.startswith("dev-token-"):
        uid = token.replace("dev-token-", "")
    else:
        uid = "test-user"
    
    token_info = {
        "uid": uid,
        "email": f"{uid}@example.com",
        "name": f"User {uid}",
        "sub": uid,
    }
    
    return token_info


def device_key_info_func(api_key: str, required_scopes=None) -> dict:
    """
    Validate device API key and return device info.
    
    The device key is passed in the x-device-key header.
    """
    if api_key not in device_keys:
        raise OAuthProblem("Invalid device key")
    
    device_id = device_keys[api_key]
    device_info = {
        "device_id": device_id,
        "api_key": api_key,
    }
    
    return device_info
