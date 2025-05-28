# Expense Tracker

A comprehensive expense tracking application built with Flutter.

## Features

- Track daily expenses with full CRUD operations
- Interactive statistics and charts with fl_chart
- Categorize expenses with custom categories
- Search and filter expenses by category and date range
- Dark/Light theme support with system theme detection
- Local SQLite database storage
- Multi-currency support (USD, EUR, GBP, JPY, INR)
- Edit expenses with pre-populated data
- Swipe to delete with confirmation
- Real-time expense analytics and summaries
- Comprehensive settings management

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

3. **Windows Developer Mode (Required for Desktop)**
   If you're running on Windows and want to test the desktop version, you need to enable Developer Mode:

   **Option 1: Use the provided script**

   ```bash
   # Run the batch file to open settings
   ./enable_developer_mode.bat
   ```

   **Option 2: Manual setup**

   - Open Windows Settings (Win + I)
   - Go to Privacy & security → For developers
   - Turn ON "Developer Mode"
   - Click "Yes" when prompted
   - Restart your terminal and run `flutter run -d windows`

4. **Build for production**

   ```bash
   # Android
   flutter build apk --release

   # iOS
   flutter build ios --release

   # Web
   flutter build web --release

   # Windows (requires Developer Mode)
   flutter build windows --release
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
