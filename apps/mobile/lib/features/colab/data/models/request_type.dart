enum RequestType {
  join,
  invite,
}

extension RequestTypeExtension on RequestType {
  String get value {
    switch (this) {
      case RequestType.join:
        return 'join';
      case RequestType.invite:
        return 'invite';
    }
  }

  static RequestType fromString(String value) {
    switch (value) {
      case 'join':
        return RequestType.join;
      case 'invite':
        return RequestType.invite;
      default:
        return RequestType.join;
    }
  }
}
