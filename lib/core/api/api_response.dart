class ApiResponse {
  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
    this.nextClaim,
  });

  final bool success;
  final String message;
  final dynamic data;
  final String? nextClaim;

  factory ApiResponse.fromJson(Map<String, dynamic>? json) {
    final rawSuccess = json?['success'];
    final success = rawSuccess is bool
        ? rawSuccess
        : rawSuccess?.toString().toLowerCase() == 'true';

    return ApiResponse(
      success: success,
      message: json?['message']?.toString() ?? '',
      data: json?['data'],
      nextClaim: json?['next_claim']?.toString(),
    );
  }
}
