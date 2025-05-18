# Expense Tracker

A comprehensive expense tracking application built with Flutter.

## Features

- 📱 Cross-platform (iOS, Android, Web, Desktop)
- 💰 Track daily expenses
- 📊 Visual statistics and charts
- 🏷️ Categorize expenses
- 🌙 Dark/Light theme support
- 💾 Local data storage

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/               # Data models
├── screens/              # UI screens
├── widgets/              # Reusable widgets
├── services/             # Business logic & data services
├── providers/            # State management
└── utils/                # Helper functions & constants
```

## Dependencies

- **provider**: State management
- **sqflite**: Local database storage
- **intl**: Date and time formatting
- **fl_chart**: Charts and graphs
- **flutter_slidable**: Swipe actions
- **shared_preferences**: App settings storage

## Getting Started

1. **Prerequisites**
   - Flutter SDK (latest stable version)
   - Dart SDK
   - Android Studio / VS Code

2. **Installation**
   ```bash
   # Clone the repository
   git clone <repository-url>
   cd expense_tracker

   # Install dependencies
   flutter pub get

   # Run the app
   flutter run
   ```

3. **Build for production**
   ```bash
   # Android
   flutter build apk --release

   # iOS
   flutter build ios --release

   # Web
   flutter build web --release
   ```

## Development

- Run tests: `flutter test`
- Analyze code: `flutter analyze`
- Format code: `flutter format .`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.
