# myStash - Flutter Savings Management App

**Take-Home Assessment Task: Build a Simple Stash Management App**

A Flutter mobile application for managing personal savings goals with clean architecture, state management, and local data persistence. This app demonstrates building a lightweight version of myStash focused on viewing and managing "stashes" (individual savings targets).

## Task Requirements Implemented

### 1. Authentication (Mocked)
- Simple login screen with email and password validation
- Non-empty input validation with routing to home screen
- No backend integration required

### 2. Home Screen
- Display list of user stashes with:
  - Stash Name
  - Amount Saved
  - Target Amount
  - Animated Progress Bar (% towards target)
- Overview statistics and user greeting

### 3. Stash Detail Screen
- Tap any stash to view detailed information:
  - Full name, amount saved, target, creation date, and category
  - Add new contribution functionality
  - Input contribution amount and update stash progress
  - Contribution history display

### 4. Create New Stash
- Complete form with:
  - Name input
  - Target Amount input
  - Category selection (dropdown with 10 predefined categories)
  - Start Date picker
  - Local storage using Hive database

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or later)
- Dart SDK (2.17.0 or later)
- Chrome browser (for web development)
- Android Studio or VS Code with Flutter extensions

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd my_stash_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate model files**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application**
   ```bash
   # For web
   flutter run -d chrome
   
   # For Android (with device/emulator connected)
   flutter run
   
   # For iOS (on macOS with Xcode)
   flutter run -d ios
   ```

### Login Credentials
The app uses mock authentication. Use any email format and password with 6+ characters to sign in.

## Assumptions Made

### Authentication
- Mock authentication system is sufficient for demonstration
- Simple validation (non-empty fields, email format, 6+ character password)
- No actual security implementation required
- User session persistence across app restarts

### Data Management
- Local storage using Hive is acceptable (no backend integration)
- Data persists until app uninstall
- No data synchronization between devices needed
- Sample data generation for demonstration purposes

### User Interface
- Material Design 3 approach for modern fintech aesthetics
- Responsive design optimized for mobile devices
- Animations enhance user experience without compromising performance
- Professional UI polish to simulate real-world fintech experience

### Stash Categories
- Predefined categories are sufficient (Emergency Fund, Vacation, Home, Car, Education, Health, Investment, Wedding, Electronics, Other)
- Category-specific colors and icons for visual distinction
- Maximum of 10 categories available in dropdown

### Financial Data
- Currency formatting assumes USD ($)
- No currency conversion needed
- Basic percentage calculations for progress tracking
- Decimal precision for monetary values

## Libraries Used

### Core Dependencies
- **flutter**: Core Flutter framework (3.0+)
- **provider**: State management solution for reactive UI updates
- **hive**: Lightweight NoSQL database for local data storage
- **hive_flutter**: Flutter integration for Hive database

### Development Dependencies
- **hive_generator**: Code generation for Hive TypeAdapters
- **build_runner**: Build system for code generation

### UI & Formatting
- **google_fonts**: Inter font family for premium typography
- **intl**: Internationalization and date/currency formatting
- **uuid**: Unique identifier generation for data models

### Input Handling
- Built-in Flutter services for input formatters and validation

## Additional Thoughts

### Architecture Decisions
The app follows clean architecture principles with clear separation of concerns:
- **Models**: Data structures with Hive annotations for persistence
- **Services**: Business logic for data operations and authentication
- **Providers**: State management using ChangeNotifier pattern
- **Screens**: UI presentation layer with responsive design
- **Widgets**: Reusable UI components with consistent styling
- **Utils**: Helper functions, constants, and formatting utilities

### State Management Implementation
- **Provider pattern** chosen for simplicity and Flutter team recommendation
- Consumer widgets for efficient rebuilding
- Proper separation of business logic from UI components
- Loading states and error handling throughout the app

### Technical Implementation
- **Local Storage**: Hive selected for performance, ease of use, and type safety
- **Animations**: Custom animations implemented for professional user experience
- **Navigation**: Custom page transitions for smooth screen transitions
- **Form Validation**: Real-time validation with user feedback

### Performance Considerations
- Lazy loading of data where appropriate
- Efficient widget rebuilding using Consumer widgets
- Animation controllers properly disposed to prevent memory leaks
- Optimized list rendering for stash cards
- Staggered animations for better visual flow

### Code Quality
- Consistent naming conventions throughout the codebase
- Comprehensive error handling and loading states
- Type safety with null safety enabled
- Widget composition over inheritance
- Separation of business logic from UI components
- Clean code structure with modular design

### Bonus Features Implemented
- **Animations & UI Polish**: Smooth transitions, progress animations, shimmer effects for completed stashes
- **Good Architecture**: Clean separation of concerns, SOLID principles
- **Responsive UI**: Adaptive design for different screen sizes
- **Professional Fintech Experience**: Premium typography, consistent design system, micro-interactions

### Limitations Acknowledged
- No comprehensive unit tests implemented due to time constraints
- Limited accessibility features implementation
- No offline-first data synchronization
- Mock authentication without security considerations
- Single currency support only
