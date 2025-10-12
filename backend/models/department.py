from utils.db import db
from datetime import datetime

class Department(db.Model):
    __tablename__ = 'departments'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    supervisor_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    supervisor = db.relationship('User', foreign_keys=[supervisor_id], backref='supervised_department')
    jobs = db.relationship('Job', backref='department', lazy=True, cascade='all, delete-orphan')
    
    def to_dict(self):
        """Convert department to dictionary"""
        return {
            'id': self.id,
            'name': self.name,
            'supervisor_id': self.supervisor_id,
            'supervisor_name': self.supervisor.full_name if self.supervisor else None,
            'created_at': self.created_at.isoformat()
        }
    
    def __repr__(self):
        return f'<Department {self.name}>'
