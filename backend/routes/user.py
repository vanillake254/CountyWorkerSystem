from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.user import User
from utils.db import db
from utils.role_checker import role_required

user_bp = Blueprint('user', __name__)

@user_bp.route('/users', methods=['GET'])
@jwt_required()
@role_required('admin', 'supervisor')
def get_users():
    """Get all users (optionally filter by role)"""
    try:
        role = request.args.get('role')
        
        if role:
            users = User.query.filter_by(role=role).all()
        else:
            users = User.query.all()
        
        return jsonify({
            'status': 'success',
            'users': [user.to_dict() for user in users]
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@user_bp.route('/users/<int:user_id>', methods=['GET'])
@jwt_required()
def get_user(user_id):
    """Get a specific user"""
    try:
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'status': 'error',
                'message': 'User not found'
            }), 404
        
        return jsonify({
            'status': 'success',
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@user_bp.route('/users/<int:user_id>', methods=['PUT'])
@jwt_required()
@role_required('admin')
def update_user(user_id):
    """Update user (admin only)"""
    try:
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'status': 'error',
                'message': 'User not found'
            }), 404
        
        data = request.get_json()
        
        # Update fields
        if 'full_name' in data:
            user.full_name = data['full_name']
        if 'email' in data:
            # Check if email already exists
            existing = User.query.filter_by(email=data['email']).first()
            if existing and existing.id != user_id:
                return jsonify({
                    'status': 'error',
                    'message': 'Email already exists'
                }), 400
            user.email = data['email']
        if 'role' in data:
            valid_roles = ['applicant', 'worker', 'supervisor', 'admin']
            if data['role'] not in valid_roles:
                return jsonify({
                    'status': 'error',
                    'message': f'Invalid role. Must be one of: {", ".join(valid_roles)}'
                }), 400
            
            # If changing to supervisor, check if department already has a supervisor
            if data['role'] == 'supervisor' and user.department_id:
                existing_supervisor = User.query.filter_by(
                    role='supervisor',
                    department_id=user.department_id
                ).filter(User.id != user_id).first()
                
                if existing_supervisor:
                    return jsonify({
                        'status': 'error',
                        'message': f'Department already has a supervisor: {existing_supervisor.full_name}'
                    }), 400
            
            user.role = data['role']
        
        if 'department_id' in data:
            # If user is or will be a supervisor, check if new department already has one
            if user.role == 'supervisor' or (data.get('role') == 'supervisor'):
                # Check if this supervisor already has a different department
                if user.role == 'supervisor' and user.department_id and user.department_id != data['department_id']:
                    return jsonify({
                        'status': 'error',
                        'message': 'A supervisor can only be assigned to one department. Please remove from current department first.'
                    }), 400
                
                existing_supervisor = User.query.filter_by(
                    role='supervisor',
                    department_id=data['department_id']
                ).filter(User.id != user_id).first()
                
                if existing_supervisor:
                    return jsonify({
                        'status': 'error',
                        'message': f'Department already has a supervisor: {existing_supervisor.full_name}'
                    }), 400
            
            user.department_id = data['department_id']
        
        if 'salary' in data:
            user.salary = float(data['salary'])
        
        if 'password' in data:
            # Admin can reset user password without old password
            from werkzeug.security import generate_password_hash
            user.password = generate_password_hash(data['password'])
        
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'User updated successfully',
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@user_bp.route('/users/<int:user_id>', methods=['DELETE'])
@jwt_required()
@role_required('admin')
def delete_user(user_id):
    """Delete user (admin only)"""
    try:
        current_user_id = int(get_jwt_identity())
        
        # Prevent admin from deleting themselves
        if current_user_id == user_id:
            return jsonify({
                'status': 'error',
                'message': 'Cannot delete your own account'
            }), 400
        
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'status': 'error',
                'message': 'User not found'
            }), 404
        
        db.session.delete(user)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': f'User {user.full_name} deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@user_bp.route('/users/change-password', methods=['PUT'])
@jwt_required()
def change_password():
    """Change current user's password"""
    try:
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({
                'status': 'error',
                'message': 'User not found'
            }), 404
        
        data = request.get_json()
        
        if not data.get('current_password') or not data.get('new_password'):
            return jsonify({
                'status': 'error',
                'message': 'Current password and new password are required'
            }), 400
        
        # Verify current password
        if not user.check_password(data['current_password']):
            return jsonify({
                'status': 'error',
                'message': 'Current password is incorrect'
            }), 400
        
        # Validate new password
        if len(data['new_password']) < 6:
            return jsonify({
                'status': 'error',
                'message': 'New password must be at least 6 characters long'
            }), 400
        
        # Set new password
        user.set_password(data['new_password'])
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Password changed successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@user_bp.route('/users/<int:user_id>/reset-password', methods=['PUT'])
@jwt_required()
@role_required('admin')
def reset_user_password(user_id):
    """Admin reset user password (no old password required)"""
    try:
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'status': 'error',
                'message': 'User not found'
            }), 404
        
        data = request.get_json()
        
        if not data.get('new_password'):
            return jsonify({
                'status': 'error',
                'message': 'New password is required'
            }), 400
        
        # Validate new password
        if len(data['new_password']) < 6:
            return jsonify({
                'status': 'error',
                'message': 'New password must be at least 6 characters long'
            }), 400
        
        # Set new password
        user.set_password(data['new_password'])
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': f'Password reset successfully for {user.full_name}'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500
