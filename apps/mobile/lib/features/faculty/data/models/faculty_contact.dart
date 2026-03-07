/// Contact information for a faculty member.
///
/// Nested within [FacultyDetail]. Fields are nullable because
/// scraped data may not always have complete contact info.
class FacultyContact {
  final String? email;
  final String? phoneNumber;

  const FacultyContact({this.email, this.phoneNumber});

  factory FacultyContact.fromJson(Map<String, dynamic> json) {
    return FacultyContact(
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone_number': phoneNumber,
    };
  }
}
