"""
Database migration script to add new columns for workflow implementation
Run this on Railway to update the production database
"""
from app import create_app
from utils.db import db
from sqlalchemy import text
import os

def migrate_database():
    """Add new columns to existing database"""
    app = create_app('production')
    
    with app.app_context():
        try:
            print("Starting database migration...")
            
            # Add salary and salary_balance columns to users table
            print("Adding salary column to users table...")
            db.session.execute(text("""
                ALTER TABLE users 
                ADD COLUMN IF NOT EXISTS salary FLOAT
            """))
            
            print("Adding salary_balance column to users table...")
            db.session.execute(text("""
                ALTER TABLE users 
                ADD COLUMN IF NOT EXISTS salary_balance FLOAT DEFAULT 0.0
            """))
            
            # Add approved_at and supervisor_comment columns to tasks table
            print("Adding approved_at column to tasks table...")
            db.session.execute(text("""
                ALTER TABLE tasks 
                ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP
            """))
            
            print("Adding supervisor_comment column to tasks table...")
            db.session.execute(text("""
                ALTER TABLE tasks 
                ADD COLUMN IF NOT EXISTS supervisor_comment TEXT
            """))
            
            # Update existing workers to have initial salary balance equal to salary
            print("Updating existing worker salary balances...")
            db.session.execute(text("""
                UPDATE users 
                SET salary_balance = COALESCE(salary, 0.0)
                WHERE role = 'worker' AND salary IS NOT NULL AND salary_balance IS NULL
            """))
            
            db.session.commit()
            print("✅ Database migration completed successfully!")
            
        except Exception as e:
            db.session.rollback()
            print(f"❌ Migration failed: {str(e)}")
            raise

if __name__ == '__main__':
    migrate_database()
