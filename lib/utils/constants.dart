class ExerciseConstants {
  // Exercise Categories
  static const List<String> categories = [
    'Cardio',
    'Strength',
    'Flexibility',
    'Balance',
    'Sports',
    'Other',
  ];

  // Common Cardio Exercises
  static const List<String> cardioExercises = [
    'Running',
    'Cycling',
    'Swimming',
    'Walking',
    'Rowing',
    'Jump Rope',
    'Stair Climbing',
    'Elliptical',
    'Dancing',
    'Boxing',
  ];

  // Common Strength Exercises
  static const List<String> strengthExercises = [
    'Push-ups',
    'Pull-ups',
    'Squats',
    'Deadlifts',
    'Bench Press',
    'Shoulder Press',
    'Bicep Curls',
    'Tricep Dips',
    'Lunges',
    'Planks',
  ];

  // Common Flexibility Exercises
  static const List<String> flexibilityExercises = [
    'Yoga',
    'Stretching',
    'Pilates',
    'Tai Chi',
    'Dynamic Stretching',
    'Static Stretching',
  ];

  // Approximate calories burned per minute for different exercise types
  static const Map<String, double> caloriesPerMinute = {
    'Running': 10.0,
    'Cycling': 8.0,
    'Swimming': 9.0,
    'Walking': 4.0,
    'Strength Training': 6.0,
    'Yoga': 3.0,
    'HIIT': 12.0,
    'Dancing': 7.0,
    'Boxing': 11.0,
    'Jump Rope': 11.0,
  };

  static double estimateCalories(String category, int durationMinutes) {
    double caloriesPerMin;
    
    switch (category.toLowerCase()) {
      case 'cardio':
        caloriesPerMin = 8.0;
        break;
      case 'strength':
        caloriesPerMin = 6.0;
        break;
      case 'flexibility':
        caloriesPerMin = 3.0;
        break;
      case 'sports':
        caloriesPerMin = 9.0;
        break;
      default:
        caloriesPerMin = 5.0;
    }
    
    return caloriesPerMin * durationMinutes;
  }
}
