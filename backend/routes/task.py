from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.task import Task
from models.user import User
from utils.db import db
from utils.role_checker import role_required
from datetime import datetime

task_bp = Blueprint('task', __name__)

@task_bp.route('/tasks', methods=['GET'])
@jwt_required()
def get_tasks():
    """Get tasks (filtered by role)"""
    try:
        user_id = int(get_jwt_identity())
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'status': 'error',
                'message': 'User not found'
            }), 404
        
        # Admin sees all tasks
        if user.role == 'admin':
            tasks = Task.query.all()
        # Supervisor sees tasks they supervise
        elif user.role == 'supervisor':
            tasks = Task.query.filter_by(supervisor_id=user_id).all()
        # Worker sees tasks assigned to them
        elif user.role == 'worker':
            tasks = Task.query.filter_by(assigned_to=user_id).all()
        else:
            tasks = []
        
        return jsonify({
            'status': 'success',
            'tasks': [task.to_dict() for task in tasks]
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@task_bp.route('/tasks/<int:task_id>', methods=['GET'])
@jwt_required()
def get_task(task_id):
    """Get a specific task"""
    try:
        task = Task.query.get(task_id)
        
        if not task:
            return jsonify({
                'status': 'error',
                'message': 'Task not found'
            }), 404
        
        return jsonify({
            'status': 'success',
            'task': task.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@task_bp.route('/tasks', methods=['POST'])
@jwt_required()
@role_required('supervisor', 'admin')
def create_task():
    """Create a new task (supervisor or admin)"""
    try:
        user_id = int(get_jwt_identity())
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['title', 'description', 'assigned_to', 'start_date', 'end_date']
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'status': 'error',
                    'message': f'Missing required field: {field}'
                }), 400
        
        # Verify worker exists and has worker role
        worker = User.query.get(data['assigned_to'])
        if not worker or worker.role != 'worker':
            return jsonify({
                'status': 'error',
                'message': 'Invalid worker ID'
            }), 404
        
        # Parse dates
        try:
            start_date = datetime.fromisoformat(data['start_date'].replace('Z', '+00:00'))
            end_date = datetime.fromisoformat(data['end_date'].replace('Z', '+00:00'))
        except ValueError:
            return jsonify({
                'status': 'error',
                'message': 'Invalid date format. Use ISO format (YYYY-MM-DDTHH:MM:SS)'
            }), 400
        
        # Create task
        task = Task(
            title=data['title'],
            description=data['description'],
            assigned_to=data['assigned_to'],
            supervisor_id=user_id,
            start_date=start_date,
            end_date=end_date,
            progress_status='pending'
        )
        
        db.session.add(task)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Task created successfully',
            'task': task.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@task_bp.route('/tasks/<int:task_id>', methods=['PUT'])
@jwt_required()
def update_task(task_id):
    """Update task progress"""
    try:
        user_id = int(get_jwt_identity())
        user = User.query.get(user_id)
        task = Task.query.get(task_id)
        
        if not task:
            return jsonify({
                'status': 'error',
                'message': 'Task not found'
            }), 404
        
        # Check permissions (worker assigned to task, supervisor, or admin)
        if user.role not in ['admin', 'supervisor'] and task.assigned_to != user_id:
            return jsonify({
                'status': 'error',
                'message': 'Access denied'
            }), 403
        
        data = request.get_json()
        
        # Update progress status
        if 'progress_status' in data:
            valid_statuses = ['pending', 'in_progress', 'completed']
            if data['progress_status'] not in valid_statuses:
                return jsonify({
                    'status': 'error',
                    'message': f'Invalid status. Must be one of: {", ".join(valid_statuses)}'
                }), 400
            
            task.progress_status = data['progress_status']
            
            # Set completed_at when task is completed
            if data['progress_status'] == 'completed':
                task.completed_at = datetime.utcnow()
        
        # Supervisors/admins can update other fields
        if user.role in ['admin', 'supervisor']:
            if 'title' in data:
                task.title = data['title']
            if 'description' in data:
                task.description = data['description']
            if 'start_date' in data:
                task.start_date = datetime.fromisoformat(data['start_date'].replace('Z', '+00:00'))
            if 'end_date' in data:
                task.end_date = datetime.fromisoformat(data['end_date'].replace('Z', '+00:00'))
        
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': f'Task progress updated to {task.progress_status}',
            'task': task.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@task_bp.route('/tasks/<int:task_id>', methods=['DELETE'])
@jwt_required()
@role_required('supervisor', 'admin')
def delete_task(task_id):
    """Delete a task (supervisor or admin)"""
    try:
        task = Task.query.get(task_id)
        
        if not task:
            return jsonify({
                'status': 'error',
                'message': 'Task not found'
            }), 404
        
        db.session.delete(task)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Task deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500
