import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service Native Text-to-Speech (TTS) tanpa dependensi eksternal pihak ketiga.
/// Memanfaatkan engine TextToSpeech bawaan sistem operasi (Android / Web / Desktop).
class TtsService {
  static const MethodChannel _channel = MethodChannel('com.example.alkitabz/tts');
  static final ValueNotifier<bool> isSpeaking = ValueNotifier<bool>(false);
  static final ValueNotifier<String?> activeSpeakingKey = ValueNotifier<String?>(null);
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    _channel.invokeMethod('init').catchError((_) => null);
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onStart':
          isSpeaking.value = true;
          break;
        case 'onDone':
        case 'onError':
          isSpeaking.value = false;
          activeSpeakingKey.value = null;
          break;
      }
    });
  }

  /// Memutar suara TTS untuk teks yang diberikan.
  /// [key] menandai identifier unik (misal: 'heb_4', 'kjv_4') agar UI tombol terkait dapat merespons.
  static Future<bool> speak(String text, {required String lang, String? key}) async {
    init();
    try {
      // Jika tombol yang sama ditekan saat sedang memutar, lakukan Stop
      if (isSpeaking.value && activeSpeakingKey.value == key) {
        await stop();
        return true;
      }

      activeSpeakingKey.value = key;
      final success = await _channel.invokeMethod<bool>('speak', {
        'text': text,
        'lang': lang,
      });

      if (success == true) {
        isSpeaking.value = true;
      } else {
        isSpeaking.value = false;
        activeSpeakingKey.value = null;
      }
      return success ?? false;
    } catch (e) {
      debugPrint('TTS service speak exception: $e');
      isSpeaking.value = false;
      activeSpeakingKey.value = null;
      return false;
    }
  }

  /// Menghentikan pemutaran audio TTS.
  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } catch (_) {}
    isSpeaking.value = false;
    activeSpeakingKey.value = null;
  }

  /// Mengecek apakah voice pack bahasa tertentu tersedia di perangkat.
  static Future<bool> isLanguageAvailable(String lang) async {
    init();
    try {
      final res = await _channel.invokeMethod<bool>('isLanguageAvailable', {'lang': lang});
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Membuka halaman pengaturan Text-to-Speech bawaan Android.
  static Future<void> openTtsSettings() async {
    try {
      await _channel.invokeMethod('openTtsSettings');
    } catch (_) {}
  }
}

