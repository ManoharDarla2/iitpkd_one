import 'package:iitpkd_one/features/faculty/data/models/faculty_contact.dart';

/// Full detailed profile of a faculty member.
///
/// Maps to the response from GET /api/v1/faculty/:slug.
/// Contains all available information including contact, research,
/// teaching, and publications.
class FacultyDetail {
  final String slug;
  final String name;
  final String designation;
  final String department;
  final String? imageUrl;
  final FacultyContact? contact;
  final List<String> researchAreas;
  final String? biosketch;
  final List<String> teaching;
  final List<String> researchGroups;
  final Map<String, String>? additionalInformation;
  final List<String> publications;

  const FacultyDetail({
    required this.slug,
    required this.name,
    required this.designation,
    required this.department,
    this.imageUrl,
    this.contact,
    this.researchAreas = const [],
    this.biosketch,
    this.teaching = const [],
    this.researchGroups = const [],
    this.additionalInformation,
    this.publications = const [],
  });

  factory FacultyDetail.fromJson(Map<String, dynamic> json) {
    return FacultyDetail(
      slug: json['slug'] as String,
      name: json['name'] as String,
      designation: json['designation'] as String,
      department: json['department'] as String,
      imageUrl: json['image_url'] as String?,
      contact: json['contact'] != null
          ? FacultyContact.fromJson(json['contact'] as Map<String, dynamic>)
          : null,
      researchAreas: (json['research_areas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      biosketch: json['biosketch'] as String?,
      teaching: (json['teaching'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      researchGroups: (json['research_groups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      additionalInformation:
          (json['additional_information'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as String),
      ),
      publications: (json['publications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      'designation': designation,
      'department': department,
      'image_url': imageUrl,
      'contact': contact?.toJson(),
      'research_areas': researchAreas,
      'biosketch': biosketch,
      'teaching': teaching,
      'research_groups': researchGroups,
      'additional_information': additionalInformation,
      'publications': publications,
    };
  }
}
