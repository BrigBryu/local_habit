/// Service to manage user level, XP, and achievements
class LevelService {
  static final LevelService _instance = LevelService._internal();
  factory LevelService() => _instance;
  LevelService._internal();

  int _currentXP = 0;
  int _currentLevel = 1;

  /// Get current XP
  int get currentXP => _currentXP;

  /// Get current level
  int get currentLevel => _currentLevel;

  /// XP required for next level (exponential growth)
  int get xpForNextLevel => _calculateXPForLevel(_currentLevel + 1);

  /// XP required for current level
  int get xpForCurrentLevel => _calculateXPForLevel(_currentLevel);

  /// Progress towards next level (0.0 to 1.0)
  double get progressToNextLevel {
    final xpInCurrentLevel = _currentXP - xpForCurrentLevel;
    final xpNeededForNext = xpForNextLevel - xpForCurrentLevel;
    return xpNeededForNext > 0 ? xpInCurrentLevel / xpNeededForNext : 0.0;
  }

  /// XP remaining until next level
  int get xpUntilNextLevel => xpForNextLevel - _currentXP;

  /// Add XP and check for level up
  bool addXP(int amount, {String? source}) {
    final oldLevel = _currentLevel;
    _currentXP += amount;
    _updateLevel();
    
    print('🎯 +$amount XP${source != null ? ' from $source' : ''} (Total: $_currentXP)');
    
    final leveledUp = _currentLevel > oldLevel;
    if (leveledUp) {
      print('🎉 LEVEL UP! Level $_currentLevel unlocked!');
    }
    
    return leveledUp;
  }

  /// Update level based on current XP
  void _updateLevel() {
    while (_currentXP >= xpForNextLevel && _currentLevel < 100) {
      _currentLevel++;
    }
  }

  /// Calculate XP required for a given level
  int _calculateXPForLevel(int level) {
    if (level <= 1) return 0;
    // Exponential growth: 10, 25, 45, 70, 100, 135, 175, 220, 270, 325...
    return ((level - 1) * (level - 1) * 5) + ((level - 1) * 5);
  }

  /// Get level info as a formatted string
  String getLevelDisplay() {
    return 'Level $_currentLevel • $_currentXP/$xpForNextLevel XP';
  }

  /// Get progress as a compact string
  String getProgressDisplay() {
    final xpInLevel = _currentXP - xpForCurrentLevel;
    final xpNeeded = xpForNextLevel - xpForCurrentLevel;
    return '$xpInLevel/$xpNeeded XP';
  }

  /// Reset progress (for testing)
  void reset() {
    _currentXP = 0;
    _currentLevel = 1;
    print('🔄 Level progress reset');
  }

  /// Get detailed stats for the level page
  Map<String, dynamic> getDetailedStats() {
    return {
      'currentLevel': _currentLevel,
      'currentXP': _currentXP,
      'xpForNextLevel': xpForNextLevel,
      'xpForCurrentLevel': xpForCurrentLevel,
      'progressToNextLevel': progressToNextLevel,
      'xpUntilNextLevel': xpUntilNextLevel,
      'totalLevels': 100, // Max level
    };
  }

  /// Calculate level from total XP (for display purposes)
  static int levelFromXP(int xp) {
    int level = 1;
    while (level < 100) {
      final nextLevelXP = ((level) * (level) * 5) + ((level) * 5);
      if (xp < nextLevelXP) break;
      level++;
    }
    return level;
  }
}