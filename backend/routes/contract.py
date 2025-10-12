from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.contract import Contract
from models.user import User
from utils.db import db
from utils.role_checker import role_required
from datetime import datetime

contract_bp = Blueprint('contract', __name__)

@contract_bp.route('/contracts', methods=['GET'])
@jwt_required()
def get_contracts():
    """Get contracts (filtered by role)"""
    try:
        user_id = int(get_jwt_identity())
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({
                'status': 'error',
                'message': 'User not found'
            }), 404
        
        # Admin sees all contracts
        if user.role == 'admin':
            contracts = Contract.query.all()
        # Workers see only their own
        elif user.role == 'worker':
            contracts = Contract.query.filter_by(worker_id=user_id).all()
        else:
            contracts = []
        
        return jsonify({
            'status': 'success',
            'contracts': [contract.to_dict() for contract in contracts]
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@contract_bp.route('/contracts/<int:contract_id>', methods=['GET'])
@jwt_required()
def get_contract(contract_id):
    """Get a specific contract"""
    try:
        user_id = int(get_jwt_identity())
        user = User.query.get(user_id)
        contract = Contract.query.get(contract_id)
        
        if not contract:
            return jsonify({
                'status': 'error',
                'message': 'Contract not found'
            }), 404
        
        # Check permissions
        if user.role not in ['admin'] and contract.worker_id != user_id:
            return jsonify({
                'status': 'error',
                'message': 'Access denied'
            }), 403
        
        return jsonify({
            'status': 'success',
            'contract': contract.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@contract_bp.route('/contracts', methods=['POST'])
@jwt_required()
@role_required('admin')
def create_contract():
    """Create a new contract (admin only)"""
    try:
        user_id = int(get_jwt_identity())
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['worker_id', 'start_date', 'end_date']
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
        
        # Parse dates
        try:
            start_date = datetime.fromisoformat(data['start_date'].replace('Z', '+00:00'))
            end_date = datetime.fromisoformat(data['end_date'].replace('Z', '+00:00'))
        except ValueError:
            return jsonify({
                'status': 'error',
                'message': 'Invalid date format. Use ISO format (YYYY-MM-DDTHH:MM:SS)'
            }), 400
        
        # Create contract
        contract = Contract(
            worker_id=data['worker_id'],
            file_url=data.get('file_url'),
            start_date=start_date,
            end_date=end_date,
            approved_by=user_id
        )
        
        db.session.add(contract)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Contract created successfully',
            'contract': contract.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@contract_bp.route('/contracts/<int:contract_id>', methods=['PUT'])
@jwt_required()
@role_required('admin')
def update_contract(contract_id):
    """Update a contract (admin only)"""
    try:
        user_id = int(get_jwt_identity())
        contract = Contract.query.get(contract_id)
        
        if not contract:
            return jsonify({
                'status': 'error',
                'message': 'Contract not found'
            }), 404
        
        data = request.get_json()
        
        # Update fields
        if 'file_url' in data:
            contract.file_url = data['file_url']
        if 'start_date' in data:
            contract.start_date = datetime.fromisoformat(data['start_date'].replace('Z', '+00:00'))
        if 'end_date' in data:
            contract.end_date = datetime.fromisoformat(data['end_date'].replace('Z', '+00:00'))
        
        contract.approved_by = user_id
        
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Contract updated successfully',
            'contract': contract.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@contract_bp.route('/contracts/<int:contract_id>', methods=['DELETE'])
@jwt_required()
@role_required('admin')
def delete_contract(contract_id):
    """Delete a contract (admin only)"""
    try:
        contract = Contract.query.get(contract_id)
        
        if not contract:
            return jsonify({
                'status': 'error',
                'message': 'Contract not found'
            }), 404
        
        db.session.delete(contract)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Contract deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500
