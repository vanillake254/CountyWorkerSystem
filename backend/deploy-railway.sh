#!/bin/bash

echo "🚀 Deploying County Worker Platform Backend to Railway..."

# Check if railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Installing..."
    npm install -g @railway/cli
fi

# Login to Railway
echo "🔐 Logging in to Railway..."
railway login

# Deploy
echo "📦 Deploying to Railway..."
railway up

echo "✅ Deployment complete!"
echo "🌐 Check your Railway dashboard for the deployment URL"
echo ""
echo "📝 Don't forget to:"
echo "  1. Set environment variables (SECRET_KEY, JWT_SECRET_KEY)"
echo "  2. Run database migrations"
echo "  3. Seed the database with initial data"
echo ""
echo "Run migrations:"
echo "  railway run flask db upgrade"
echo ""
echo "Seed database:"
echo "  railway run python3 seed.py"
