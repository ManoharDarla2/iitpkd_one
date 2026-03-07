/// Lightweight representation of a faculty member for list views.
///
/// Maps to the response from GET /api/v1/faculty.
/// Only contains fields needed for the list/card display.
class FacultyMember {
  final String slug;
  final String name;
  final String designation;
  final String department;
  final String? imageUrl;

  const FacultyMember({
    required this.slug,
    required this.name,
    required this.designation,
    required this.department,
    this.imageUrl,
  });

  factory FacultyMember.fromJson(Map<String, dynamic> json) {
    return FacultyMember(
      slug: json['slug'] as String,
      name: json['name'] as String,
      designation: json['designation'] as String,
      department: json['department'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      'designation': designation,
      'department': department,
      'image_url': imageUrl,
    };
  }
}
