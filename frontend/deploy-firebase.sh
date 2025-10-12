#!/bin/bash

echo "🚀 Deploying County Worker Platform Frontend to Firebase..."

# Check if firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

# Login to Firebase
echo "🔐 Logging in to Firebase..."
firebase login

# Build Flutter web app
echo "🔨 Building Flutter web app..."
flutter clean
flutter pub get
flutter build web --release

# Deploy to Firebase
echo "📦 Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "✅ Deployment complete!"
echo "🌐 Your app is now live!"
echo ""
echo "📝 Don't forget to:"
echo "  1. Update API base URL in api_service.dart"
echo "  2. Update CORS settings in backend"
echo "  3. Test the deployed app"
