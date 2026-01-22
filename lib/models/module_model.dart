enum ModuleStatus {
  completed,
  inProgress,
  locked,
}

class ModuleModel {
  final String id;
  final String title;
  final String subtitle;
  final int completedLessons;
  final int totalLessons;
  final ModuleStatus status;

  ModuleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.completedLessons,
    required this.totalLessons,
    required this.status,
  });
}
