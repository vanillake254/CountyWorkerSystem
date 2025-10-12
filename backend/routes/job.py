from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.job import Job
from models.department import Department
from utils.db import db
from utils.role_checker import role_required

job_bp = Blueprint('job', __name__)

@job_bp.route('/jobs', methods=['GET'])
def get_jobs():
    """Get all jobs (optionally filter by status)"""
    try:
        status = request.args.get('status', 'open')
        
        if status == 'all':
            jobs = Job.query.all()
        else:
            jobs = Job.query.filter_by(status=status).all()
        
        return jsonify({
            'status': 'success',
            'jobs': [job.to_dict() for job in jobs]
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@job_bp.route('/jobs/<int:job_id>', methods=['GET'])
def get_job(job_id):
    """Get a specific job"""
    try:
        job = Job.query.get(job_id)
        
        if not job:
            return jsonify({
                'status': 'error',
                'message': 'Job not found'
            }), 404
        
        return jsonify({
            'status': 'success',
            'job': job.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@job_bp.route('/jobs', methods=['POST'])
@jwt_required()
@role_required('admin')
def create_job():
    """Create a new job (admin only)"""
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['title', 'description', 'department_id']
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'status': 'error',
                    'message': f'Missing required field: {field}'
                }), 400
        
        # Verify department exists
        department = Department.query.get(data['department_id'])
        if not department:
            return jsonify({
                'status': 'error',
                'message': 'Department not found'
            }), 404
        
        # Create job
        job = Job(
            title=data['title'],
            description=data['description'],
            department_id=data['department_id'],
            status=data.get('status', 'open')
        )
        
        db.session.add(job)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Job created successfully',
            'job': job.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@job_bp.route('/jobs/<int:job_id>', methods=['PUT'])
@jwt_required()
@role_required('admin')
def update_job(job_id):
    """Update a job (admin only)"""
    try:
        job = Job.query.get(job_id)
        
        if not job:
            return jsonify({
                'status': 'error',
                'message': 'Job not found'
            }), 404
        
        data = request.get_json()
        
        # Update fields
        if 'title' in data:
            job.title = data['title']
        if 'description' in data:
            job.description = data['description']
        if 'status' in data:
            job.status = data['status']
        if 'department_id' in data:
            department = Department.query.get(data['department_id'])
            if not department:
                return jsonify({
                    'status': 'error',
                    'message': 'Department not found'
                }), 404
            job.department_id = data['department_id']
        
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Job updated successfully',
            'job': job.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@job_bp.route('/jobs/<int:job_id>', methods=['DELETE'])
@jwt_required()
@role_required('admin')
def delete_job(job_id):
    """Delete a job (admin only)"""
    try:
        job = Job.query.get(job_id)
        
        if not job:
            return jsonify({
                'status': 'error',
                'message': 'Job not found'
            }), 404
        
        db.session.delete(job)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Job deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500
