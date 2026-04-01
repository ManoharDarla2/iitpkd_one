import 'package:intl/intl.dart';

class Competition {
  final String websiteUrl;
  final String title;
  final String applyLink;
  final DateTime deadline;

  const Competition({
    required this.websiteUrl,
    required this.title,
    required this.applyLink,
    required this.deadline,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    final parsedDeadline = DateTime.tryParse(json['deadline'] as String? ?? '');

    return Competition(
      websiteUrl:
          json['website_url'] as String? ?? json['websiteUrl'] as String,
      title: json['title'] as String,
      applyLink: json['apply_link'] as String? ?? json['applyLink'] as String,
      deadline: parsedDeadline ?? DateTime(1970),
    );
  }

  String get deadlineLabel => DateFormat('dd MMM yyyy').format(deadline);

  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(deadline.year, deadline.month, deadline.day);
    return target.difference(today).inDays;
  }
}
