/// Habit icon types for domain layer (no Flutter dependency)
enum HabitIcon {
  basic('check_circle_outline'),
  stack('layers'),
  alarm('alarm'),
  timer('timer'),
  schedule('schedule');

  const HabitIcon(this.identifier);
  final String identifier;
}