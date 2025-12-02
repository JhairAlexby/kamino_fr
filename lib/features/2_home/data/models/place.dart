import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class Place {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> tags;
  final double latitude;
  final double longitude;
  final String address;
  final String imageUrl;
  final bool isHiddenGem;
  final String? openingTime;
  final String? closingTime;
  final int? tourDuration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double distance;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.imageUrl,
    required this.isHiddenGem,
    required this.openingTime,
    required this.closingTime,
    required this.tourDuration,
    required this.createdAt,
    required this.updatedAt,
    required this.distance,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String? ?? '',
      imageUrl: (json['imageUrl'] as String? ?? '').trim().replaceAll('`', ''),
      isHiddenGem: json['isHiddenGem'] as bool? ?? false,
      openingTime: json['openingTime'] as String?,
      closingTime: json['closingTime'] as String?,
      tourDuration: (json['tourDuration'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
    );
  }

  Feature toFeature() {
    return Feature(
      id: id,
      properties: {
        'id': id,
        'name': name,
        'category': category,
        'address': address,
        'imageUrl': imageUrl,
        'isHiddenGem': isHiddenGem,
        'distance': distance,
      },
      geometry: Point(coordinates: Position(longitude, latitude)),
    );
  }
}
