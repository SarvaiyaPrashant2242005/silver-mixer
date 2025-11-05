# Silver Mixer Calculator

A professional Flutter application for silver mixing calculations with support for English and Gujarati languages.

## Features

- ✨ **Bilingual Support**: Switch between English and Gujarati
- 📊 **Real-time Calculations**: See results as you type
- 💾 **History Management**: Save and retrieve past calculations
- 🔄 **Edit Mode**: Modify existing calculations
- 📱 **Responsive UI**: Beautiful and user-friendly interface
- 🎨 **Modern Design**: Material Design 3 with smooth animations
- 💽 **Local Storage**: All data saved locally using SharedPreferences

## Folder Structure

```
lib/
├── main.dart                    # App entry point
├── controller/
│   └── calculation_controller.dart  # Business logic & state management
├── model/
│   └── calculation_model.dart       # Data models
├── services/
│   ├── language_service.dart        # Language management
│   └── storage_service.dart         # Data persistence
└── screens/
    ├── splash_screen.dart           # Splash screen with animation
    ├── home_screen.dart             # Landing page
    ├── entry_input_screen.dart      # Input entries (Step 1)
    ├── touch_input_screen.dart      # Input touch values (Step 2)
    ├── result_screen.dart           # Show calculation results
    └── history_screen.dart          # View saved calculations
```

## Installation

1. **Prerequisites**:
   - Flutter SDK (3.0.0 or higher)
   - Android Studio / VS Code with Flutter plugins
   - A device or emulator

2. **Clone and Setup**:
   ```bash
   # Navigate to your project directory
   cd silver_mixer
   
   # Get dependencies
   flutter pub get
   
   # Generate app icon (optional, if you have icon assets)
   flutter pub run flutter_launcher_icons
   
   # Generate splash screen (optional, if you have splash assets)
   flutter pub run flutter_native_splash:create
   ```

3. **Run the App**:
   ```bash
   # For development
   flutter run
   
   # For release build (Android)
   flutter build apk --release
   
   # For release build (iOS)
   flutter build ios --release
   ```

## App Icon Setup

To use the SVG icon provided:

1. Convert the SVG to PNG using an online tool or design software
2. Create these files:
   - `assets/icon/app_icon.png` (1024x1024px)
   - `assets/icon/app_icon_foreground.png` (432x432px, transparent background)
   - `assets/splash/splash_icon.png` (512x512px)

3. Run:
   ```bash
   flutter pub run flutter_launcher_icons
   flutter pub run flutter_native_splash:create
   ```

## Usage Guide

### Step 1: Enter Entries
- Input weight, touch, and fine values
- Add multiple entries using the floating action button
- Remove entries if needed (minimum 1 entry required)

### Step 2: Enter Touch Values
- Input Me. Touch value
- Input Co. Touch value
- Ga. Touch auto-fills (same as Me. Touch)

### Step 3: View Results
The app calculates and displays:
- Koch Copper (કોચ કોપર)
- Silver Fine (ચાંદી ફાઈન)
- Gaalva Number Near (ગાળવા નંબર નજીક)
- Number Copper (નંબર કોપર)

### Step 4: Save Calculation
- Enter a title (required)
- Add description (optional)
- Save to history for future reference

## Calculation Formula

Based on the provided screenshot:

1. **Step 1**: Total Fine + Me.Touch
2. **Step 2**: Step1 - Total Weight = Koch Copper
3. **Step 3**: Step2 × Co.Touch = Silver Fine
4. **Step 4**: (Step3 rounded) + Total Fine
5. **Step 5**: Step4 - Me.Touch = Gaalva Number Near
6. **Step 6**: Step5 - Total Weight = Number Copper

## Language Support

The app supports two languages:
- **English**: For international users
- **Gujarati (ગુજરાતી)**: For local users

Switch language anytime from the home screen using the language icon.

## Data Storage

- Uses `shared_preferences` for local data persistence
- All calculations are stored locally on the device
- No internet connection required
- Data persists across app sessions

## App Size Optimization

The app is optimized for minimal size:
- Efficient data structures
- Minimal dependencies
- Local storage only
- No heavy external libraries

## Building for Production

### Android:
```bash
flutter build apk --release --split-per-abi
```
This creates optimized APKs for different architectures.

### iOS:
```bash
flutter build ios --release
```
Then archive and upload via Xcode.

## Troubleshooting

**Issue**: Dependencies not installing
```bash
flutter clean
flutter pub get
```

**Issue**: App icon not showing
```bash
flutter pub run flutter_launcher_icons
flutter clean
flutter run
```

**Issue**: Build errors
```bash
flutter doctor
# Fix any issues shown
flutter clean
flutter pub get
```

## Developer

**Developed by AllySoft Solutions**

---

## License

This project is private and proprietary.

## Version History

- **v1.0.0** - Initial release
  - Bilingual support (English/Gujarati)
  - Entry input with multiple entries
  - Touch value input
  - Real-time calculations
  - History management
  - Save/Edit/Delete functionality
  - Beautiful splash screen
  - Modern UI with Material Design 3