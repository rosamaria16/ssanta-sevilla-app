import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'api_service.dart';

class RadioPlayerController extends ChangeNotifier {
  RadioPlayerController._internal() {
    _player.playerStateStream.listen((_) {
      notifyListeners();
    });
  }
  static final RadioPlayerController _instance = RadioPlayerController._internal();
  factory RadioPlayerController() => _instance;

  final AudioPlayer _player = AudioPlayer();
  Emisora? _currentEmisora;

  Emisora? get currentEmisora => _currentEmisora;
  bool get isPlaying => _player.playing;

  Future<void> play(Emisora emisora) async {
    _currentEmisora = emisora;
    notifyListeners();
    await _player.setUrl(emisora.urlStream);
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentEmisora = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
