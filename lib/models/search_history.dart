import 'destination.dart';

class SearchHistory {
  final String id;
  final Destination destination;
  final DateTime timestamp;

  SearchHistory({
    required this.id,
    required this.destination,
    required this.timestamp,
  });

  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      id: json['id'] ?? '',
      destination: Destination.fromJson(json['destination'] ?? {}),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
