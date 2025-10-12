#!/bin/bash

echo "🗄️ Initializing Railway Database..."

cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/backend"

echo "📦 Step 1: Initialize migrations..."
railway run flask db init || echo "Already initialized"

echo "📦 Step 2: Create migration..."
railway run flask db migrate -m "Initial migration"

echo "📦 Step 3: Apply migrations..."
railway run flask db upgrade

echo "📦 Step 4: Seed database with test data..."
railway run python3 seed.py

echo "✅ Database initialized successfully!"
echo ""
echo "🎉 Your backend is ready at:"
echo "https://countyworker-system-production.up.railway.app"
