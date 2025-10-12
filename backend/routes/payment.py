from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.payment import Payment
from models.user import User
from models.task import Task
from utils.db import db
from utils.role_checker import role_required
from datetime import datetime

payment_bp = Blueprint('payment', __name__)

@payment_bp.route('/payments', methods=['GET'])
@jwt_required()
def get_payments():
    """Get payments (filtered by role)"""
    try:
        user_id = int(get_jwt_identity())
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'status': 'error',
                'message': 'User not found'
            }), 404
        
        # Admin sees all payments
        if user.role == 'admin':
            payments = Payment.query.all()
        # Workers see only their own
        elif user.role == 'worker':
            payments = Payment.query.filter_by(worker_id=user_id).all()
        else:
            payments = []
        
        return jsonify({
            'status': 'success',
            'payments': [payment.to_dict() for payment in payments]
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@payment_bp.route('/payments/<int:payment_id>', methods=['GET'])
@jwt_required()
def get_payment(payment_id):
    """Get a specific payment"""
    try:
        user_id = int(get_jwt_identity())
        user = User.query.get(user_id)
        payment = Payment.query.get(payment_id)
        
        if not payment:
            return jsonify({
                'status': 'error',
                'message': 'Payment not found'
            }), 404
        
        # Check permissions
        if user.role not in ['admin'] and payment.worker_id != user_id:
            return jsonify({
                'status': 'error',
                'message': 'Access denied'
            }), 403
        
        return jsonify({
            'status': 'success',
            'payment': payment.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@payment_bp.route('/payments', methods=['POST'])
@jwt_required()
@role_required('admin')
def create_payment():
    """Create a new payment record (admin only)"""
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['worker_id', 'amount']
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'status': 'error',
                    'message': f'Missing required field: {field}'
                }), 400
        
        # Verify worker exists
        worker = User.query.get(data['worker_id'])
        if not worker or worker.role != 'worker':
            return jsonify({
                'status': 'error',
                'message': 'Invalid worker ID'
            }), 404
        
        # Verify task if provided
        if 'task_id' in data and data['task_id']:
            task = Task.query.get(data['task_id'])
            if not task:
                return jsonify({
                    'status': 'error',
                    'message': 'Invalid task ID'
                }), 404
        
        # Create payment
        payment = Payment(
            worker_id=data['worker_id'],
            task_id=data.get('task_id'),
            amount=float(data['amount']),
            status='unpaid'
        )
        
        db.session.add(payment)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Payment record created successfully',
            'payment': payment.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@payment_bp.route('/payments/<int:payment_id>', methods=['PUT'])
@jwt_required()
@role_required('admin')
def update_payment(payment_id):
    """Update payment status (admin only)"""
    try:
        payment = Payment.query.get(payment_id)
        
        if not payment:
            return jsonify({
                'status': 'error',
                'message': 'Payment not found'
            }), 404
        
        data = request.get_json()
        
        if 'status' in data:
            valid_statuses = ['unpaid', 'paid']
            if data['status'] not in valid_statuses:
                return jsonify({
                    'status': 'error',
                    'message': f'Invalid status. Must be one of: {", ".join(valid_statuses)}'
                }), 400
            
            payment.status = data['status']
            
            # Set paid_at when marked as paid
            if data['status'] == 'paid':
                payment.paid_at = datetime.utcnow()
        
        if 'amount' in data:
            payment.amount = float(data['amount'])
        
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': f'Payment marked as {payment.status}',
            'payment': payment.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@payment_bp.route('/payments/<int:payment_id>', methods=['DELETE'])
@jwt_required()
@role_required('admin')
def delete_payment(payment_id):
    """Delete a payment record (admin only)"""
    try:
        payment = Payment.query.get(payment_id)
        
        if not payment:
            return jsonify({
                'status': 'error',
                'message': 'Payment not found'
            }), 404
        
        db.session.delete(payment)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Payment record deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500
