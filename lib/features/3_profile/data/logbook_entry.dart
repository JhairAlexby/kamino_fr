class LogbookEntry {
  final String id;
  final String placeId;
  final String placeName;
  final String placeImageUrl;
  final DateTime date;
  final String notes;

  LogbookEntry({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.placeImageUrl,
    required this.date,
    required this.notes,
  });
}