class Destination {
  final String name;
  final double latitude;
  final double longitude;

  Destination({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      name: json['display_name'] ?? json['name'] ?? '',
      latitude: double.tryParse(json['lat'].toString()) ?? 0.0,
      longitude: double.tryParse(json['lon'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': latitude,
      'lon': longitude,
    };
  }
}
