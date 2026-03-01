import 'package:iitpkd_one/core/constants/api_constants.dart';
import 'package:iitpkd_one/core/network/api_client_interface.dart';
import 'package:iitpkd_one/core/network/api_response.dart';
import 'package:iitpkd_one/features/dashboard/data/models/notice.dart';
import 'package:iitpkd_one/features/dashboard/data/models/notice_location.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';

/// Mock implementation of [ApiClientInterface] for development.
///
/// Simulates network delays to properly test loading/error states in the UI.
/// Returns realistic campus data for IIT Palakkad.
class MockApiClient implements ApiClientInterface {
  @override
  Future<ApiResponse<List<ShuttleSchedule>>> getShuttleSchedules({
    String? day,
  }) async {
    await Future<void>.delayed(ApiConstants.mockNetworkDelay);

    final allSchedules = <ShuttleSchedule>[
      const ShuttleSchedule(
        id: 'bus_101',
        from: 'Nila Campus',
        to: 'Sahyadri',
        via: ['Girls Hostel', 'Admin Block', 'Main Gate'],
        time: '09:00',
        isOutsideTrip: false,
        days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      ),
      const ShuttleSchedule(
        id: 'bus_102',
        from: 'Sahyadri',
        to: 'Nila Campus',
        via: ['Main Gate', 'Admin Block'],
        time: '09:30',
        isOutsideTrip: false,
        days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      ),
      const ShuttleSchedule(
        id: 'bus_103',
        from: 'Nila Campus',
        to: 'Sahyadri',
        via: ['Girls Hostel', 'Admin Block', 'Main Gate'],
        time: '10:15',
        isOutsideTrip: false,
        days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      ),
      const ShuttleSchedule(
        id: 'bus_104',
        from: 'Sahyadri',
        to: 'Nila Campus',
        via: ['Main Gate', 'Admin Block', 'Girls Hostel'],
        time: '10:45',
        isOutsideTrip: false,
        days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      ),
      const ShuttleSchedule(
        id: 'bus_105',
        from: 'Nila Campus',
        to: 'Sahyadri',
        via: ['Girls Hostel', 'Library', 'Main Gate'],
        time: '13:00',
        isOutsideTrip: false,
        days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      ),
      const ShuttleSchedule(
        id: 'bus_106',
        from: 'Sahyadri',
        to: 'Nila Campus',
        via: ['Main Gate', 'Library'],
        time: '14:00',
        isOutsideTrip: false,
        days: [
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday',
        ],
      ),
      const ShuttleSchedule(
        id: 'bus_107',
        from: 'Nila Campus',
        to: 'City Center',
        via: ['Sahyadri', 'Railway Station'],
        time: '17:30',
        isOutsideTrip: true,
        days: [
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday',
        ],
      ),
      const ShuttleSchedule(
        id: 'bus_108',
        from: 'City Center',
        to: 'Nila Campus',
        via: ['Railway Station', 'Sahyadri'],
        time: '19:00',
        isOutsideTrip: true,
        days: [
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday',
        ],
      ),
    ];

    final filtered = day != null
        ? allSchedules.where((s) => s.runsOnDay(day)).toList()
        : allSchedules;

    return ApiResponse.success(
      data: filtered,
      message: 'Schedules retrieved successfully',
    );
  }

  @override
  Future<ApiResponse<List<Notice>>> getTodayNotices() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final notices = <Notice>[
      const Notice(
        id: 'notice_882',
        title: 'Emergency Lab Closure',
        category: 'facility',
        importance: 'critical',
        location: NoticeLocation(
          campus: 'Sahyadri',
          block: 'B-Block',
          room: 'Lab 2',
        ),
        timeDisplay: 'All Day',
        description:
            'Transit Lab 2 is closed for maintenance until tomorrow morning.',
      ),
      const Notice(
        id: 'notice_883',
        title: 'Guest Lecture Today',
        category: 'academic',
        importance: 'normal',
        location: NoticeLocation(
          campus: 'Nila',
          block: 'C-Block',
          room: 'Seminar Hall A',
        ),
        timeDisplay: '14:30 - 16:00',
        description:
            '"AI in Robotics" by Dr. Sarah Chen. Starts at 4 PM, Seminar Hall A.',
      ),
      const Notice(
        id: 'notice_884',
        title: 'Research Talk: Quantum Computing',
        category: 'research',
        importance: 'normal',
        location: NoticeLocation(
          campus: 'Nila',
          block: 'C-Block',
          room: 'Seminar Hall',
        ),
        timeDisplay: '16:30 - 18:00',
        description: 'Open for all M.Tech and PhD students.',
      ),
    ];

    return ApiResponse.success(
      data: notices,
      message: '${notices.length} updates found for today',
    );
  }

  @override
  Future<ApiResponse<List<Notice>>> getNotices({String? dateFilter}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // Simulates historical notices for the past few days.
    final notices = <Notice>[
      const Notice(
        id: 'notice_880',
        title: 'Water Supply Disruption',
        category: 'facility',
        importance: 'critical',
        location: NoticeLocation(
          campus: 'Nila',
          block: 'A-Block',
          room: 'All Floors',
        ),
        timeDisplay: 'Yesterday, 08:00 - 14:00',
        description: 'Water supply was disrupted due to pipeline maintenance.',
      ),
      const Notice(
        id: 'notice_879',
        title: 'Coding Contest Registration',
        category: 'event',
        importance: 'normal',
        location: NoticeLocation(
          campus: 'Sahyadri',
          block: 'B-Block',
          room: 'CS Lab 1',
        ),
        timeDisplay: '2 days ago',
        description: 'Register for the inter-college coding contest by Friday.',
      ),
    ];

    return ApiResponse.success(
      data: notices,
      message: '${notices.length} notices found',
    );
  }
}
