# Daily Exercise App

A comprehensive Flutter mobile application for tracking workouts, setting fitness goals, and monitoring progress. Built with Firebase for backend services and authentication.

## Features

### 🏋️ Workout Tracking
- Log detailed workout sessions with exercise name, category, duration, sets, reps, and weight
- Track calories burned for each workout
- Add notes to workouts for additional context
- View workout history with detailed information
- Delete and manage your workout entries

### 🎯 Fitness Goals
- Set personalized fitness goals (weekly workouts, total duration, calories, weight loss, etc.)
- Track progress with visual progress bars
- Update goal progress as you complete workouts
- Mark goals as completed
- View active and completed goals separately

### 📊 Progress Monitoring
- Interactive charts showing workout frequency and calories burned
- View statistics by week, month, or year
- Track total workouts, duration, and calories burned
- Visual representation of goal progress
- Comprehensive dashboard for all fitness metrics

### 🔐 Authentication
- Email/Password authentication
- Google Sign-In integration
- Password reset functionality
- User profile management
- Secure Firebase Auth integration

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase Firestore
- **Authentication**: Firebase Auth (Email/Password & Google Sign-In)
- **Charts**: fl_chart package
- **State Management**: Provider
- **UI Design**: Material Design 3

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (3.0.0 or higher)
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for mobile development)
- Firebase CLI
- A Firebase project

## Firebase Setup

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project" and follow the setup wizard
3. Enable Google Analytics (optional)

### 2. Enable Authentication Methods

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Email/Password** provider
3. Enable **Google** provider
   - Add your support email
   - Download the configuration files (next step)

### 3. Enable Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Start in **Test mode** (or Production mode with proper rules)
4. Choose a Cloud Firestore location

### 4. Set Up Firestore Security Rules

Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Workouts collection
    match /workouts/{workoutId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
                       request.auth.uid == request.resource.data.userId;
    }
    
    // Goals collection
    match /goals/{goalId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
                       request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### 5. Configure Firebase for Android

1. In Firebase Console, add an Android app
2. Register your app with package name: `com.example.daily_exercise_app`
3. Download `google-services.json`
4. Place it in `android/app/` directory

### 6. Configure Firebase for iOS

1. In Firebase Console, add an iOS app
2. Register your app with bundle ID: `com.example.dailyExerciseApp`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory

### 7. Update Firebase Configuration

Open `lib/firebase_options.dart` and replace the placeholder values with your actual Firebase configuration:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_API_KEY',
  appId: 'YOUR_IOS_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
  iosBundleId: 'com.example.dailyExerciseApp',
);
```

## Installation

### 1. Clone or Download the Project

```bash
cd "c:\Users\hasit\OneDrive\Desktop\Monbile app"
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Create Asset Directories

```bash
mkdir assets
mkdir assets\images
mkdir assets\icons
mkdir assets\fonts
```

### 4. Add Fonts (Optional)

Download Poppins font family and place the font files in `assets/fonts/`:
- `Poppins-Regular.ttf`
- `Poppins-Medium.ttf`
- `Poppins-SemiBold.ttf`
- `Poppins-Bold.ttf`

Or remove the font configuration from `pubspec.yaml` if you prefer to use default fonts.

### 5. Configure Google Sign-In for Android

Add your SHA-1 fingerprint to Firebase:

```bash
# For debug builds
cd android
./gradlew signingReport
```

Copy the SHA-1 fingerprint and add it in Firebase Console under Project Settings > Your Apps > Android app.

### 6. Update Android Configuration

Edit `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Ensure this is at least 21
        targetSdkVersion 33
        multiDexEnabled true
    }
}
```

## Running the App

### For Android

```bash
flutter run
```

### For iOS

```bash
cd ios
pod install
cd ..
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── user_model.dart
│   ├── workout_model.dart
│   └── goal_model.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── workout_provider.dart
│   └── goal_provider.dart
├── screens/                  # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── workouts/
│   │   ├── workouts_screen.dart
│   │   ├── add_workout_screen.dart
│   │   └── workout_detail_screen.dart
│   ├── goals/
│   │   ├── goals_screen.dart
│   │   ├── add_goal_screen.dart
│   │   └── goal_detail_screen.dart
│   ├── progress/
│   │   └── progress_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── splash_screen.dart
├── services/                 # Backend services
│   ├── auth_service.dart
│   ├── workout_service.dart
│   └── goal_service.dart
└── utils/                    # Utilities
    ├── theme.dart
    ├── validators.dart
    └── date_helper.dart
```

## Key Dependencies

- `firebase_core`: Firebase SDK core
- `firebase_auth`: Firebase authentication
- `cloud_firestore`: Cloud Firestore database
- `google_sign_in`: Google Sign-In integration
- `provider`: State management
- `fl_chart`: Charts and graphs
- `intl`: Internationalization and date formatting

## Features in Detail

### Workout Categories
- Cardio
- Strength
- Flexibility
- Balance
- Sports
- Other

### Goal Types
- Weekly Workouts
- Total Workouts
- Total Duration
- Calories Burned
- Weight Loss
- Custom Goals

### Progress Charts
- Bar chart for workout frequency
- Line chart for calories burned
- Weekly, monthly, and yearly views
- Real-time data updates

## Troubleshooting

### Common Issues

**1. Firebase configuration errors**
- Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are properly placed
- Verify Firebase configuration in `firebase_options.dart`

**2. Google Sign-In not working**
- Add SHA-1 fingerprint to Firebase Console
- Enable Google Sign-In in Firebase Authentication

**3. Build errors**
- Run `flutter clean` and `flutter pub get`
- Check minimum SDK versions (Android minSdkVersion 21)

**4. Firestore permission errors**
- Check Firestore security rules
- Ensure user is authenticated before accessing data

## Future Enhancements

- [ ] Exercise library with predefined workouts
- [ ] Social features (share achievements, compete with friends)
- [ ] Workout reminders and notifications
- [ ] AI-powered workout recommendations
- [ ] Integration with fitness wearables
- [ ] Meal tracking and nutrition planning
- [ ] Exercise video tutorials
- [ ] Export workout data to CSV/PDF

## Contributing

This is a personal project, but suggestions and feedback are welcome!

## License

This project is for educational purposes.

## Support

For issues or questions, please check the Firebase documentation:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Documentation](https://docs.flutter.dev/)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

## Screenshots

*(Add screenshots of your app here once it's running)*

## Author

Built with ❤️ using Flutter and Firebase

---

**Note**: Remember to never commit your `google-services.json`, `GoogleService-Info.plist`, or any files containing API keys to public repositories. Add them to `.gitignore` if sharing your code publicly.
