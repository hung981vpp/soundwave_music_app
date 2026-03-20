import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';


class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Queue state
  List<Song> _originalQueue = [];
  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isShuffle = false;
  bool _isRepeat = false;

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  List<Song> get queue => _queue;
  bool get isShuffle => _isShuffle;
  bool get isRepeat => _isRepeat;

  PlayerProvider() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      // Auto play next song when completed
      if (state.processingState == ProcessingState.completed) {
        if (_isRepeat) {
          seekTo(Duration.zero);
          _audioPlayer.play();
        } else {
          next();
        }
      }
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((pos) {
      _position = pos;
    });

    _audioPlayer.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
    });
  }

  // --- Core Playback ---

  Future<void> playSong(Song song, {List<Song>? queue}) async {
    _currentSong = song;

    if (queue != null && queue.isNotEmpty) {
      _originalQueue = List.from(queue);
      if (_isShuffle) {
        _queue = List.from(_originalQueue)..shuffle(Random());
        // Đảm bảo bài hát hiện tại ở đầu queue nếu shuffle
        _queue.removeWhere((s) => s.filePath == song.filePath);
        _queue.insert(0, song);
      } else {
        _queue = List.from(_originalQueue);
      }
      _currentIndex = _queue.indexWhere((s) => s.filePath == song.filePath);
      if (_currentIndex == -1) {
         _queue.insert(0, song);
         _currentIndex = 0;
      }
    } else {
      // Phát 1 bài lẻ (hoặc search list) -> tạo queue 1 bài để không lỗi
      _originalQueue = [song];
      _queue = [song];
      _currentIndex = 0;
    }
    
    notifyListeners();
    await _playCurrent();
  }

  int _playRequestId = 0;

  Future<void> _playCurrent() async {
    if (_currentSong == null) return;
    
    final requestId = ++_playRequestId;
    try {
      if (_currentSong!.filePath.startsWith('assets/')) {
        await _audioPlayer.setAsset(_currentSong!.filePath);
        if (_playRequestId == requestId) {
          await _audioPlayer.play();
        }
      } else {
        await _audioPlayer.setUrl(_currentSong!.filePath);
        if (_playRequestId == requestId) {
          await _audioPlayer.play();
        }
      }
    } catch (e) {
      print('=== Lỗi phát nhạc: $e');
      
      // Không tự nhảy bài nếu người dùng vừa mới bấm chuyển qua bài khác
      if (_playRequestId == requestId) {
        final errorStr = e.toString().toLowerCase();
        // Bỏ qua lỗi do kết nối bị hủy (vì người dùng tua nhanh qua bài khác)
        if (!errorStr.contains('abort') && !errorStr.contains('cancel')) {
          if (_queue.length > 1) {
            await Future.delayed(const Duration(milliseconds: 500));
            // Kiểm tra lại lần nữa vì có thể trong 500ms người dùng đã bấm chuyển
            if (_playRequestId == requestId) {
              next();
            }
          }
        }
      }
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentSong = null;
    _currentIndex = -1;
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // --- Queue Controls ---

  Future<void> next() async {
    if (_queue.isEmpty || _queue.length == 1) {
      // Nếu chỉ có 1 bài, replay lại
      await seekTo(Duration.zero);
      if (!_isPlaying) {
        await _audioPlayer.play();
      }
      return;
    }
    
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
    } else {
      // Quay vòng về đầu
      _currentIndex = 0;
    }
    
    _currentSong = _queue[_currentIndex];
    notifyListeners();
    await _playCurrent();
  }

  Future<void> prev() async {
    if (_queue.isEmpty) return;
    
    // Nếu đang phát quá 3s thì lùi về đầu bài
    if (_position.inSeconds > 3) {
      await seekTo(Duration.zero);
      return;
    }
    
    if (_queue.length == 1) {
      // Nếu chỉ có 1 bài, replay lại
      await seekTo(Duration.zero);
      if (!_isPlaying) {
        await _audioPlayer.play();
      }
      return;
    }
    
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _queue.length - 1; // Về bài cuối
    }
    
    _currentSong = _queue[_currentIndex];
    notifyListeners();
    await _playCurrent();
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    if (_isShuffle) {
      final current = _currentSong;
      _queue = List.from(_originalQueue)..shuffle(Random());
      if (current != null) {
        _queue.removeWhere((s) => s.filePath == current.filePath);
        _queue.insert(0, current);
        _currentIndex = 0;
      }
    } else {
      _queue = List.from(_originalQueue);
      if (_currentSong != null) {
        _currentIndex = _queue.indexWhere((s) => s.filePath == _currentSong!.filePath);
      }
    }
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
