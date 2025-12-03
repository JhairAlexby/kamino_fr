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
  final String? narrativeStoreId;
  final String? narrativeDocumentId;
  final bool hasNarrative;
  final List<String> closedDays;
  final Map<String, DaySchedule> scheduleByDay;
  final CrowdInfo? crowdInfo;
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
    required this.narrativeStoreId,
    required this.narrativeDocumentId,
    required this.hasNarrative,
    required this.closedDays,
    required this.scheduleByDay,
    required this.crowdInfo,
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
      narrativeStoreId: json['narrativeStoreId'] as String?,
      narrativeDocumentId: json['narrativeDocumentId'] as String?,
      hasNarrative: json['hasNarrative'] as bool? ?? false,
      closedDays: (json['closedDays'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      scheduleByDay: ((json['scheduleByDay'] as Map<String, dynamic>?) ?? const {})
          .map((k, v) => MapEntry(k, DaySchedule.fromJson(v as Map<String, dynamic>))),
      crowdInfo: json['crowdInfo'] == null
          ? null
          : CrowdInfo.fromJson(json['crowdInfo'] as Map<String, dynamic>),
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
        'hasNarrative': hasNarrative,
      },
      geometry: Point(coordinates: Position(longitude, latitude)),
    );
  }
}

class DaySchedule {
  final String open;
  final String close;

  DaySchedule({required this.open, required this.close});

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      open: json['open'] as String? ?? '',
      close: json['close'] as String? ?? '',
    );
  }
}

class CrowdInfo {
  final List<String> bestDays;
  final List<String> peakDays;
  final List<String> bestHours;
  final List<String> peakHours;

  CrowdInfo({
    required this.bestDays,
    required this.peakDays,
    required this.bestHours,
    required this.peakHours,
  });

  factory CrowdInfo.fromJson(Map<String, dynamic> json) {
    return CrowdInfo(
      bestDays: (json['bestDays'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      peakDays: (json['peakDays'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      bestHours: (json['bestHours'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      peakHours: (json['peakHours'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}
