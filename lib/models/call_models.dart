class CallResponse {
  final String message;
  final String hostUrl;
  final String guestUrl;

  CallResponse({
    required this.message,
    required this.hostUrl,
    required this.guestUrl,
  });

  factory CallResponse.fromJson(Map<String, dynamic> json) {
    return CallResponse(
      message: json['message'],
      hostUrl: json['host_url'],
      guestUrl: json['guest_url'],
    );
  }
}
