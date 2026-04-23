import 'package:intl/intl.dart';
import 'package:iitpkd_one/core/constants/api_constants.dart';
import 'package:iitpkd_one/core/network/api_client_interface.dart';
import 'package:iitpkd_one/core/network/api_response.dart';
import 'package:iitpkd_one/features/competitions/data/models/competition.dart';
import 'package:iitpkd_one/features/dashboard/data/models/notice.dart';
import 'package:iitpkd_one/features/dashboard/data/models/notice_location.dart';
import 'package:iitpkd_one/features/dashboard/data/models/shuttle_schedule.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_contact.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_detail.dart';
import 'package:iitpkd_one/features/faculty/data/models/faculty_member.dart';
import 'package:iitpkd_one/features/schedule/data/models/meal_day.dart';
import 'package:iitpkd_one/features/schedule/data/models/mess_menu.dart';
import 'package:iitpkd_one/features/schedule/data/models/mess_metadata.dart';
import 'package:iitpkd_one/features/schedule/data/models/shuttle_metadata.dart';
import 'package:iitpkd_one/features/search/data/models/search_category.dart';
import 'package:iitpkd_one/features/search/data/models/search_result.dart';
import 'package:iitpkd_one/features/search/data/models/search_result_item.dart';

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

    return ApiResponse.success(data: today, message: "Today's menu retrieved");
  }

  @override
  Future<ApiResponse<MessMetadata>> getMessMetadata() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return ApiResponse.success(
      data: MessMetadata(updatedAt: DateTime(2026, 1, 10), version: 'mock-v1'),
      message: 'Mess metadata retrieved',
    );
  }

  // ---------------------------------------------------------------------------
  // Faculty endpoints
  // ---------------------------------------------------------------------------

  @override
  Future<ApiResponse<List<FacultyMember>>> getFacultyList({
    String? department,
  }) async {
    await Future<void>.delayed(ApiConstants.mockNetworkDelay);

    final allFaculty = <FacultyMember>[
      const FacultyMember(
        slug: 'dr-biju-paul',
        name: 'Dr. Biju Paul',
        designation: 'Associate Professor',
        department: 'Computer Science and Engineering',
        imageUrl: null,
      ),
      const FacultyMember(
        slug: 'dr-sahely-bhadra',
        name: 'Dr. Sahely Bhadra',
        designation: 'Associate Professor',
        department: 'Computer Science and Engineering',
        imageUrl: 'https://iitpkd.ac.in/sites/default/files/facpic/sahely.jpg',
      ),
      const FacultyMember(
        slug: 'dr-vineeth-balasubramanian',
        name: 'Dr. Vineeth Balasubramanian',
        designation: 'Assistant Professor',
        department: 'Computer Science and Engineering',
        imageUrl: null,
      ),
      const FacultyMember(
        slug: 'dr-krithika-ramalingam',
        name: 'Dr. Krithika Ramalingam',
        designation: 'Associate Professor',
        department: 'Mechanical Engineering',
        imageUrl: null,
      ),
      const FacultyMember(
        slug: 'dr-rajesh-nair',
        name: 'Dr. Rajesh Nair',
        designation: 'Professor',
        department: 'Physics',
        imageUrl: null,
      ),
      const FacultyMember(
        slug: 'dr-ananya-sharma',
        name: 'Dr. Ananya Sharma',
        designation: 'Assistant Professor',
        department: 'Chemistry',
        imageUrl: null,
      ),
      const FacultyMember(
        slug: 'dr-priya-menon',
        name: 'Dr. Priya Menon',
        designation: 'Associate Professor',
        department: 'Mathematics',
        imageUrl: null,
      ),
      const FacultyMember(
        slug: 'dr-siddharth-iyer',
        name: 'Dr. Siddharth Iyer',
        designation: 'Assistant Professor',
        department: 'Humanities and Social Sciences',
        imageUrl: null,
      ),
    ];

    final filtered = department != null
        ? allFaculty.where((f) => f.department == department).toList()
        : allFaculty;

    return ApiResponse.success(
      data: filtered,
      message: 'Faculty list retrieved successfully',
    );
  }

  @override
  Future<ApiResponse<FacultyDetail>> getFacultyDetail({
    required String slug,
  }) async {
    await Future<void>.delayed(ApiConstants.mockNetworkDelay);

    final facultyDetails = <String, FacultyDetail>{
      'dr-biju-paul': const FacultyDetail(
        slug: 'dr-biju-paul',
        name: 'Dr. Biju Paul',
        designation: 'Associate Professor',
        department: 'Computer Science and Engineering',
        contact: FacultyContact(
          email: 'biju@iitpkd.ac.in',
          phoneNumber: '+91-4923-226-0003',
        ),
        researchAreas: ['Network Security', 'Cryptography', 'Cloud Computing'],
        biosketch:
            'Dr. Biju Paul is an Associate Professor at IIT Palakkad specializing in network security and cryptographic protocols. He has published extensively in peer-reviewed journals and conferences.',
        teaching: [
          'CS2010: Data Structures and Algorithms',
          'CS4050: Computer Networks',
          'CS6020: Advanced Cryptography',
        ],
        researchGroups: ['Cybersecurity Lab (Nila Campus)'],
        additionalInformation: {
          'office_hours': 'Tuesday & Friday 2 PM - 4 PM',
          'room': 'Academic Block A, Room 218',
        },
        publications: [
          'Paul B., "Post-Quantum Key Exchange Protocols", IEEE Trans. Information Theory 2025',
          'Paul B., Kumar A., "Lightweight Cryptography for IoT", Cryptography 2024',
          'Paul B., "Network Security Framework", ACM Computing Surveys 2023',
        ],
      ),
      'dr-sahely-bhadra': const FacultyDetail(
        slug: 'dr-sahely-bhadra',
        name: 'Dr. Sahely Bhadra',
        designation: 'Associate Professor',
        department: 'Computer Science and Engineering',
        imageUrl: 'https://iitpkd.ac.in/sites/default/files/facpic/sahely.jpg',
        contact: FacultyContact(
          email: 'sahely@iitpkd.ac.in',
          phoneNumber: null,
        ),
        researchAreas: ['Kernel Methods', 'Optimization', 'Bioinformatics'],
        biosketch:
            'Dr. Sahely Bhadra is an Associate Professor in CSE at IIT Palakkad. She completed her PhD from KU Leuven, Belgium. Her research interests lie at the intersection of machine learning theory and computational biology.',
        teaching: [
          'CS1010: Introduction to Programming',
          'CS3040: Design and Analysis of Algorithms',
          'CS6010: Kernel Methods in Machine Learning',
        ],
        researchGroups: [
          'Computational Biology Group',
          'AI & Data Science Lab (Nila Campus)',
        ],
        additionalInformation: {
          'office_hours': 'Tuesday 2 PM - 4 PM',
          'room': 'Academic Block A, Room 215',
        },
        publications: [
          'Bhadra S., "Multi-Kernel Learning for Protein Classification", Bioinformatics 2025',
          'Bhadra S., Pham T., "Robust SVM with Missing Labels", JMLR 2024',
        ],
      ),
      'dr-vineeth-balasubramanian': const FacultyDetail(
        slug: 'dr-vineeth-balasubramanian',
        name: 'Dr. Vineeth Balasubramanian',
        designation: 'Assistant Professor',
        department: 'Computer Science and Engineering',
        contact: FacultyContact(
          email: 'vineeth@iitpkd.ac.in',
          phoneNumber: null,
        ),
        researchAreas: [
          'Computer Vision',
          'Deep Learning',
          'Pattern Recognition',
        ],
        biosketch:
            'Dr. Vineeth Balasubramanian is an Assistant Professor specializing in computer vision and deep learning applications. His work focuses on visual recognition and understanding of complex scenes.',
        teaching: [
          'CS3050: Digital Image Processing',
          'CS5010: Advanced Computer Vision',
          'CS6030: Deep Learning for Vision',
        ],
        researchGroups: ['Vision & Graphics Lab'],
        additionalInformation: {
          'office_hours': 'Wednesday 3 PM - 5 PM',
          'room': 'Academic Block A, Room 220',
        },
        publications: [
          'Balasubramanian V., "Attention Mechanisms in Visual Recognition", CVPR 2025',
          'Balasubramanian V., "Scene Understanding with Graph CNNs", ICCV 2024',
        ],
      ),
      'dr-krithika-ramalingam': const FacultyDetail(
        slug: 'dr-krithika-ramalingam',
        name: 'Dr. Krithika Ramalingam',
        designation: 'Associate Professor',
        department: 'Mechanical Engineering',
        contact: FacultyContact(
          email: 'krithika@iitpkd.ac.in',
          phoneNumber: null,
        ),
        researchAreas: [
          'Computational Fluid Dynamics',
          'Thermal Engineering',
          'Microfluidics',
        ],
        biosketch:
            'Dr. Krithika Ramalingam is an Associate Professor in Mechanical Engineering. Her research focuses on computational modeling of fluid flow and heat transfer in micro-scale systems.',
        teaching: [
          'ME2020: Thermodynamics',
          'ME3030: Fluid Mechanics',
          'ME6010: Computational Fluid Dynamics',
        ],
        researchGroups: ['Thermal & Fluid Sciences Lab'],
        additionalInformation: {
          'office_hours': 'Wednesday 2 PM - 4 PM',
          'room': 'Sahyadri Campus, Room 302',
        },
        publications: [
          'Ramalingam K., "Heat Transfer in Microchannels", Int. J. Heat Mass Transfer 2025',
          'Ramalingam K., "Lattice Boltzmann Simulations", Physics of Fluids 2024',
        ],
      ),
      'dr-rajesh-nair': const FacultyDetail(
        slug: 'dr-rajesh-nair',
        name: 'Dr. Rajesh Nair',
        designation: 'Professor',
        department: 'Physics',
        contact: FacultyContact(
          email: 'rajesh.nair@iitpkd.ac.in',
          phoneNumber: '+91-4923-226-0002',
        ),
        researchAreas: [
          'Quantum Computing',
          'Condensed Matter Physics',
          'Quantum Information',
        ],
        biosketch:
            'Dr. Rajesh Nair is a Professor of Physics and a leading researcher in quantum computing. He has published over 80 papers in reputed journals and leads the Quantum Information Lab at IIT Palakkad.',
        teaching: [
          'PH1010: Physics I',
          'PH4020: Quantum Mechanics II',
          'PH6030: Quantum Computing',
        ],
        researchGroups: [
          'Quantum Information Lab',
          'Centre for Quantum Sciences',
        ],
        additionalInformation: {
          'office_hours': 'Monday & Friday 11 AM - 1 PM',
          'room': 'Nila Campus, Room 401',
        },
        publications: [
          'Nair R., "Topological Qubits in Solid-State Systems", Nature Physics 2025',
          'Nair R., "Error Correction for NISQ Devices", PRX Quantum 2024',
          'Nair R., Iyer S., "Quantum Algorithms for Optimization", Quantum 2023',
        ],
      ),
      'dr-ananya-sharma': const FacultyDetail(
        slug: 'dr-ananya-sharma',
        name: 'Dr. Ananya Sharma',
        designation: 'Assistant Professor',
        department: 'Chemistry',
        contact: FacultyContact(
          email: 'ananya@iitpkd.ac.in',
          phoneNumber: null,
        ),
        researchAreas: ['Organic Chemistry', 'Green Chemistry', 'Catalysis'],
        biosketch:
            'Dr. Ananya Sharma joined IIT Palakkad in 2022 after her postdoc at ETH Zurich. She works on developing sustainable catalytic methods for organic synthesis.',
        teaching: [
          'CY1010: Chemistry I',
          'CY3020: Organic Chemistry II',
          'CY5010: Green Chemistry',
        ],
        researchGroups: ['Sustainable Chemistry Lab'],
        additionalInformation: {
          'office_hours': 'Tuesday & Thursday 3 PM - 4 PM',
          'room': 'Nila Campus, Room 203',
        },
        publications: [
          'Sharma A., "Photoredox Catalysis for C-N Bond Formation", JACS 2025',
          'Sharma A., "Sustainable Solvents in Organic Synthesis", Green Chemistry 2024',
        ],
      ),
      'dr-priya-menon': const FacultyDetail(
        slug: 'dr-priya-menon',
        name: 'Dr. Priya Menon',
        designation: 'Associate Professor',
        department: 'Mathematics',
        contact: FacultyContact(
          email: 'priya.menon@iitpkd.ac.in',
          phoneNumber: null,
        ),
        researchAreas: ['Number Theory', 'Algebraic Geometry', 'Cryptography'],
        biosketch:
            'Dr. Priya Menon is an Associate Professor in Mathematics with expertise in algebraic number theory and its applications to modern cryptography.',
        teaching: [
          'MA1010: Mathematics I',
          'MA3030: Abstract Algebra',
          'MA6020: Algebraic Number Theory',
        ],
        researchGroups: ['Algebra & Number Theory Group'],
        additionalInformation: {
          'office_hours': 'Friday 2 PM - 4 PM',
          'room': 'Nila Campus, Room 305',
        },
        publications: [
          'Menon P., "Elliptic Curves over Function Fields", Math. Annalen 2025',
          'Menon P., "Post-Quantum Lattice-Based Signatures", Crypto 2024',
        ],
      ),
      'dr-siddharth-iyer': const FacultyDetail(
        slug: 'dr-siddharth-iyer',
        name: 'Dr. Siddharth Iyer',
        designation: 'Assistant Professor',
        department: 'Humanities and Social Sciences',
        contact: FacultyContact(
          email: 'siddharth@iitpkd.ac.in',
          phoneNumber: null,
        ),
        researchAreas: [
          'Philosophy of Science',
          'Ethics of AI',
          'Science and Technology Studies',
        ],
        biosketch:
            'Dr. Siddharth Iyer teaches courses on ethics, philosophy of science, and the societal impact of technology. He holds a PhD from JNU, New Delhi.',
        teaching: [
          'HS1010: Technical Communication',
          'HS3020: Philosophy of Science',
          'HS5010: Ethics of Artificial Intelligence',
        ],
        researchGroups: [],
        additionalInformation: {
          'office_hours': 'Wednesday 10 AM - 12 PM',
          'room': 'Nila Campus, Room 108',
        },
        publications: [
          'Iyer S., "Responsible AI in Indian Higher Education", AI & Society 2025',
          'Iyer S., "Epistemic Justice in Algorithmic Systems", Philosophy & Technology 2024',
        ],
      ),
    };

    final detail = facultyDetails[slug];
    if (detail == null) {
      return ApiResponse.error(
        error: 'Faculty member not found',
        message: 'No faculty found with slug: $slug',
      );
    }

    return ApiResponse.success(
      data: detail,
      message: 'Faculty detail retrieved successfully',
    );
  }

  // ---------------------------------------------------------------------------
  // Search endpoints
  // ---------------------------------------------------------------------------

  @override
  Future<ApiResponse<SearchResult>> search({
    required String query,
    String? category,
    int? limit,
  }) async {
    await Future<void>.delayed(ApiConstants.mockNetworkDelay);

    final q = query.toLowerCase().trim();
    if (q.isEmpty) {
      return ApiResponse.success(
        data: SearchResult(
          query: query,
          category: category,
          totalCount: 0,
          results: const [],
        ),
        message: 'Empty query',
      );
    }

    final maxResults = limit ?? 20;

    // Filter by query (case-insensitive substring match on title + subtitle + description)
    var filtered = _searchableItems.where((item) {
      final haystack =
          '${item.title} ${item.subtitle} ${item.description ?? ''}'
              .toLowerCase();
      return haystack.contains(q);
    });

    // Filter by category if specified
    if (category != null) {
      final cat = SearchCategory.fromValue(category);
      if (cat != null) {
        filtered = filtered.where((item) => item.category == cat);
      }
    }

    final results = filtered.take(maxResults).toList();

    return ApiResponse.success(
      data: SearchResult(
        query: query,
        category: category,
        totalCount: results.length,
        results: results,
      ),
      message: 'Search results for "$query"',
    );
  }

  @override
  Future<ApiResponse<List<String>>> getSearchSuggestions({
    required String query,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final q = query.toLowerCase().trim();
    if (q.isEmpty) {
      // Return popular/trending suggestions when query is empty.
      return ApiResponse.success(
        data: const [
          '3D Printer',
          'Laser Cutter',
          'Soldering Station',
          'CNC Router',
          'Electric Drill',
          'ARC Welder',
        ],
        message: 'Popular suggestions',
      );
    }

    // Prefix-based matching on searchable item titles.
    final matches = _searchableItems
        .where((item) => item.title.toLowerCase().contains(q))
        .map((item) => item.title)
        .toSet() // Deduplicate
        .take(6)
        .toList();

    return ApiResponse.success(
      data: matches,
      message: 'Suggestions for "$query"',
    );
  }

  @override
  Future<ApiResponse<List<Competition>>> getCompetitions() async {
    await Future<void>.delayed(ApiConstants.mockNetworkDelay);

    return ApiResponse.success(
      data: [
        Competition(
          websiteUrl: 'https://www.droneexpo.in/',
          title: 'Drone Expo 2026',
          applyLink: 'https://www.droneexpo.in/visitor-registration',
          deadline: DateTime(2026, 4, 17),
        ),
        Competition(
          websiteUrl:
              'https://www.ursc.gov.in/IRoC-U2026/events.jsp#skipmaincontent',
          title: 'ISRO Robotics Challenge 2026',
          applyLink:
              'https://www.ursc.gov.in/IRoC-U2026/events.jsp#skipmaincontent',
          deadline: DateTime(2026, 4, 2),
        ),
        Competition(
          websiteUrl: 'https://www.safmc.com.sg/about-the-competition/',
          title: 'Singapore Amazing Flying Machine Competition',
          applyLink: 'https://www.safmc.com.sg/registration/',
          deadline: DateTime(2026, 2, 27),
        ),
        Competition(
          websiteUrl: 'https://roboclub.technoxian.com/',
          title: 'Technoxian World Robotics Championship 10.0',
          applyLink: 'https://roboclub.technoxian.com/',
          deadline: DateTime(2026, 4, 7),
        ),
      ],
      message: 'Competitions retrieved successfully',
    );
  }

  /// Mock searchable items across all categories.
  static const _searchableItems = <SearchResultItem>[
    // -- Equipment (Innovation Lab Tools) --

    // Power Tools
    SearchResultItem(
      id: 'equip-orbital-sander',
      category: SearchCategory.equipment,
      title: 'Orbital Sander',
      subtitle: 'Bosch GEX 125-1 AE',
      description:
          'Random orbital sander for fine surface finishing on wood and metal. Variable speed control with dust collection micro-filter system. Ideal for smoothing and polishing workpieces before painting or coating.',
      imageUrl: 'https://picsum.photos/seed/orbital-sander/400/300',
      metadata: {
        'make': 'Bosch',
        'model': 'GEX 125-1 AE',
        'tool_category': 'Power Tools',
        'location': 'Innovation Lab, Bay 1',
      },
    ),
    SearchResultItem(
      id: 'equip-electric-drill',
      category: SearchCategory.equipment,
      title: 'Electric Drill',
      subtitle: 'Bosch GSB 10RE',
      description:
          'Professional-grade impact drill for drilling in wood, metal, and masonry. 500W motor with variable speed and forward/reverse function. Comes with standard chuck key and auxiliary handle.',
      imageUrl: 'https://picsum.photos/seed/electric-drill/400/300',
      metadata: {
        'make': 'Bosch',
        'model': 'GSB 10RE',
        'tool_category': 'Power Tools',
        'location': 'Innovation Lab, Bay 1',
      },
    ),
    SearchResultItem(
      id: 'equip-angle-grinder',
      category: SearchCategory.equipment,
      title: 'Angle Grinder',
      subtitle: 'Bosch GWS 600',
      description:
          'Compact angle grinder for cutting, grinding, and polishing metal and stone surfaces. 670W motor with anti-vibration side handle and protective guard. Standard 100mm disc size.',
      imageUrl: 'https://picsum.photos/seed/angle-grinder/400/300',
      metadata: {
        'make': 'Bosch',
        'model': 'GWS 600',
        'tool_category': 'Power Tools',
        'location': 'Innovation Lab, Bay 1',
      },
    ),
    SearchResultItem(
      id: 'equip-jigsaw',
      category: SearchCategory.equipment,
      title: 'Jigsaw',
      subtitle: 'Bosch GST 650',
      description:
          'Variable-speed jigsaw for precise curved and straight cuts in wood, metal, and plastic. 450W motor with 4-stage orbital action and SDS blade change system for quick swaps.',
      imageUrl: 'https://picsum.photos/seed/jigsaw-cutter/400/300',
      metadata: {
        'make': 'Bosch',
        'model': 'GST 650',
        'tool_category': 'Power Tools',
        'location': 'Innovation Lab, Bay 1',
      },
    ),
    SearchResultItem(
      id: 'equip-heat-gun',
      category: SearchCategory.equipment,
      title: 'Heat Gun',
      subtitle: 'Bosch GHG 180',
      description:
          'Industrial heat gun for shrink wrapping, paint stripping, and bending PVC pipes. Dual temperature settings (60°C and 600°C) with 1800W power output.',
      imageUrl: 'https://picsum.photos/seed/heat-gun/400/300',
      metadata: {
        'make': 'Bosch',
        'model': 'GHG 180',
        'tool_category': 'Power Tools',
        'location': 'Innovation Lab, Bay 2',
      },
    ),

    // Electric / CNC Tools
    SearchResultItem(
      id: 'equip-cnc-laser-cutter',
      category: SearchCategory.equipment,
      title: 'CNC Laser Cutter',
      subtitle: 'Kavone KL1060',
      description:
          'CO2 laser cutting and engraving machine with 1000x600mm work area. Cuts acrylic, MDF, plywood, leather, and fabric with precision. 80W laser tube with Ruida controller and auto-focus.',
      imageUrl: 'https://picsum.photos/seed/laser-cutter/400/300',
      metadata: {
        'make': 'Kavone',
        'model': 'KL1060',
        'tool_category': 'Electric Tools',
        'location': 'Innovation Lab, CNC Zone',
      },
    ),
    SearchResultItem(
      id: 'equip-arc-welder',
      category: SearchCategory.equipment,
      title: 'ARC Welder',
      subtitle: 'Euro GenX MMA 201XP',
      description:
          'Inverter-based MMA/ARC welding machine with 200A output. Suitable for mild steel, stainless steel, and cast iron. Features anti-stick, hot start, and arc force control for clean welds.',
      imageUrl: 'https://picsum.photos/seed/arc-welder/400/300',
      metadata: {
        'make': 'Euro',
        'model': 'GenX MMA 201XP',
        'tool_category': 'Electric Tools',
        'location': 'Innovation Lab, Welding Bay',
      },
    ),
    SearchResultItem(
      id: 'equip-cnc-router',
      category: SearchCategory.equipment,
      title: 'CNC Router',
      subtitle: 'BobsCNC Evolution 4',
      description:
          'Desktop CNC router for precision milling of wood, acrylic, and soft metals. 450x390mm work area with 85mm Z-axis clearance. Uses standard GRBL firmware compatible with most CAM software.',
      imageUrl: 'https://picsum.photos/seed/cnc-router/400/300',
      metadata: {
        'make': 'BobsCNC',
        'model': 'Evolution 4',
        'tool_category': 'Electric Tools',
        'location': 'Innovation Lab, CNC Zone',
      },
    ),
    SearchResultItem(
      id: 'equip-pcb-mill',
      category: SearchCategory.equipment,
      title: 'PCB Milling Machine',
      subtitle: 'Bantam Tools Desktop PCB Mill',
      description:
          'Precision PCB prototyping mill for single and double-sided circuit boards. Software-guided alignment and automatic tool change. Supports FR-1 and FR-4 substrates.',
      imageUrl: 'https://picsum.photos/seed/pcb-mill/400/300',
      metadata: {
        'make': 'Bantam Tools',
        'model': 'Desktop PCB Milling Machine',
        'tool_category': 'Electric Tools',
        'location': 'Innovation Lab, Electronics Bench',
      },
    ),
    SearchResultItem(
      id: 'equip-soldering-station',
      category: SearchCategory.equipment,
      title: 'Soldering Station',
      subtitle: 'Hakko FX-888D',
      description:
          'Digital soldering station with 70W ceramic heater for quick heat recovery. Adjustable temperature from 200°C to 480°C. Includes T18 series tip and heat-resistant pad.',
      imageUrl: 'https://picsum.photos/seed/soldering-station/400/300',
      metadata: {
        'make': 'Hakko',
        'model': 'FX-888D',
        'tool_category': 'Electric Tools',
        'location': 'Innovation Lab, Electronics Bench',
      },
    ),

    // 3D Tools
    SearchResultItem(
      id: 'equip-sla-3d-printer',
      category: SearchCategory.equipment,
      title: 'SLA 3D Printer',
      subtitle: 'Prusa Original SL1',
      description:
          'Resin-based stereolithography 3D printer for high-detail prototypes and miniatures. 120x68x150mm build volume with 25-100 micron layer height. Uses 405nm UV LED array for precise curing.',
      imageUrl: 'https://picsum.photos/seed/sla-printer/400/300',
      metadata: {
        'make': 'Prusa',
        'model': 'Original Prusa SL1',
        'tool_category': '3D Tools',
        'location': 'Innovation Lab, 3D Print Station',
      },
    ),
    SearchResultItem(
      id: 'equip-fdm-3d-printer',
      category: SearchCategory.equipment,
      title: 'FDM 3D Printer',
      subtitle: 'Ultimaker 3',
      description:
          'Dual-extrusion FDM 3D printer for functional prototypes and production parts. 215x215x200mm build volume with PVA water-soluble support material. Compatible with PLA, ABS, Nylon, CPE, and more.',
      imageUrl: 'https://picsum.photos/seed/fdm-printer/400/300',
      metadata: {
        'make': 'Ultimaker',
        'model': 'Ultimaker 3',
        'tool_category': '3D Tools',
        'location': 'Innovation Lab, 3D Print Station',
      },
    ),
    SearchResultItem(
      id: 'equip-3d-scanner',
      category: SearchCategory.equipment,
      title: '3D Scanner',
      subtitle: 'Creality CR-Scan 01',
      description:
          'Portable structured-light 3D scanner for reverse engineering and quality inspection. 0.1mm accuracy with turntable mode for small objects. Exports STL and OBJ formats for direct 3D printing.',
      imageUrl: 'https://picsum.photos/seed/3d-scanner/400/300',
      metadata: {
        'make': 'Creality',
        'model': 'CR-Scan 01',
        'tool_category': '3D Tools',
        'location': 'Innovation Lab, 3D Print Station',
      },
    ),
    SearchResultItem(
      id: 'equip-3d-pen',
      category: SearchCategory.equipment,
      title: '3D Printing Pen',
      subtitle: '3Doodler Create+',
      description:
          'Handheld 3D printing pen for freeform prototyping, repairs, and artistic projects. Works with PLA and ABS filaments at adjustable speeds. Great for quick concept visualization.',
      imageUrl: 'https://picsum.photos/seed/3d-pen/400/300',
      metadata: {
        'make': '3Doodler',
        'model': 'Create+',
        'tool_category': '3D Tools',
        'location': 'Innovation Lab, 3D Print Station',
      },
    ),

    // -- People (Faculty) --
    SearchResultItem(
      id: 'dr-biju-paul',
      category: SearchCategory.people,
      title: 'Dr. Biju Paul',
      subtitle: 'Associate Professor, CSE',
      description: 'Research: Network Security, Cryptography, Cloud Computing',
      metadata: {
        'slug': 'dr-biju-paul',
        'department': 'Computer Science and Engineering',
      },
    ),
    SearchResultItem(
      id: 'dr-sahely-bhadra',
      category: SearchCategory.people,
      title: 'Dr. Sahely Bhadra',
      subtitle: 'Associate Professor, CSE',
      description: 'Research: Kernel Methods, Optimization, Bioinformatics',
      imageUrl: 'https://iitpkd.ac.in/sites/default/files/facpic/sahely.jpg',
      metadata: {
        'slug': 'dr-sahely-bhadra',
        'department': 'Computer Science and Engineering',
      },
    ),
    SearchResultItem(
      id: 'dr-vineeth-balasubramanian',
      category: SearchCategory.people,
      title: 'Dr. Vineeth Balasubramanian',
      subtitle: 'Assistant Professor, CSE',
      description:
          'Research: Computer Vision, Deep Learning, Pattern Recognition',
      metadata: {
        'slug': 'dr-vineeth-balasubramanian',
        'department': 'Computer Science and Engineering',
      },
    ),
    SearchResultItem(
      id: 'dr-krithika-ramalingam',
      category: SearchCategory.people,
      title: 'Dr. Krithika Ramalingam',
      subtitle: 'Associate Professor, ME',
      description:
          'Research: Computational Fluid Dynamics, Thermal Engineering',
      metadata: {
        'slug': 'dr-krithika-ramalingam',
        'department': 'Mechanical Engineering',
      },
    ),
    SearchResultItem(
      id: 'dr-rajesh-nair',
      category: SearchCategory.people,
      title: 'Dr. Rajesh Nair',
      subtitle: 'Professor, Physics',
      description:
          'Research: Quantum Computing, Condensed Matter, Quantum Information',
      metadata: {'slug': 'dr-rajesh-nair', 'department': 'Physics'},
    ),
    SearchResultItem(
      id: 'dr-ananya-sharma',
      category: SearchCategory.people,
      title: 'Dr. Ananya Sharma',
      subtitle: 'Assistant Professor, Chemistry',
      description: 'Research: Organic Chemistry, Green Chemistry, Catalysis',
      metadata: {'slug': 'dr-ananya-sharma', 'department': 'Chemistry'},
    ),
    SearchResultItem(
      id: 'dr-priya-menon',
      category: SearchCategory.people,
      title: 'Dr. Priya Menon',
      subtitle: 'Associate Professor, Mathematics',
      description: 'Research: Number Theory, Algebraic Geometry, Cryptography',
      metadata: {'slug': 'dr-priya-menon', 'department': 'Mathematics'},
    ),
    SearchResultItem(
      id: 'dr-siddharth-iyer',
      category: SearchCategory.people,
      title: 'Dr. Siddharth Iyer',
      subtitle: 'Assistant Professor, HSS',
      description: 'Research: Philosophy of Science, Ethics of AI',
      metadata: {
        'slug': 'dr-siddharth-iyer',
        'department': 'Humanities and Social Sciences',
      },
    ),

    // -- Labs --
    SearchResultItem(
      id: 'lab-cs-programming',
      category: SearchCategory.labs,
      title: 'Computer Programming Lab',
      subtitle: 'B-Block, Room 101, Sahyadri Campus',
      description:
          'General purpose programming lab with 60 workstations. Used for CS1010, CS2010 lab sessions.',
      metadata: {
        'location': 'B-Block, Room 101',
        'capacity': '60',
        'campus': 'Sahyadri',
      },
    ),
    SearchResultItem(
      id: 'lab-networking',
      category: SearchCategory.labs,
      title: 'Networking Lab',
      subtitle: 'B-Block, Room 102, Sahyadri Campus',
      description:
          'Equipped with routers, switches, and packet analyzers for CS4050 Computer Networks coursework.',
      metadata: {
        'location': 'B-Block, Room 102',
        'capacity': '40',
        'campus': 'Sahyadri',
      },
    ),
    SearchResultItem(
      id: 'lab-ai-robotics',
      category: SearchCategory.labs,
      title: 'AI & Robotics Lab',
      subtitle: 'A-Block, Room 310, Nila Campus',
      description:
          'Research lab with GPU workstations, robotic arms, and sensor kits. Headed by CSE faculty.',
      metadata: {'location': 'A-Block, Room 310', 'campus': 'Nila'},
    ),
    SearchResultItem(
      id: 'lab-physics',
      category: SearchCategory.labs,
      title: 'Physics Lab',
      subtitle: 'A-Block, Room 201, Nila Campus',
      description:
          'Undergraduate physics experiments and demonstrations. Used for PH1010 lab sessions.',
      metadata: {
        'location': 'A-Block, Room 201',
        'capacity': '50',
        'campus': 'Nila',
      },
    ),
    SearchResultItem(
      id: 'lab-chemistry',
      category: SearchCategory.labs,
      title: 'Chemistry Lab',
      subtitle: 'A-Block, Room 202, Nila Campus',
      description:
          'Wet lab for organic and inorganic experiments. Fume hoods and analytical instruments available.',
      metadata: {
        'location': 'A-Block, Room 202',
        'capacity': '45',
        'campus': 'Nila',
      },
    ),
    SearchResultItem(
      id: 'lab-thermal-fluids',
      category: SearchCategory.labs,
      title: 'Thermal & Fluid Sciences Lab',
      subtitle: 'Sahyadri Campus, Room 305',
      description:
          'Research lab for computational fluid dynamics and heat transfer experiments.',
      metadata: {'location': 'Room 305', 'campus': 'Sahyadri'},
    ),
    SearchResultItem(
      id: 'lab-electronics',
      category: SearchCategory.labs,
      title: 'Electronics Workshop',
      subtitle: 'B-Block, Room 201, Sahyadri Campus',
      description:
          'Hands-on electronics lab with oscilloscopes, signal generators, and soldering stations.',
      metadata: {
        'location': 'B-Block, Room 201',
        'capacity': '40',
        'campus': 'Sahyadri',
      },
    ),

    // -- Schedules --
    SearchResultItem(
      id: 'schedule-shuttle',
      category: SearchCategory.schedules,
      title: 'Shuttle Schedule',
      subtitle: 'Campus bus timings',
      description:
          'Daily shuttle service between Nila Campus, Sahyadri Campus, and City Center. Runs on weekdays.',
      metadata: {
        'route': 'Nila - Sahyadri - City Center',
        'frequency': 'Every 30-60 minutes',
      },
    ),
    SearchResultItem(
      id: 'schedule-mess',
      category: SearchCategory.schedules,
      title: 'Mess Menu',
      subtitle: '14-day rotating meal schedule',
      description:
          'Breakfast, lunch, snacks, and dinner menu for Nila Campus mess. Two-week rotation cycle.',
      metadata: {'campus': 'Nila', 'cycle': '14-day rotation'},
    ),
    SearchResultItem(
      id: 'schedule-library-hours',
      category: SearchCategory.schedules,
      title: 'Library Hours',
      subtitle: 'Central Library timings',
      description:
          'Weekdays: 8 AM - 10 PM. Weekends: 9 AM - 6 PM. Extended hours during exam season.',
      metadata: {
        'weekday': '8:00 AM - 10:00 PM',
        'weekend': '9:00 AM - 6:00 PM',
      },
    ),
    SearchResultItem(
      id: 'schedule-sports',
      category: SearchCategory.schedules,
      title: 'Sports Complex Hours',
      subtitle: 'Gym and courts timings',
      description:
          'Gym: 6 AM - 9 PM daily. Badminton courts: slot-based booking via campus portal.',
      metadata: {'gym': '6:00 AM - 9:00 PM', 'courts': 'Slot-based booking'},
    ),
  ];

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
        dinner: [
          'Chapati',
          'Butter Chicken Gravy (Veg)',
          'Rice',
          'Gulab Jamun',
        ],
      ),
    ),
  ];
}
