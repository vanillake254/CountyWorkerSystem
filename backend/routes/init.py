from flask import Blueprint, jsonify
from utils.db import db
from models.user import User
from models.department import Department
from models.job import Job
from datetime import datetime

init_bp = Blueprint('init', __name__)

@init_bp.route('/initialize-database', methods=['POST'])
def initialize_database():
    """One-time endpoint to initialize database with test data"""
    try:
        # Check if admin already exists
        existing_admin = User.query.filter_by(email='hr@county.go.ke').first()
        if existing_admin:
            return jsonify({
                'status': 'error',
                'message': 'Database already initialized'
            }), 400

        # Create departments
        departments = [
            Department(name='Human Resources', description='HR Department'),
            Department(name='Sanitation', description='Sanitation and Waste Management'),
            Department(name='Public Works', description='Infrastructure and Public Works'),
            Department(name='Health Services', description='County Health Services')
        ]
        
        for dept in departments:
            db.session.add(dept)
        
        db.session.flush()  # Get department IDs

        # Create users
        users_data = [
            {
                'full_name': 'Admin User',
                'email': 'hr@county.go.ke',
                'password': 'password',
                'role': 'admin',
                'department_id': departments[0].id
            },
            {
                'full_name': 'John Supervisor',
                'email': 'sup@county.go.ke',
                'password': 'password',
                'role': 'supervisor',
                'department_id': departments[1].id
            },
            {
                'full_name': 'Peter Worker',
                'email': 'worker@county.go.ke',
                'password': 'password',
                'role': 'worker',
                'department_id': departments[1].id
            },
            {
                'full_name': 'Jane Applicant',
                'email': 'applicant@county.go.ke',
                'password': 'password',
                'role': 'applicant',
                'department_id': None
            }
        ]

        for user_data in users_data:
            user = User(
                full_name=user_data['full_name'],
                email=user_data['email'],
                role=user_data['role'],
                department_id=user_data['department_id']
            )
            user.set_password(user_data['password'])
            db.session.add(user)

        # Create sample jobs
        jobs_data = [
            {
                'title': 'Sanitation Worker',
                'description': 'Responsible for waste collection and street cleaning',
                'department_id': departments[1].id,
                'requirements': 'Physical fitness, ability to work outdoors',
                'salary': 25000.00,
                'status': 'open'
            },
            {
                'title': 'Road Maintenance Worker',
                'description': 'Maintain and repair county roads',
                'department_id': departments[2].id,
                'requirements': 'Experience in construction or road work',
                'salary': 30000.00,
                'status': 'open'
            }
        ]

        for job_data in jobs_data:
            job = Job(**job_data)
            db.session.add(job)

        db.session.commit()

        return jsonify({
            'status': 'success',
            'message': 'Database initialized successfully',
            'credentials': {
                'admin': {'email': 'hr@county.go.ke', 'password': 'password'},
                'supervisor': {'email': 'sup@county.go.ke', 'password': 'password'},
                'worker': {'email': 'worker@county.go.ke', 'password': 'password'},
                'applicant': {'email': 'applicant@county.go.ke', 'password': 'password'}
            }
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': f'Failed to initialize database: {str(e)}'
        }), 500
