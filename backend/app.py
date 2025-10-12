from flask import Flask, jsonify
from flask_cors import CORS
from config import config
from utils.db import db, init_db
from utils.jwt_helper import jwt, init_jwt
import os

# Import routes
from routes.auth import auth_bp
from routes.job import job_bp
from routes.application import application_bp
from routes.task import task_bp
from routes.contract import contract_bp
from routes.payment import payment_bp
from routes.department import department_bp
from routes.user import user_bp

def create_app(config_name='development'):
    """Application factory"""
    app = Flask(__name__)
    
    # Load configuration
    app.config.from_object(config[config_name])
    
    # Initialize extensions
    CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)
    init_db(app)
    init_jwt(app)
    
    # Create upload folder if it doesn't exist
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    
    # Register blueprints
    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(job_bp, url_prefix='/api')
    app.register_blueprint(application_bp, url_prefix='/api')
    app.register_blueprint(task_bp, url_prefix='/api')
    app.register_blueprint(contract_bp, url_prefix='/api')
    app.register_blueprint(payment_bp, url_prefix='/api')
    app.register_blueprint(department_bp, url_prefix='/api')
    app.register_blueprint(user_bp, url_prefix='/api')
    
    # Health check endpoint
    @app.route('/')
    def index():
        return jsonify({
            'status': 'success',
            'message': 'County Worker Platform API',
            'version': '1.0.0',
            'developer': 'Kelvin Barasa (DSE-01-8475-2023)'
        }), 200
    
    @app.route('/health')
    def health():
        return jsonify({
            'status': 'healthy',
            'database': 'connected'
        }), 200
    
    # Error handlers
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({
            'status': 'error',
            'message': 'Resource not found'
        }), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': 'Internal server error'
        }), 500
    
    return app

if __name__ == '__main__':
    # Use production config if FLASK_ENV is production
    config_name = os.getenv('FLASK_ENV', 'development')
    app = create_app(config_name)
    
    # Get port from environment variable (Railway sets PORT)
    port = int(os.getenv('PORT', 5000))
    app.run(debug=(config_name == 'development'), host='0.0.0.0', port=port)

# For gunicorn - ensure we use a valid config name
config_name = os.getenv('FLASK_ENV', 'production')
if config_name not in ['development', 'production']:
    config_name = 'production'
app = create_app(config_name)
