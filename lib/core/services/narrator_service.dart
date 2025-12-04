import 'package:flutter_tts/flutter_tts.dart';
import 'package:kamino_fr/features/2_home/data/narrator_repository.dart';

class NarratorService {
  final NarratorRepository repository;
  final FlutterTts _tts;
  bool _configured = false;

  NarratorService({required this.repository, FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    try {
      await _tts.setLanguage('es-MX');
    } catch (_) {}
    try {
      final langs = await _tts.getLanguages;
      if (langs is List) {
        if (!langs.contains('es-MX')) {
          if (langs.contains('es-ES')) {
            await _tts.setLanguage('es-ES');
          } else if (langs.contains('es-US')) {
            await _tts.setLanguage('es-US');
          } else if (langs.any((l) => l.toString().startsWith('es'))) {
            final firstEs = langs.firstWhere((l) => l.toString().startsWith('es')); 
            await _tts.setLanguage(firstEs.toString());
          }
        }
      }
    } catch (_) {}
    await _tts.setSpeechRate(0.5);
    try { await _tts.setVolume(1.0); } catch (_) {}
    try { await _tts.setPitch(1.0); } catch (_) {}
    try {
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {}
    try {
      await _tts.setEngine('com.google.android.tts');
    } catch (_) {}
    try {
      final voices = await _tts.getVoices;
      if (voices is List) {
        Map<String, String>? candidate;
        for (final v in voices) {
          if (v is Map) {
            final locale = v['locale']?.toString() ?? '';
            final name = v['name']?.toString();
            if (locale.startsWith('es') && name != null && name.isNotEmpty) {
              candidate = {'name': name, 'locale': locale};
              break;
            }
          }
        }
        if (candidate != null) {
          await _tts.setVoice(candidate);
        }
      }
    } catch (_) {}
    _configured = true;
  }

  Future<bool> narratePlace(String placeId) async {
    await _ensureConfigured();
    final text = await repository.fetchNarrative(placeId);
    if (text == null) return false;
    final norm = _normalize(text);
    if (norm.isEmpty) return false;
    try {
      await _tts.stop();
      await _speakChunked(norm);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> speak(String text) async {
    await _ensureConfigured();
    final norm = _normalize(text);
    if (norm.isEmpty) return;
    try {
      await _tts.stop();
      await _speakChunked(norm);
    } catch (_) {}
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  String _normalize(String input) {
    final t = input.replaceAll('\n', ' ').replaceAll('\r', ' ').trim();
    return t;
  }

  Future<void> _speakChunked(String text) async {
    final chunks = _splitIntoChunks(text, 600);
    for (final c in chunks) {
      if (c.trim().isEmpty) continue;
      await _tts.speak(c);
    }
  }

  List<String> _splitIntoChunks(String text, int maxLen) {
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    final out = <String>[];
    var current = StringBuffer();
    for (final s in sentences) {
      if (current.length + s.length + 1 > maxLen) {
        out.add(current.toString());
        current = StringBuffer();
      }
      if (current.isNotEmpty) current.write(' ');
      current.write(s);
    }
    final last = current.toString();
    if (last.trim().isNotEmpty) out.add(last);
    return out;
  }
}
