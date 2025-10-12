"""
Direct database migration script for Railway PostgreSQL
Run this with the DATABASE_URL from Railway
"""
import psycopg2
import os
import sys

# Get DATABASE_URL from environment or command line
DATABASE_URL = os.environ.get('DATABASE_URL') or (sys.argv[1] if len(sys.argv) > 1 else None)

if not DATABASE_URL:
    print("❌ Error: DATABASE_URL not provided")
    print("\nUsage:")
    print("  python migrate_railway_direct.py 'postgresql://user:pass@host:port/dbname'")
    print("  OR")
    print("  DATABASE_URL='postgresql://...' python migrate_railway_direct.py")
    sys.exit(1)

def migrate_database():
    """Add new columns to existing database"""
    try:
        print("Connecting to Railway PostgreSQL database...")
        conn = psycopg2.connect(DATABASE_URL)
        cursor = conn.cursor()
        
        print("Starting database migration...")
        
        # Add salary and salary_balance columns to users table
        print("Adding salary column to users table...")
        cursor.execute("""
            ALTER TABLE users 
            ADD COLUMN IF NOT EXISTS salary FLOAT
        """)
        
        print("Adding salary_balance column to users table...")
        cursor.execute("""
            ALTER TABLE users 
            ADD COLUMN IF NOT EXISTS salary_balance FLOAT DEFAULT 0.0
        """)
        
        # Add approved_at and supervisor_comment columns to tasks table
        print("Adding approved_at column to tasks table...")
        cursor.execute("""
            ALTER TABLE tasks 
            ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP
        """)
        
        print("Adding supervisor_comment column to tasks table...")
        cursor.execute("""
            ALTER TABLE tasks 
            ADD COLUMN IF NOT EXISTS supervisor_comment TEXT
        """)
        
        # Update existing workers to have initial salary balance equal to salary
        print("Updating existing worker salary balances...")
        cursor.execute("""
            UPDATE users 
            SET salary_balance = COALESCE(salary, 0.0)
            WHERE role = 'worker' AND salary IS NOT NULL AND salary_balance IS NULL
        """)
        
        conn.commit()
        print("✅ Database migration completed successfully!")
        
        # Show summary
        cursor.execute("SELECT COUNT(*) FROM users WHERE salary IS NOT NULL")
        workers_with_salary = cursor.fetchone()[0]
        print(f"\n📊 Summary:")
        print(f"   - Workers with salary: {workers_with_salary}")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Migration failed: {str(e)}")
        if 'conn' in locals():
            conn.rollback()
            conn.close()
        raise

if __name__ == '__main__':
    migrate_database()
