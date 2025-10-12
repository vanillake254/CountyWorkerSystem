#!/bin/bash
# Railway migration script
# This will run the database migration on Railway

echo "Running database migration..."
python migrate_db.py

echo "Migration complete! Starting application..."
