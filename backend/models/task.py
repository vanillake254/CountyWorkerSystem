from utils.db import db
from datetime import datetime

class Task(db.Model):
    __tablename__ = 'tasks'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=False)
    assigned_to = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    supervisor_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    progress_status = db.Column(db.String(20), nullable=False, default='incomplete')  # incomplete, completed, approved, denied
    start_date = db.Column(db.DateTime, nullable=False)
    end_date = db.Column(db.DateTime, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    completed_at = db.Column(db.DateTime, nullable=True)
    approved_at = db.Column(db.DateTime, nullable=True)
    supervisor_comment = db.Column(db.Text, nullable=True)  # Comment when approving/denying
    
    # Relationships
    payments = db.relationship('Payment', backref='task', lazy=True)
    
    def to_dict(self):
        """Convert task to dictionary"""
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'assigned_to': self.assigned_to,
            'worker_name': self.worker.full_name if self.worker else None,
            'supervisor_id': self.supervisor_id,
            'supervisor_name': self.supervisor.full_name if self.supervisor else None,
            'progress_status': self.progress_status,
            'start_date': self.start_date.isoformat(),
            'end_date': self.end_date.isoformat(),
            'created_at': self.created_at.isoformat(),
            'completed_at': self.completed_at.isoformat() if self.completed_at else None,
            'approved_at': self.approved_at.isoformat() if self.approved_at else None,
            'supervisor_comment': self.supervisor_comment
        }
    
    def __repr__(self):
        return f'<Task {self.title} - {self.progress_status}>'
