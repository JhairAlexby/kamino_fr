import 'dart:convert';

class LogbookEntry {
  final String? id; // Optional for creation
  final String placeId;
  final String? placeName; // Not in API request, keep for local UI if needed
  final String? placeImageUrl; // Not in API request, keep for local UI
  final DateTime visitDate;
  final int rating;
  final String description;
  final List<String>? photos;

  LogbookEntry({
    this.id,
    required this.placeId,
    this.placeName,
    this.placeImageUrl,
    required this.visitDate,
    required this.rating,
    required this.description,
    this.photos,
  });

  LogbookEntry copyWith({
    String? id,
    String? placeId,
    String? placeName,
    String? placeImageUrl,
    DateTime? visitDate,
    int? rating,
    String? description,
    List<String>? photos,
  }) {
    return LogbookEntry(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      placeImageUrl: placeImageUrl ?? this.placeImageUrl,
      visitDate: visitDate ?? this.visitDate,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      photos: photos ?? this.photos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'placeName': placeName,
      'placeImageUrl': placeImageUrl,
      'visitDate': visitDate.toIso8601String(),
      'rating': rating,
      'description': description,
      'photos': photos,
    };
  }

  factory LogbookEntry.fromJson(Map<String, dynamic> json) {
    return LogbookEntry(
      id: json['id'] as String?,
      placeId: json['placeId'] as String,
      // placeName and placeImageUrl come from joining with Place data usually, 
      // or might be absent in raw log response. We'll handle nulls gracefully.
      placeName: json['placeName'] as String?,
      placeImageUrl: json['placeImageUrl'] as String?,
      visitDate: DateTime.parse(json['visitDate'] as String),
      rating: (json['rating'] as num).toInt(),
      description: json['description'] as String,
      photos: (json['photos'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  static String encode(List<LogbookEntry> logs) => json.encode(
    logs.map<Map<String, dynamic>>((log) => log.toJson()).toList(),
  );

  static List<LogbookEntry> decode(String logs) =>
    (json.decode(logs) as List<dynamic>)
        .map<LogbookEntry>((item) => LogbookEntry.fromJson(item))
        .toList();
}
