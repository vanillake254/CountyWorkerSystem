"""
Seed script to populate database with sample data
Run this after creating the database: python seed.py
"""
from app import create_app
from utils.db import db
from models.user import User
from models.department import Department
from models.job import Job
from models.application import Application
from models.task import Task
from models.contract import Contract
from models.payment import Payment
from datetime import datetime, timedelta

def seed_database():
    """Populate database with sample data"""
    app = create_app()
    
    with app.app_context():
        # Clear existing data
        print("Clearing existing data...")
        db.drop_all()
        db.create_all()
        
        # Create departments
        print("Creating departments...")
        departments = [
            Department(name='Sanitation'),
            Department(name='Water & Infrastructure'),
            Department(name='Administration'),
            Department(name='Health Services'),
            Department(name='Public Works')
        ]
        
        for dept in departments:
            db.session.add(dept)
        db.session.commit()
        
        # Create users
        print("Creating users...")
        
        # Admin
        admin = User(
            full_name='HR Administrator',
            email='hr@county.go.ke',
            role='admin'
        )
        admin.set_password('password')
        db.session.add(admin)
        
        # Supervisors
        supervisor1 = User(
            full_name='John Supervisor',
            email='sup@county.go.ke',
            role='supervisor',
            department_id=1  # Sanitation
        )
        supervisor1.set_password('password')
        db.session.add(supervisor1)
        
        supervisor2 = User(
            full_name='Mary Supervisor',
            email='sup2@county.go.ke',
            role='supervisor',
            department_id=2  # Water & Infrastructure
        )
        supervisor2.set_password('password')
        db.session.add(supervisor2)
        
        # Workers
        worker1 = User(
            full_name='Peter Worker',
            email='worker@county.go.ke',
            role='worker',
            department_id=1
        )
        worker1.set_password('password')
        db.session.add(worker1)
        
        worker2 = User(
            full_name='Jane Worker',
            email='worker2@county.go.ke',
            role='worker',
            department_id=2
        )
        worker2.set_password('password')
        db.session.add(worker2)
        
        # Applicants
        applicant1 = User(
            full_name='David Applicant',
            email='applicant@county.go.ke',
            role='applicant'
        )
        applicant1.set_password('password')
        db.session.add(applicant1)
        
        applicant2 = User(
            full_name='Sarah Applicant',
            email='applicant2@county.go.ke',
            role='applicant'
        )
        applicant2.set_password('password')
        db.session.add(applicant2)
        
        db.session.commit()
        
        # Update departments with supervisors
        print("Assigning supervisors to departments...")
        departments[0].supervisor_id = supervisor1.id
        departments[1].supervisor_id = supervisor2.id
        db.session.commit()
        
        # Create jobs
        print("Creating jobs...")
        jobs = [
            Job(
                title='Street Cleaning Officer',
                description='Responsible for cleaning designated street areas, collecting litter, and maintaining cleanliness standards.',
                department_id=1,
                status='open'
            ),
            Job(
                title='Water Pipeline Maintenance Assistant',
                description='Assist in maintaining water pipelines, detecting leaks, and performing minor repairs.',
                department_id=2,
                status='open'
            ),
            Job(
                title='Data Entry Clerk',
                description='Enter and manage county records, maintain databases, and generate reports.',
                department_id=3,
                status='open'
            ),
            Job(
                title='Waste Collection Driver',
                description='Drive waste collection vehicles and coordinate with collection teams.',
                department_id=1,
                status='closed'
            )
        ]
        
        for job in jobs:
            db.session.add(job)
        db.session.commit()
        
        # Create applications
        print("Creating applications...")
        applications = [
            Application(
                applicant_id=applicant1.id,
                job_id=1,
                status='pending'
            ),
            Application(
                applicant_id=applicant2.id,
                job_id=2,
                status='accepted',
                reviewed_at=datetime.utcnow()
            ),
            Application(
                applicant_id=applicant1.id,
                job_id=3,
                status='rejected',
                reviewed_at=datetime.utcnow()
            )
        ]
        
        for app in applications:
            db.session.add(app)
        db.session.commit()
        
        # Create tasks
        print("Creating tasks...")
        tasks = [
            Task(
                title='Clean Main Street Area',
                description='Clean and maintain Main Street from 1st Avenue to 5th Avenue',
                assigned_to=worker1.id,
                supervisor_id=supervisor1.id,
                progress_status='in_progress',
                start_date=datetime.utcnow(),
                end_date=datetime.utcnow() + timedelta(days=7)
            ),
            Task(
                title='Inspect Water Pipes - Zone A',
                description='Conduct thorough inspection of all water pipes in residential Zone A',
                assigned_to=worker2.id,
                supervisor_id=supervisor2.id,
                progress_status='completed',
                start_date=datetime.utcnow() - timedelta(days=14),
                end_date=datetime.utcnow() - timedelta(days=7),
                completed_at=datetime.utcnow() - timedelta(days=7)
            ),
            Task(
                title='Weekly Street Maintenance',
                description='Regular weekly maintenance of assigned street sections',
                assigned_to=worker1.id,
                supervisor_id=supervisor1.id,
                progress_status='pending',
                start_date=datetime.utcnow() + timedelta(days=1),
                end_date=datetime.utcnow() + timedelta(days=8)
            )
        ]
        
        for task in tasks:
            db.session.add(task)
        db.session.commit()
        
        # Create contracts
        print("Creating contracts...")
        contracts = [
            Contract(
                worker_id=worker1.id,
                file_url='/uploads/contracts/contract_worker1.pdf',
                start_date=datetime.utcnow(),
                end_date=datetime.utcnow() + timedelta(days=180),
                approved_by=admin.id
            ),
            Contract(
                worker_id=worker2.id,
                file_url='/uploads/contracts/contract_worker2.pdf',
                start_date=datetime.utcnow(),
                end_date=datetime.utcnow() + timedelta(days=180),
                approved_by=admin.id
            )
        ]
        
        for contract in contracts:
            db.session.add(contract)
        db.session.commit()
        
        # Create payments
        print("Creating payments...")
        payments = [
            Payment(
                worker_id=worker1.id,
                task_id=1,
                amount=5000.00,
                status='unpaid'
            ),
            Payment(
                worker_id=worker2.id,
                task_id=2,
                amount=7500.00,
                status='paid',
                paid_at=datetime.utcnow()
            ),
            Payment(
                worker_id=worker1.id,
                task_id=None,
                amount=3000.00,
                status='unpaid'
            )
        ]
        
        for payment in payments:
            db.session.add(payment)
        db.session.commit()
        
        print("\n✅ Database seeded successfully!")
        print("\n📋 Sample User Credentials:")
        print("=" * 50)
        print("Admin:")
        print("  Email: hr@county.go.ke")
        print("  Password: password")
        print("\nSupervisor:")
        print("  Email: sup@county.go.ke")
        print("  Password: password")
        print("\nWorker:")
        print("  Email: worker@county.go.ke")
        print("  Password: password")
        print("\nApplicant:")
        print("  Email: applicant@county.go.ke")
        print("  Password: password")
        print("=" * 50)

if __name__ == '__main__':
    seed_database()
