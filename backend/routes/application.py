from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.application import Application
from models.job import Job
from models.user import User
from utils.db import db
from utils.role_checker import role_required
from datetime import datetime

application_bp = Blueprint('application', __name__)

@application_bp.route('/applications', methods=['GET'])
@jwt_required()
def get_applications():
    """Get applications (filtered by role)"""
    try:
        user_id = int(get_jwt_identity())
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'status': 'error',
                'message': 'User not found'
            }), 404
        
        # Admin sees all applications
        if user.role == 'admin':
            applications = Application.query.all()
        # Applicants see only their own
        else:
            applications = Application.query.filter_by(applicant_id=user_id).all()
        
        return jsonify({
            'status': 'success',
            'applications': [app.to_dict() for app in applications]
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@application_bp.route('/applications', methods=['POST'])
@jwt_required()
def create_application():
    """Apply for a job"""
    try:
        user_id = int(get_jwt_identity())
        data = request.get_json()
        
        # Validate required fields
        if 'job_id' not in data:
            return jsonify({
                'status': 'error',
                'message': 'Job ID is required'
            }), 400
        
        # Check if job exists and is open
        job = Job.query.get(data['job_id'])
        if not job:
            return jsonify({
                'status': 'error',
                'message': 'Job not found'
            }), 404
        
        if job.status != 'open':
            return jsonify({
                'status': 'error',
                'message': 'This job is no longer accepting applications'
            }), 400
        
        # Check if user already applied
        existing = Application.query.filter_by(
            applicant_id=user_id,
            job_id=data['job_id']
        ).first()
        
        if existing:
            return jsonify({
                'status': 'error',
                'message': 'You have already applied for this job'
            }), 400
        
        # Create application
        application = Application(
            applicant_id=user_id,
            job_id=data['job_id'],
            status='pending'
        )
        
        db.session.add(application)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Application submitted successfully',
            'application': application.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@application_bp.route('/applications/<int:application_id>', methods=['PUT'])
@jwt_required()
@role_required('admin')
def update_application(application_id):
    """Update application status (admin only)"""
    try:
        application = Application.query.get(application_id)
        
        if not application:
            return jsonify({
                'status': 'error',
                'message': 'Application not found'
            }), 404
        
        data = request.get_json()
        
        if 'status' not in data:
            return jsonify({
                'status': 'error',
                'message': 'Status is required'
            }), 400
        
        # Validate status
        valid_statuses = ['pending', 'accepted', 'rejected']
        if data['status'] not in valid_statuses:
            return jsonify({
                'status': 'error',
                'message': f'Invalid status. Must be one of: {", ".join(valid_statuses)}'
            }), 400
        
        # Update application
        application.status = data['status']
        application.reviewed_at = datetime.utcnow()
        
        # If accepted, update user role to worker
        if data['status'] == 'accepted':
            applicant = User.query.get(application.applicant_id)
            if applicant:
                applicant.role = 'worker'
                # Assign to job's department
                job = Job.query.get(application.job_id)
                if job:
                    applicant.department_id = job.department_id
        
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': f'Application {data["status"]}',
            'application': application.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@application_bp.route('/applications/<int:application_id>', methods=['DELETE'])
@jwt_required()
def delete_application(application_id):
    """Delete/withdraw application"""
    try:
        user_id = int(get_jwt_identity())
        user = User.query.get(user_id)
        
        application = Application.query.get(application_id)
        
        if not application:
            return jsonify({
                'status': 'error',
                'message': 'Application not found'
            }), 404
        
        # Only applicant or admin can delete
        if user.role != 'admin' and application.applicant_id != user_id:
            return jsonify({
                'status': 'error',
                'message': 'Access denied'
            }), 403
        
        db.session.delete(application)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Application withdrawn successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500
