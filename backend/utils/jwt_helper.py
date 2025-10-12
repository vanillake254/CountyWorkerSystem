from flask_jwt_extended import JWTManager
from functools import wraps
from flask_jwt_extended import get_jwt_identity, verify_jwt_in_request
from flask import jsonify

jwt = JWTManager()

def init_jwt(app):
    """Initialize JWT with Flask app"""
    jwt.init_app(app)
    
    @jwt.expired_token_loader
    def expired_token_callback(jwt_header, jwt_payload):
        return jsonify({
            'status': 'error',
            'message': 'Token has expired'
        }), 401
    
    @jwt.invalid_token_loader
    def invalid_token_callback(error):
        print(f"❌ Invalid token error: {error}")
        return jsonify({
            'status': 'error',
            'message': f'Invalid token: {str(error)}'
        }), 401
    
    @jwt.unauthorized_loader
    def missing_token_callback(error):
        return jsonify({
            'status': 'error',
            'message': 'Authorization token is missing'
        }), 401
