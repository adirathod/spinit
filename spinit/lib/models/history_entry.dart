class HistoryEntry {
  final String id;
  final String wheelName;
  final String resultLabel;
  final String resultColor;
  final String timestamp;

  const HistoryEntry({
    required this.id,
    required this.wheelName,
    required this.resultLabel,
    required this.resultColor,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'wheelName': wheelName,
        'resultLabel': resultLabel,
        'resultColor': resultColor,
        'timestamp': timestamp,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        id: json['id'] as String,
        wheelName: json['wheelName'] as String,
        resultLabel: json['resultLabel'] as String,
        resultColor: json['resultColor'] as String,
        timestamp: json['timestamp'] as String,
      );
}
