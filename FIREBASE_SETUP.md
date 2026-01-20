# Firebase Setup Guide

## Quick Setup Steps

1. **Create Firebase Project**
   - Go to https://console.firebase.google.com/
   - Click "Add Project"
   - Enter project name: "daily-exercise-app"

2. **Enable Authentication**
   - Navigate to Authentication → Sign-in method
   - Enable Email/Password
   - Enable Google

3. **Create Firestore Database**
   - Navigate to Firestore Database
   - Create database in test mode
   - Choose closest region

4. **Add Android App**
   ```
   Package name: com.example.daily_exercise_app
   Download google-services.json
   Place in: android/app/google-services.json
   ```

5. **Add iOS App**
   ```
   Bundle ID: com.example.dailyExerciseApp
   Download GoogleService-Info.plist
   Place in: ios/Runner/GoogleService-Info.plist
   ```

6. **Update firebase_options.dart**
   - Copy your Firebase config values
   - Replace placeholders in lib/firebase_options.dart

7. **Run FlutterFire Configure (Alternative)**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

## Firestore Collections Structure

### users
```
{
  email: string
  displayName: string
  photoUrl: string (optional)
  createdAt: timestamp
  lastLoginAt: timestamp
}
```

### workouts
```
{
  userId: string
  exerciseName: string
  category: string
  durationMinutes: number
  sets: number (optional)
  reps: number (optional)
  weight: number (optional)
  caloriesBurned: number
  notes: string (optional)
  date: timestamp
  createdAt: timestamp
}
```

### goals
```
{
  userId: string
  title: string
  description: string
  type: string
  targetValue: number
  currentValue: number
  unit: string
  startDate: timestamp
  targetDate: timestamp
  isCompleted: boolean
  createdAt: timestamp
}
```

## Security Rules

Apply these rules in Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /workouts/{workoutId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
                       request.auth.uid == request.resource.data.userId;
    }
    
    match /goals/{goalId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
                       request.auth.uid == request.resource.data.userId;
    }
  }
}
```
