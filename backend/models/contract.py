from utils.db import db
from datetime import datetime

class Contract(db.Model):
    __tablename__ = 'contracts'
    
    id = db.Column(db.Integer, primary_key=True)
    worker_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    file_url = db.Column(db.String(500), nullable=True)
    start_date = db.Column(db.DateTime, nullable=False)
    end_date = db.Column(db.DateTime, nullable=False)
    approved_by = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    approver = db.relationship('User', foreign_keys=[approved_by], backref='approved_contracts')
    
    def to_dict(self):
        """Convert contract to dictionary"""
        return {
            'id': self.id,
            'worker_id': self.worker_id,
            'worker_name': self.worker.full_name if self.worker else None,
            'file_url': self.file_url,
            'start_date': self.start_date.isoformat(),
            'end_date': self.end_date.isoformat(),
            'approved_by': self.approved_by,
            'approver_name': self.approver.full_name if self.approver else None,
            'created_at': self.created_at.isoformat()
        }
    
    def __repr__(self):
        return f'<Contract {self.id} - Worker {self.worker_id}>'
