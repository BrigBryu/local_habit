/// Habit icon types for domain layer (no Flutter dependency)
enum HabitIcon {
  basic('check_circle_outline'),
  exercise('directions_run'),
  water('local_drink'),
  book('book'),
  sleep('bedtime'),
  meditation('self_improvement'),
  food('restaurant'),
  work('work'),
  social('people'),
  creative('brush'),
  learning('school'),
  layers('layers'),
  alarm('alarm'),
  timer('timer'),
  schedule('schedule');

  const HabitIcon(this.identifier);
  final String identifier;
}

/// Time of day for habit scheduling
enum TimeOfDay {
  morning('morning'),
  afternoon('afternoon'),
  evening('evening'),
  anytime('anytime');

  const TimeOfDay(this.identifier);
  final String identifier;
}
