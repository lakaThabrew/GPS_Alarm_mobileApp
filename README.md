# GPS Alarm

A beautiful, native Flutter mobile application that provides location-based alarms. Never miss your stop again! This project was converted from a classic web app to a modern Flutter experience with a native glassmorphic design.

## Features

- **Live Tracking:** Real-time distance and speed calculation to your destination.
- **Location Alarms:** Intelligent proximity alerts triggering vibration and sound at specific thresholds (2km, 1km, 750m, and arrival).
- **Interactive Maps:** Immersive, offline-capable map experience powered by `flutter_map` and OpenStreetMap.
- **Glassmorphic UI:** A stunning, modern interface featuring custom glass cards, smooth gradients, and reactive components.
- **Background Support:** Utilizes `wakelock_plus` to maintain screen activity during critical tracking phases.

## Getting Started

1. Ensure your physical device or Android/iOS Emulator is running.
2. Clone or navigate to the project directory:
   ```bash
   cd "F:\Projects\Mobile Apps\Gps_alarm"
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Development Requirements

- Flutter SDK (latest version recommended)
- A configured IDE (VS Code, Android Studio, etc.)
- For Windows users: You may need to enable **Developer Mode** in your Windows Settings (`start ms-settings:developers`) if you encounter plugin or symlink errors during the build process.

## Dependencies

- `flutter_map` - For map rendering
- `geolocator` - For GPS polling
- `audioplayers` - For alarm sounds
- `vibration` - For haptic feedback alerts
- `wakelock_plus` - To keep the screen active while tracking
- `shared_preferences` - For local persistence
