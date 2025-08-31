#!/bin/bash

# Instagram Clone - Build and Run Script
# This script helps build and run the Instagram clone app

echo "🚀 Instagram Clone - Build and Run Script"
echo "=========================================="

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed or not in PATH"
    echo "Please install Xcode from the App Store"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "insta.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    echo "Current directory: $(pwd)"
    exit 1
fi

echo "✅ Project found: insta.xcodeproj"

# Clean build folder
echo "🧹 Cleaning build folder..."
xcodebuild clean -project insta.xcodeproj -scheme insta

if [ $? -ne 0 ]; then
    echo "❌ Clean failed"
    exit 1
fi

echo "✅ Clean completed"

# Build the project
echo "🔨 Building project..."
xcodebuild build -project insta.xcodeproj -scheme insta -destination 'platform=iOS Simulator,name=iPhone 15'

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build completed successfully!"

# Open in Xcode
echo "📱 Opening project in Xcode..."
open insta.xcodeproj

echo ""
echo "🎉 Setup complete! The project is now open in Xcode."
echo ""
echo "Next steps:"
echo "1. Select your target device/simulator"
echo "2. Press Cmd+R to build and run"
echo "3. Enjoy the Instagram clone with dark mode support!"
echo ""
echo "Features:"
echo "• 📱 Instagram-like feed with stories and posts"
echo "• 🌙 Dark mode toggle in profile view"
echo "• 📖 Interactive story viewer with gestures"
echo "• 💾 Core Data persistence"
echo "• 🎨 Modern SwiftUI design"
