import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundUtils {
  static final AudioPlayer _player = AudioPlayer();

  /// Memutar suara "tit" (beep) pendek dan memberikan getaran haptic ringan
  /// Mendukung format file beep.mp3 maupun beep.wav secara otomatis
  static Future<void> playBeep() async {
    try {
      try {
        // Mencoba memutar beep.mp3 yang dimasukkan pengguna
        await _player.play(AssetSource('audio/beep.mp3'));
      } catch (mp3Error) {
        // Jika gagal atau file mp3 tidak ada di sasis asset, fallback ke beep.wav
        await _player.play(AssetSource('audio/beep.wav'));
      }
      // Menambahkan feedback haptic getar ringan untuk HP / Device
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Pengamanan jika platform tidak mendukung audio
      print("Info: Gagal memutar suara scan: $e");
    }
  }
}
