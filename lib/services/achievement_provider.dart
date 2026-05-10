class AchievementProvider {
  static final Map<String, int> _achievementPoints = {
    'streak_3_days': 250,
    'exam_master': 500,
  };

  static int getPoints(String achievementId) {
    // If it's a level completion achievement (multiply_X_complete)
    if (achievementId.startsWith('multiply_') && achievementId.endsWith('_complete')) {
      return 100;
    }
    
    // Otherwise return from map or 0 if unknown
    return _achievementPoints[achievementId] ?? 0;
  }
}
