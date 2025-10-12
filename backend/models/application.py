from utils.db import db
from datetime import datetime

class Application(db.Model):
    __tablename__ = 'applications'
    
    id = db.Column(db.Integer, primary_key=True)
    applicant_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    job_id = db.Column(db.Integer, db.ForeignKey('jobs.id'), nullable=False)
    status = db.Column(db.String(20), nullable=False, default='pending')  # pending, accepted, rejected
    applied_at = db.Column(db.DateTime, default=datetime.utcnow)
    reviewed_at = db.Column(db.DateTime, nullable=True)
    
    def to_dict(self):
        """Convert application to dictionary"""
        return {
            'id': self.id,
            'applicant_id': self.applicant_id,
            'applicant_name': self.applicant.full_name if self.applicant else None,
            'applicant_email': self.applicant.email if self.applicant else None,
            'job_id': self.job_id,
            'job_title': self.job.title if self.job else None,
            'department': self.job.department.name if self.job and self.job.department else None,
            'status': self.status,
            'applied_at': self.applied_at.isoformat(),
            'reviewed_at': self.reviewed_at.isoformat() if self.reviewed_at else None
        }
    
    def __repr__(self):
        return f'<Application {self.id} - {self.status}>'
