from utils.db import db
from datetime import datetime

class Job(db.Model):
    __tablename__ = 'jobs'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=False)
    department_id = db.Column(db.Integer, db.ForeignKey('departments.id'), nullable=False)
    status = db.Column(db.String(20), nullable=False, default='open')  # open, closed
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    applications = db.relationship('Application', backref='job', lazy=True, cascade='all, delete-orphan')
    
    def to_dict(self):
        """Convert job to dictionary"""
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'department_id': self.department_id,
            'department_name': self.department.name if self.department else None,
            'status': self.status,
            'created_at': self.created_at.isoformat(),
            'applications_count': len(self.applications)
        }
    
    def __repr__(self):
        return f'<Job {self.title} - {self.status}>'
