# LectureLift
# Members: Bayla Patin, Thomas Shimer, Anthony Raemsch, Megan White, Makayla Files 

**Ride-sharing for students, by students.**

LectureLift ensures you never have to worry about getting to class. Connect with students who have similar schedules and catch a lift securely.

## Core Features
- **🎓 Edu-Verification**: Exclusive access for students with valid `.edu` emails.
- **📅 Class Schedule**: Import your schedule via `.ics` file or add classes manually.
- **⭐ Dual Rating System**: Dedicated tabs and ratings for both Riders and Drivers.
- **🔍 Smart Filtering**: Filter rides based on matching class schedules.

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


## Project Structure
- `lib/screens/`: Contains the main application screens (e.g., `MapScreen`).
- `lib/widgets/`: Reusable UI components (`MapSearchBar`, `MapHelperCard`, etc.).
- `lib/theme/`: App styling and theme definitions.
- `assets/`: Static assets like custom map styles.