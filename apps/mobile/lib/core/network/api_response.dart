/// Generic wrapper for all API responses from the backend.
///
/// The backend returns a standardized JSON structure:
/// ```json
/// {
///   "success": <bool>,
///   "message": <string?>,
///   "error": <string?>,
///   "data": <dynamic?>
/// }
/// ```
class ApiResponse<T> {
  final bool success;
  final String? message;
  final String? error;
  final T? data;

  const ApiResponse({
    required this.success,
    this.message,
    this.error,
    this.data,
  });

  /// Parses a raw JSON map into an [ApiResponse<T>].
  ///
  /// [fromJsonT] converts the raw `data` field into the desired type [T].
  /// If `data` is null, [fromJsonT] is not called and [data] remains null.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String?,
      error: json['error'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  /// Convenience constructor for a successful response.
  factory ApiResponse.success({T? data, String? message}) {
    return ApiResponse<T>(success: true, message: message, data: data);
  }

  /// Convenience constructor for an error response.
  factory ApiResponse.error({required String error, String? message}) {
    return ApiResponse<T>(success: false, error: error, message: message);
  }

  /// Whether this response indicates a failure.
  bool get isError => !success;
}
