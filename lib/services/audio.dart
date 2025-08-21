import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService();
  final AudioPlayer _player = AudioPlayer();

  Future<void> playPath(String path, {bool loop = true, bool gradual = true}) async {
    await _player.stop();
    await _player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
    double volume = gradual ? 0.0 : 1.0;
    await _player.setVolume(volume);
    await _player.play(DeviceFileSource(path));
    if (gradual) {
      Timer.periodic(const Duration(milliseconds: 300), (t) async {
        volume += 0.1;
        if (volume >= 1.0) {
          volume = 1.0;
          t.cancel();
        }
        await _player.setVolume(volume);
      });
    }
  }

  Future<void> stop() => _player.stop();
}


