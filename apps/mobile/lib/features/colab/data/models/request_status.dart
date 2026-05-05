enum RequestStatus {
  pending,
  accepted,
  rejected,
  cancelled,
  expired,
}

extension RequestStatusExtension on RequestStatus {
  String get value {
    switch (this) {
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.accepted:
        return 'accepted';
      case RequestStatus.rejected:
        return 'rejected';
      case RequestStatus.cancelled:
        return 'cancelled';
      case RequestStatus.expired:
        return 'expired';
    }
  }

  static RequestStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return RequestStatus.pending;
      case 'accepted':
        return RequestStatus.accepted;
      case 'rejected':
        return RequestStatus.rejected;
      case 'cancelled':
        return RequestStatus.cancelled;
      case 'expired':
        return RequestStatus.expired;
      default:
        return RequestStatus.pending;
    }
  }
}
