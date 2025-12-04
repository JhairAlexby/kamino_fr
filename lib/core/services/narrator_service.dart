import 'package:flutter_tts/flutter_tts.dart';
import 'package:kamino_fr/features/2_home/data/narrator_repository.dart';

class NarratorService {
  final NarratorRepository repository;
  final FlutterTts _tts;
  bool _configured = false;

  NarratorService({required this.repository, FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _tts.setLanguage('es-MX');
    await _tts.setSpeechRate(0.5);
    _configured = true;
  }

  Future<bool> narratePlace(String placeId) async {
    await _ensureConfigured();
    final text = await repository.fetchNarrative(placeId);
    if (text == null || text.trim().isEmpty) return false;
    await _tts.stop();
    await _tts.speak(text);
    return true;
  }

  Future<void> speak(String text) async {
    await _ensureConfigured();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
