from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.department import Department
from models.user import User
from utils.db import db
from utils.role_checker import role_required

department_bp = Blueprint('department', __name__)

@department_bp.route('/departments', methods=['GET'])
def get_departments():
    """Get all departments"""
    try:
        departments = Department.query.all()
        
        return jsonify({
            'status': 'success',
            'departments': [dept.to_dict() for dept in departments]
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@department_bp.route('/departments/<int:department_id>', methods=['GET'])
def get_department(department_id):
    """Get a specific department"""
    try:
        department = Department.query.get(department_id)
        
        if not department:
            return jsonify({
                'status': 'error',
                'message': 'Department not found'
            }), 404
        
        return jsonify({
            'status': 'success',
            'department': department.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@department_bp.route('/departments', methods=['POST'])
@jwt_required()
@role_required('admin')
def create_department():
    """Create a new department (admin only)"""
    try:
        data = request.get_json()
        
        # Validate required fields
        if 'name' not in data:
            return jsonify({
                'status': 'error',
                'message': 'Department name is required'
            }), 400
        
        # Check if department already exists
        if Department.query.filter_by(name=data['name']).first():
            return jsonify({
                'status': 'error',
                'message': 'Department already exists'
            }), 400
        
        # Verify supervisor if provided
        supervisor_id = data.get('supervisor_id')
        if supervisor_id:
            supervisor = User.query.get(supervisor_id)
            if not supervisor or supervisor.role != 'supervisor':
                return jsonify({
                    'status': 'error',
                    'message': 'Invalid supervisor ID'
                }), 404
            
            # Check if supervisor already has a department
            if supervisor.department_id:
                return jsonify({
                    'status': 'error',
                    'message': f'Supervisor {supervisor.full_name} is already assigned to another department'
                }), 400
        
        # Create department
        department = Department(
            name=data['name'],
            supervisor_id=supervisor_id
        )
        
        db.session.add(department)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Department created successfully',
            'department': department.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@department_bp.route('/departments/<int:department_id>', methods=['PUT'])
@jwt_required()
@role_required('admin')
def update_department(department_id):
    """Update a department (admin only)"""
    try:
        department = Department.query.get(department_id)
        
        if not department:
            return jsonify({
                'status': 'error',
                'message': 'Department not found'
            }), 404
        
        data = request.get_json()
        
        # Update name
        if 'name' in data:
            # Check if new name already exists
            existing = Department.query.filter_by(name=data['name']).first()
            if existing and existing.id != department_id:
                return jsonify({
                    'status': 'error',
                    'message': 'Department name already exists'
                }), 400
            department.name = data['name']
        
        # Update supervisor
        if 'supervisor_id' in data:
            if data['supervisor_id']:
                supervisor = User.query.get(data['supervisor_id'])
                if not supervisor or supervisor.role != 'supervisor':
                    return jsonify({
                        'status': 'error',
                        'message': 'Invalid supervisor ID'
                    }), 404
                
                # Check if supervisor already has a different department
                if supervisor.department_id and supervisor.department_id != department_id:
                    return jsonify({
                        'status': 'error',
                        'message': f'Supervisor {supervisor.full_name} is already assigned to another department'
                    }), 400
            department.supervisor_id = data['supervisor_id']
        
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Department updated successfully',
            'department': department.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@department_bp.route('/departments/<int:department_id>', methods=['DELETE'])
@jwt_required()
@role_required('admin')
def delete_department(department_id):
    """Delete a department (admin only)"""
    try:
        department = Department.query.get(department_id)
        
        if not department:
            return jsonify({
                'status': 'error',
                'message': 'Department not found'
            }), 404
        
        db.session.delete(department)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Department deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@department_bp.route('/departments/<int:department_id>/workers', methods=['GET'])
@jwt_required()
def get_department_workers(department_id):
    """Get all workers in a department"""
    try:
        department = Department.query.get(department_id)
        
        if not department:
            return jsonify({
                'status': 'error',
                'message': 'Department not found'
            }), 404
        
        workers = User.query.filter_by(department_id=department_id, role='worker').all()
        
        return jsonify({
            'status': 'success',
            'workers': [worker.to_dict() for worker in workers]
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500
