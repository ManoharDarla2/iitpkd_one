/// Represents the location details of a notice.
class NoticeLocation {
  final String campus;
  final String block;
  final String room;

  const NoticeLocation({
    required this.campus,
    required this.block,
    required this.room,
  });

  factory NoticeLocation.fromJson(Map<String, dynamic> json) {
    return NoticeLocation(
      campus: json['campus'] as String,
      block: json['block'] as String,
      room: json['room'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'campus': campus, 'block': block, 'room': room};
  }

  /// Human-readable location string.
  String get displayString => '$block, $room, $campus';
}
