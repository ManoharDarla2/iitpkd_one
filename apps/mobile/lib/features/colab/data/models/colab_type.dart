enum ColabType {
  project,
  job,
}

extension ColabTypeExtension on ColabType {
  String get value {
    switch (this) {
      case ColabType.project:
        return 'project';
      case ColabType.job:
        return 'job';
    }
  }

  static ColabType fromString(String value) {
    switch (value) {
      case 'project':
        return ColabType.project;
      case 'job':
        return ColabType.job;
      default:
        return ColabType.project;
    }
  }
}
