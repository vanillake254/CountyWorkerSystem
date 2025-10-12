from utils.db import db
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    full_name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), nullable=False, default='applicant')  # applicant, worker, supervisor, admin
    department_id = db.Column(db.Integer, db.ForeignKey('departments.id'), nullable=True)
    salary = db.Column(db.Float, nullable=True)  # Monthly salary assigned by admin
    salary_balance = db.Column(db.Float, nullable=True, default=0.0)  # Remaining unpaid salary
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    department = db.relationship('Department', foreign_keys=[department_id], backref='members')
    applications = db.relationship('Application', backref='applicant', lazy=True, cascade='all, delete-orphan')
    assigned_tasks = db.relationship('Task', foreign_keys='Task.assigned_to', backref='worker', lazy=True)
    supervised_tasks = db.relationship('Task', foreign_keys='Task.supervisor_id', backref='supervisor', lazy=True)
    contracts = db.relationship('Contract', foreign_keys='Contract.worker_id', backref='worker', lazy=True, cascade='all, delete-orphan')
    payments = db.relationship('Payment', foreign_keys='Payment.worker_id', backref='worker', lazy=True, cascade='all, delete-orphan')
    
    def set_password(self, password):
        """Hash and set password"""
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        """Check if password matches hash"""
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self):
        """Convert user to dictionary"""
        return {
            'id': self.id,
            'full_name': self.full_name,
            'email': self.email,
            'role': self.role,
            'department_id': self.department_id,
            'department_name': self.department.name if self.department else None,
            'salary': self.salary,
            'salary_balance': self.salary_balance,
            'created_at': self.created_at.isoformat()
        }
    
    def __repr__(self):
        return f'<User {self.email} - {self.role}>'
