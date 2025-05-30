# 💰 myStash - Smart Savings App

A beautiful, modern Flutter mobile application for managing personal savings goals. Built with clean architecture principles, smooth animations, and an intuitive user interface.

![Flutter](https://img.shields.io/badge/Flutter-3.8+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 🎯 Overview

myStash helps users automate savings and manage their finances smartly. Create individual savings targets called "stashes", track your progress, and watch your savings grow with beautiful visual indicators.

## ✨ Features

### 🔐 **Authentication**
- Simple mock authentication system
- Persistent login state
- Smooth animated login experience

### 🏠 **Dashboard**
- Personal welcome with user greeting
- Overview statistics (total saved, targets, progress)
- Beautiful animated progress indicators
- Quick access to create new stashes

### 💳 **Stash Management**
- Create custom savings goals with categories
- 10 predefined categories with unique colors and icons
- Set target amounts and start dates
- Track progress with animated progress bars

### 📊 **Detailed Tracking**
- Individual stash detail pages
- Add contributions with real-time updates
- View contribution history
- Category-specific theming

### 🎨 **Beautiful UI/UX**
- Google Fonts (Inter) for premium typography
- Smooth animations and micro-interactions
- Material Design 3 principles
- Professional fintech app aesthetics
- Responsive design for all screen sizes

### 💾 **Local Storage**
- Offline-first architecture using Hive
- Type-safe data persistence
- No internet connection required

## 🏗 Architecture

Built following **Clean Architecture** principles:

```
lib/
├── models/          # Data models with Hive annotations
├── services/        # Business logic layer
├── providers/       # State management (Provider pattern)
├── screens/         # UI screens
├── widgets/         # Reusable UI components
└── utils/          # Constants, formatters, helpers
```

### **Key Architectural Decisions:**
- **Provider** for state management
- **Hive** for local database
- **Google Fonts** for typography
- **Material Design 3** for consistent UI
- **Animation Controllers** for smooth transitions

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8+
- Dart 3.0+
- Android Studio / VS Code
- Android/iOS device or simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/my_stash_app.git
   cd my_stash_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 How to Use

### **Login**
- Use any email address and password (minimum 6 characters)
- Example: `john@example.com` / `password123`

### **Create Your First Stash**
1. Tap the **+** button on the home screen
2. Enter stash details:
   - **Name**: e.g., "Emergency Fund", "Vacation"
   - **Target Amount**: Your savings goal
   - **Category**: Choose from 10 categories
   - **Start Date**: When you begin saving
   - **Initial Amount** (optional): Starting balance

### **Add Contributions**
1. Tap any stash card to view details
2. Enter contribution amount
3. Tap "Add" to update your progress
4. Watch the animated progress bar update!

### **Track Progress**
- View overall statistics on the home screen
- Individual stash progress in detail view
- Contribution history with timestamps

## 🛠 Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile framework |
| **Dart** | Programming language |
| **Provider** | State management |
| **Hive** | Local NoSQL database |
| **Google Fonts** | Typography (Inter font) |
| **Material Design 3** | UI design system |
| **UUID** | Unique identifier generation |
| **Intl** | Internationalization & formatting |

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5           # State management
  hive: ^2.2.3               # Local database
  hive_flutter: ^1.1.0       # Flutter integration
  google_fonts: ^6.2.1       # Typography
  uuid: ^4.5.1               # ID generation
  intl: ^0.19.0              # Formatting
  path_provider: ^2.1.5      # File paths

dev_dependencies:
  hive_generator: ^2.0.0     # Code generation
  build_runner: ^2.4.6       # Build tools
```

## 🎨 Design System

### **Colors**
- **Primary**: `#6C63FF` (Modern purple)
- **Success**: `#4CAF50` (Green)
- **Error**: `#FF5252` (Red)
- **Background**: `#F8F9FA` (Light gray)

### **Categories**
Each category has unique branding:
- 🚨 Emergency Fund (Red)
- ✈️ Vacation (Blue)
- 🏠 Home (Green)
- 🚗 Car (Purple)
- 🎓 Education (Yellow)
- 🏥 Health (Pink)
- 📈 Investment (Cyan)
- 💍 Wedding (Orange)
- 📱 Electronics (Blue Gray)
- 💰 Other (Brown)

### **Typography**
- **Font**: Inter (Google Fonts)
- **Weights**: 400 (Regular), 600 (Semi-bold), 800 (Extra-bold)
- **Optimized** for readability and modern aesthetics

## 🔮 Future Enhancements

- [ ] **Dark Mode** support
- [ ] **Biometric Authentication** (fingerprint/face)
- [ ] **Backup & Sync** with cloud storage
- [ ] **Savings Insights** and analytics
- [ ] **Goal Achievement** notifications
- [ ] **Export Data** functionality
- [ ] **Multiple Currencies** support
- [ ] **Savings Challenges** gamification

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Material Design** for design guidelines
- **Google Fonts** for beautiful typography
- **Hive** for efficient local storage

---

**Built with ❤️ using Flutter**

> *"Smart savings made simple"*
