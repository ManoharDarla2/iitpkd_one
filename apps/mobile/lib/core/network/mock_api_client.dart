import 'package:intl/intl.dart';
import 'package:iitpkd_one/core/constants/api_constants.dart';
import 'package:iitpkd_one/core/network/api_client_interface.dart';
import 'package:iitpkd_one/core/network/api_response.dart';
import 'package:iitpkd_one/features/dashboard/data/models/notice.dart';
import 'package:iitpkd_one/features/dashboard/data/models/notice_location.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:iitpkd_one/features/schedule/data/models/meal_day.dart';
import 'package:iitpkd_one/features/schedule/data/models/mess_menu.dart';
import 'package:iitpkd_one/features/schedule/data/models/mess_metadata.dart';
import 'package:iitpkd_one/features/schedule/data/models/shuttle_metadata.dart';

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
        arrivalTime: '09:25',
        isOutsideTrip: false,
        days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      ),
      const ShuttleSchedule(
        id: 'bus_102',
        from: 'Sahyadri',
        to: 'Nila Campus',
        via: ['Main Gate', 'Admin Block'],
        time: '09:30',
        arrivalTime: '09:55',
        isOutsideTrip: false,
        days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      ),
      const ShuttleSchedule(
        id: 'bus_103',
        from: 'Nila Campus',
        to: 'Sahyadri',
        via: ['Girls Hostel', 'Admin Block', 'Main Gate'],
        time: '10:15',
        arrivalTime: '10:40',
        isOutsideTrip: false,
        days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      ),
      const ShuttleSchedule(
        id: 'bus_104',
        from: 'Sahyadri',
        to: 'Nila Campus',
        via: ['Main Gate', 'Admin Block', 'Girls Hostel'],
        time: '10:45',
        arrivalTime: '11:10',
        isOutsideTrip: false,
        days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      ),
      const ShuttleSchedule(
        id: 'bus_105',
        from: 'Nila Campus',
        to: 'Sahyadri',
        via: ['Girls Hostel', 'Library', 'Main Gate'],
        time: '11:15',
        arrivalTime: '11:40',
        isOutsideTrip: false,
        days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      ),
      const ShuttleSchedule(
        id: 'bus_106',
        from: 'Sahyadri',
        to: 'Nila Campus',
        via: ['Main Gate', 'Library'],
        time: '12:30',
        arrivalTime: '12:55',
        isOutsideTrip: false,
        days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      ),
      const ShuttleSchedule(
        id: 'bus_107',
        from: 'Nila Campus',
        to: 'Sahyadri',
        via: ['Girls Hostel', 'Library', 'Main Gate'],
        time: '13:00',
        arrivalTime: '13:25',
        isOutsideTrip: false,
        days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      ),
      const ShuttleSchedule(
        id: 'bus_108',
        from: 'Sahyadri',
        to: 'Nila Campus',
        via: ['Main Gate', 'Library'],
        time: '14:00',
        arrivalTime: '14:25',
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
        id: 'bus_109',
        from: 'Sahyadri',
        to: 'Nila Campus',
        via: ['Main Gate', 'Admin Block'],
        time: '14:15',
        arrivalTime: '14:40',
        isOutsideTrip: false,
        days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      ),
      const ShuttleSchedule(
        id: 'bus_110',
        from: 'Nila Campus',
        to: 'City Center',
        via: ['Sahyadri', 'Railway Station'],
        time: '17:30',
        arrivalTime: '18:15',
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
        id: 'bus_111',
        from: 'City Center',
        to: 'Nila Campus',
        via: ['Railway Station', 'Sahyadri'],
        time: '19:00',
        arrivalTime: '19:45',
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
  Future<ApiResponse<ShuttleMetadata>> getShuttleMetadata() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return ApiResponse.success(
      data: ShuttleMetadata(
        updatedAt: DateTime(2026, 1, 15),
        version: '2026-spring-v1',
      ),
      message: 'Shuttle metadata retrieved',
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

  // ---------------------------------------------------------------------------
  // Mess endpoints
  // ---------------------------------------------------------------------------

  @override
  Future<ApiResponse<MessMenu>> getMessMenu() async {
    await Future<void>.delayed(ApiConstants.mockNetworkDelay);

    return ApiResponse.success(
      data: MessMenu(campus: 'Nila', days: _fullMessMenu),
      message: 'Full 14-day mess menu retrieved',
    );
  }

  @override
  Future<ApiResponse<MealDay>> getMessMenuToday() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final weekType = _currentWeekType();
    final dayName = DateFormat('EEEE').format(DateTime.now()).toLowerCase();

    final today = _fullMessMenu.firstWhere(
      (d) => d.weekType == weekType && d.day == dayName,
      orElse: () => _fullMessMenu.first,
    );

    return ApiResponse.success(
      data: today,
      message: "Today's menu retrieved",
    );
  }

  @override
  Future<ApiResponse<MessMetadata>> getMessMetadata() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return ApiResponse.success(
      data: MessMetadata(
        updatedAt: DateTime(2026, 1, 10),
        campus: 'Nila',
      ),
      message: 'Mess metadata retrieved',
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Reference date: Jan 5, 2026 is an "odd" week.
  String _currentWeekType() {
    final reference = DateTime(2026, 1, 5);
    final weeksDiff = DateTime.now().difference(reference).inDays ~/ 7;
    return weeksDiff.isEven ? 'odd' : 'even';
  }

  /// Full 14-day realistic mess menu for IIT Palakkad Nila Campus.
  static const _fullMessMenu = <MealDay>[
    // --- Odd Week (Week 1) ---
    MealDay(
      weekType: 'odd',
      day: 'monday',
      meals: Meals(
        breakfast: ['Idli', 'Sambar', 'Coconut Chutney', 'Tea/Coffee'],
        lunch: ['Rice', 'Dal Tadka', 'Aloo Gobi', 'Roti', 'Curd'],
        snacks: ['Vada Pav', 'Tea'],
        dinner: ['Chapati', 'Paneer Butter Masala', 'Rice', 'Gulab Jamun'],
      ),
    ),
    MealDay(
      weekType: 'odd',
      day: 'tuesday',
      meals: Meals(
        breakfast: ['Masala Dosa', 'Sambar', 'Tomato Chutney', 'Tea/Coffee'],
        lunch: ['Rice', 'Rasam', 'Bhindi Fry', 'Roti', 'Buttermilk'],
        snacks: ['Samosa', 'Juice'],
        dinner: ['Roti', 'Chole', 'Jeera Rice', 'Ice Cream'],
      ),
    ),
    MealDay(
      weekType: 'odd',
      day: 'wednesday',
      meals: Meals(
        breakfast: ['Poha', 'Jalebi', 'Boiled Eggs', 'Tea/Coffee'],
        lunch: ['Rice', 'Sambar', 'Mixed Veg', 'Phulka', 'Pickle'],
        snacks: ['Bread Pakora', 'Tea'],
        dinner: ['Chapati', 'Dal Makhani', 'Rice', 'Kheer'],
      ),
    ),
    MealDay(
      weekType: 'odd',
      day: 'thursday',
      meals: Meals(
        breakfast: ['Uttapam', 'Sambar', 'Mint Chutney', 'Tea/Coffee'],
        lunch: ['Rice', 'Dal Fry', 'Baingan Bharta', 'Roti', 'Curd'],
        snacks: ['Puff Pastry', 'Juice'],
        dinner: ['Roti', 'Rajma', 'Rice', 'Fruit Custard'],
      ),
    ),
    MealDay(
      weekType: 'odd',
      day: 'friday',
      meals: Meals(
        breakfast: ['Puri', 'Aloo Sabzi', 'Sprouts', 'Tea/Coffee'],
        lunch: ['Rice', 'Sambar', 'Cabbage Poriyal', 'Roti', 'Buttermilk'],
        snacks: ['Cutlet', 'Tea'],
        dinner: ['Biryani', 'Raita', 'Salan', 'Double Ka Meetha'],
      ),
    ),
    MealDay(
      weekType: 'odd',
      day: 'saturday',
      meals: Meals(
        breakfast: ['Upma', 'Coconut Chutney', 'Banana', 'Tea/Coffee'],
        lunch: ['Rice', 'Rasam', 'Potato Fry', 'Roti', 'Papad'],
        snacks: ['Biscuits', 'Milk'],
        dinner: ['Chapati', 'Matar Paneer', 'Rice', 'Halwa'],
      ),
    ),
    MealDay(
      weekType: 'odd',
      day: 'sunday',
      meals: Meals(
        breakfast: ['Chole Bhature', 'Pickle', 'Tea/Coffee'],
        lunch: ['Veg Pulao', 'Dal Tadka', 'Raita', 'Roti', 'Sweet'],
        snacks: ['Maggi', 'Juice'],
        dinner: ['Chapati', 'Kadai Paneer', 'Rice', 'Ras Malai'],
      ),
    ),
    // --- Even Week (Week 2) ---
    MealDay(
      weekType: 'even',
      day: 'monday',
      meals: Meals(
        breakfast: ['Rava Dosa', 'Sambar', 'Ginger Chutney', 'Tea/Coffee'],
        lunch: ['Rice', 'Moong Dal', 'Tinda Masala', 'Roti', 'Curd'],
        snacks: ['Aloo Bonda', 'Tea'],
        dinner: ['Roti', 'Shahi Paneer', 'Rice', 'Jalebi'],
      ),
    ),
    MealDay(
      weekType: 'even',
      day: 'tuesday',
      meals: Meals(
        breakfast: ['Medu Vada', 'Sambar', 'Coconut Chutney', 'Tea/Coffee'],
        lunch: ['Rice', 'Dal Palak', 'Aloo Matar', 'Roti', 'Pickle'],
        snacks: ['Spring Roll', 'Juice'],
        dinner: ['Chapati', 'Chana Masala', 'Pulao', 'Rasogolla'],
      ),
    ),
    MealDay(
      weekType: 'even',
      day: 'wednesday',
      meals: Meals(
        breakfast: ['Paratha', 'Curd', 'Pickle', 'Tea/Coffee'],
        lunch: ['Rice', 'Rasam', 'Beans Poriyal', 'Roti', 'Buttermilk'],
        snacks: ['Dhokla', 'Tea'],
        dinner: ['Roti', 'Palak Paneer', 'Rice', 'Sevai Kheer'],
      ),
    ),
    MealDay(
      weekType: 'even',
      day: 'thursday',
      meals: Meals(
        breakfast: ['Appam', 'Veg Stew', 'Banana', 'Tea/Coffee'],
        lunch: ['Rice', 'Sambar', 'Drumstick Curry', 'Roti', 'Curd'],
        snacks: ['Kachori', 'Juice'],
        dinner: ['Chapati', 'Mix Veg Curry', 'Rice', 'Phirni'],
      ),
    ),
    MealDay(
      weekType: 'even',
      day: 'friday',
      meals: Meals(
        breakfast: ['Pesarattu', 'Ginger Chutney', 'Sprouts', 'Tea/Coffee'],
        lunch: ['Rice', 'Dal Tadka', 'Cauliflower Fry', 'Roti', 'Papad'],
        snacks: ['Paneer Tikka', 'Tea'],
        dinner: ['Dum Biryani', 'Mirchi Ka Salan', 'Raita', 'Kulfi'],
      ),
    ),
    MealDay(
      weekType: 'even',
      day: 'saturday',
      meals: Meals(
        breakfast: ['Pongal', 'Coconut Chutney', 'Boiled Eggs', 'Tea/Coffee'],
        lunch: ['Rice', 'Rasam', 'Kootu', 'Roti', 'Buttermilk'],
        snacks: ['Cake', 'Milk'],
        dinner: ['Roti', 'Malai Kofta', 'Rice', 'Gajar Halwa'],
      ),
    ),
    MealDay(
      weekType: 'even',
      day: 'sunday',
      meals: Meals(
        breakfast: ['Aloo Paratha', 'Curd', 'Pickle', 'Tea/Coffee'],
        lunch: ['Jeera Rice', 'Dal Makhani', 'Paneer Tikka', 'Roti', 'Sweet'],
        snacks: ['Pasta', 'Juice'],
        dinner: ['Chapati', 'Butter Chicken Gravy (Veg)', 'Rice', 'Gulab Jamun'],
      ),
    ),
  ];
}
