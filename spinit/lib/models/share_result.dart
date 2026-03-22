class ShareResult {
  final String shareCode;
  final DateTime expiresAt;

  ShareResult({required this.shareCode, required this.expiresAt});

  factory ShareResult.fromJson(Map<String, dynamic> json) {
    return ShareResult(
      shareCode: json['share_code'],
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}
