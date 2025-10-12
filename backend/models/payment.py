from utils.db import db
from datetime import datetime

class Payment(db.Model):
    __tablename__ = 'payments'
    
    id = db.Column(db.Integer, primary_key=True)
    worker_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    task_id = db.Column(db.Integer, db.ForeignKey('tasks.id'), nullable=True)
    amount = db.Column(db.Float, nullable=False)
    status = db.Column(db.String(20), nullable=False, default='unpaid')  # unpaid, paid
    date = db.Column(db.DateTime, default=datetime.utcnow)
    paid_at = db.Column(db.DateTime, nullable=True)
    
    def to_dict(self):
        """Convert payment to dictionary"""
        return {
            'id': self.id,
            'worker_id': self.worker_id,
            'worker_name': self.worker.full_name if self.worker else None,
            'task_id': self.task_id,
            'task_title': self.task.title if self.task else None,
            'amount': self.amount,
            'status': self.status,
            'date': self.date.isoformat(),
            'paid_at': self.paid_at.isoformat() if self.paid_at else None
        }
    
    def __repr__(self):
        return f'<Payment {self.id} - {self.status}>'
