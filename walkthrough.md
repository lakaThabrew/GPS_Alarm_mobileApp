# GPS Alarm Flutter App Conversion

I have successfully converted the WebApp into a native Flutter mobile application, preserving all its core tracking logic while upgrading the interface to a beautiful, native glassmorphic design!

## What was Accomplished

- **Project Initialization**: Scaffolding the new Flutter app natively in `F:\Projects\Mobile Apps\Gps_alarm`.
- **Dependency Integration**: Added all required packages including `flutter_map` for offline-capable maps, `geolocator` for highly accurate GPS polling, `audioplayers` & `vibration` for alarms, and `wakelock_plus` to keep the screen active.
- **Data Models & State**: Built `Location`, `Destination`, and `SearchHistory` models with structured Providers to efficiently manage state and background logic.
- **Glassmorphic UI Engine**: Designed `GlassCard`, custom buttons, and smooth gradients mimicking the web app's modern feel.
- **Feature Parity**:
  - **Login / Register**: Local simulated auth with persistence via `SharedPreferences`.
  - **Home Dashboard**: Integrated OpenStreetMap Nominatim search for destinations and quick-access recent history.
  - **Live Tracking**: An immersive map with real-time distance and speed calculations. The alarms (vibrations and sound) are programmed to trigger at 2km, 1km, 750m, and arrival thresholds!

## How to Run the App

1. Ensure your physical device or Android Emulator is running.
2. Open your terminal and navigate to the project directory:
   ```bash
   cd "F:\Projects\Mobile Apps\Gps_alarm"
   ```
3. Run the app:
   ```bash
   flutter run
   ```

> [!TIP]
> If you encounter plugin or symlink errors on Windows during the build process, you may need to enable **Developer Mode** in your Windows Settings (`start ms-settings:developers`) to allow Flutter to compile plugins successfully!

Let me know if you would like to test it and adjust the UI colors or features further!
