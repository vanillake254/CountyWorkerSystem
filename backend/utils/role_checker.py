from functools import wraps
from flask import jsonify
from flask_jwt_extended import get_jwt_identity, verify_jwt_in_request
from models.user import User

def role_required(*allowed_roles):
    """Decorator to check if user has required role"""
    def decorator(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            verify_jwt_in_request()
            user_id = int(get_jwt_identity())  # Convert string to int
            user = User.query.get(user_id)
            
            if not user:
                return jsonify({
                    'status': 'error',
                    'message': 'User not found'
                }), 404
            
            if user.role not in allowed_roles:
                return jsonify({
                    'status': 'error',
                    'message': 'Access denied. Insufficient permissions.'
                }), 403
            
            return fn(*args, **kwargs)
        return wrapper
    return decorator
