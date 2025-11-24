# LectureLift

A Flutter application for campus navigation and routing.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio)
- [Git](https://git-scm.com/)

## Getting Started with VS Code

Follow these steps to develop in VS Code and run the app on an Android Emulator.

### 1. Set Up the Emulator (via Android Studio)
Android Studio is required only to manage the Android Virtual Device (AVD).
1.  Launch **Android Studio**.
2.  On the Welcome screen, click the **More Actions** (three dots) menu and select **Virtual Device Manager**.
    *   *Alternatively, if a project is open, click the phone icon in the top toolbar.*
3.  Click the **Play** button next to your desired emulator (e.g., Pixel 6) to launch it.
4.  Once the emulator is running, you can close Android Studio (but keep the emulator open).

### 2. Open the Project in VS Code
1.  Launch **Visual Studio Code**.
2.  Click **File > Open Folder...**
3.  Navigate to the `LectureLift/lecture_lift` directory and select it.

### 3. Run the App
1.  Open the **Run and Debug** sidebar (Ctrl+Shift+D or Cmd+Shift+D).
2.  Select **"dart_flutter"** or **"Flutter"** from the dropdown configuration (if prompted).
3.  Ensure your emulator is selected in the bottom-right corner of VS Code (it should say something like "Pixel 6 API 33").
4.  Press **F5** (or click the green play button) to start debugging.
    *   *Alternatively, run `flutter run` in the VS Code terminal.*

## Troubleshooting

### API Key Issues
If you see a blank map or routing fails:
- Ensure your Google Maps API Key is valid.
- Check that the **Maps SDK for Android** and **Directions API** are enabled in your Google Cloud Console.
- If running on an emulator, ensure the emulator has internet access.

### "Forbidden" Error
If you see a "Forbidden" error when searching:
- This usually happens if API key restrictions are set incorrectly.
- For development, ensure your API key allows requests from your Android package name (`com.example.lecture_lift`).

## Project Structure
- `lib/screens/`: Contains the main application screens (e.g., `MapScreen`).
- `lib/widgets/`: Reusable UI components (`MapSearchBar`, `MapHelperCard`, etc.).
- `lib/theme/`: App styling and theme definitions.
- `assets/`: Static assets like custom map styles.