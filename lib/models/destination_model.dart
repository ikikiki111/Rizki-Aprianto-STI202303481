class Destination {
  final int? id;
  final String name;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final String? imagePath;
  final DateTime? visitDate;
  final String? visitTime;
  final DateTime createdAt;

  Destination({
    this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.imagePath,
    this.visitDate,
    this.visitTime,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': imagePath,
      'visitDate': visitDate?.toIso8601String(),
      'visitTime': visitTime,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      location: map['location'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      imagePath: map['imagePath'],
      visitDate: map['visitDate'] != null
          ? DateTime.parse(map['visitDate'])
          : null,
      visitTime: map['visitTime'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Destination copyWith({
    int? id,
    String? name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    String? imagePath,
    DateTime? visitDate,
    String? visitTime,
    DateTime? createdAt,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imagePath: imagePath ?? this.imagePath,
      visitDate: visitDate ?? this.visitDate,
      visitTime: visitTime ?? this.visitTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
