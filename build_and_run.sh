#!/bin/bash

echo "🚀 Building and Running Stories App..."
echo "======================================="

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed or not in PATH"
    exit 1
fi

# Build the project
echo "📱 Building project..."
xcodebuild -project insta.xcodeproj -scheme insta -destination 'platform=iOS Simulator,name=iPhone 16' build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🎯 Next steps:"
    echo "1. Open insta.xcodeproj in Xcode"
    echo "2. Select iPhone 16 simulator (or any available simulator)"
    echo "3. Press Cmd+R to run the app"
    echo ""
    echo "📱 App Features:"
    echo "- Stories are now integrated into the main FeedView (top of screen)"
    echo "- Horizontal pagination for stories with infinite scroll"
    echo "- Multiple stories per user with auto-advance"
    echo "- Instagram-like gestures and cube transitions"
    echo "- Like functionality with immediate UI updates"
    echo "- Proper persistence for seen/unseen and liked states"
    echo ""
    echo "🎬 How to test:"
    echo "1. Run the app and see stories at the top of the home screen"
    echo "2. Tap on any story to open the full-screen viewer"
    echo "3. Swipe left/right to navigate between stories of the same user"
    echo "4. Swipe down to dismiss stories"
    echo "5. Tap the heart button to like stories"
    echo "6. Scroll horizontally through the stories list for pagination"
    echo ""
    echo "🔧 Technical improvements:"
    echo "- Removed separate Stories tab"
    echo "- Stories integrated into FeedView"
    echo "- Fixed like button update issues"
    echo "- Added cube transitions between users"
    echo "- Improved story pagination and memory efficiency"
else
    echo "❌ Build failed!"
    exit 1
fi
