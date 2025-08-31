# Instagram Clone - SwiftUI App

A modern Instagram-like social media app built with SwiftUI, Core Data, and featuring dark mode support.

## Features

### 🏠 Feed View
- **Stories Section**: Interactive story circles with gradient borders
- **Posts Feed**: Scrollable feed with post cards
- **Pull to Refresh**: Swipe down to refresh content
- **Like Functionality**: Tap to like/unlike posts

### 📱 Stories
- **Story Viewer**: Full-screen story experience
- **Auto-advance**: Stories automatically progress
- **Swipe Navigation**: Swipe left/right to navigate between stories
- **Interactive Controls**: Like, reply, and share buttons
- **Progress Indicators**: Visual progress bars for each story

### 🔍 Search View
- **Search Bar**: Placeholder for search functionality
- **Recent Searches**: Shows recent search history
- **Modern UI**: Clean, card-based design

### 👤 Profile View
- **Dark Mode Toggle**: Switch between light and dark themes
- **Settings Menu**: Placeholder for app settings
- **Help & Support**: Access to help resources

### 🌙 Dark Mode Support
- **System Integration**: Respects system appearance settings
- **Manual Toggle**: Switch themes from profile view
- **Persistent Storage**: Remembers user preference
- **Adaptive Colors**: All UI elements adapt to theme

## Architecture

### Core Data Models
- **User**: Profile information, followers, following, posts
- **Post**: Caption, image URL, likes, comments, timestamp
- **Story**: Media content, duration, view status, like status

### ViewModels
- **FeedViewModel**: Manages posts data and interactions
- **StoriesViewModel**: Handles stories loading and pagination

### Services
- **StoriesDataService**: Generates sample stories and manages data
- **SampleDataService**: Creates initial sample data for testing

### Views
- **MainTabView**: Tab-based navigation
- **FeedView**: Main content feed
- **StoriesSection**: Horizontal scrolling stories
- **PostCard**: Individual post display
- **StoryViewer**: Full-screen story experience

## Technical Details

### Dependencies
- **SwiftUI**: Modern declarative UI framework
- **Core Data**: Persistent data storage
- **Foundation**: Basic iOS functionality

### Data Sources
- **Sample Users**: Matrix-themed user data from `users.json`
- **Random Images**: Picsum Photos for placeholder images
- **Generated Content**: Dynamic story generation with emojis

### Performance Features
- **Lazy Loading**: Efficient content loading with pagination
- **Async Images**: Background image loading
- **Memory Management**: Proper Core Data context handling

## Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- macOS 14.0+

### Installation
1. Clone the repository
2. Open `insta.xcodeproj` in Xcode
3. Build and run on simulator or device

### Sample Data
The app automatically generates sample data on first launch:
- 30 Matrix-themed users
- 5-8 stories per user
- Sample posts with captions and images

## Code Quality

### Clean Architecture
- **Separation of Concerns**: Clear separation between views, view models, and services
- **MVVM Pattern**: Model-View-ViewModel architecture
- **Dependency Injection**: Proper dependency management

### Swift Best Practices
- **Modern SwiftUI**: Uses latest SwiftUI features
- **Property Wrappers**: Proper use of `@StateObject`, `@ObservedObject`
- **Error Handling**: Comprehensive error handling with user feedback

### UI/UX Design
- **Adaptive Layouts**: Responsive design for different screen sizes
- **Consistent Spacing**: Systematic spacing and padding
- **Accessibility**: Proper accessibility labels and support

## Future Enhancements

### Planned Features
- **Real-time Updates**: Live content updates
- **User Authentication**: Login and registration
- **Camera Integration**: Photo capture and editing
- **Push Notifications**: Activity alerts
- **Social Features**: Comments, direct messages, following

### Technical Improvements
- **CloudKit Integration**: iCloud data sync
- **Offline Support**: Cached content for offline viewing
- **Performance Optimization**: Image caching and compression
- **Testing**: Unit tests and UI tests

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- **Matrix Characters**: User names inspired by The Matrix universe
- **Picsum Photos**: Random image service for sample content
- **SwiftUI Community**: Open source SwiftUI examples and inspiration
