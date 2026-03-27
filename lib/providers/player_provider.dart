import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/song.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

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
      // Note: we don't manually call next() on completed anymore
      // because ConcatenatingAudioSource handles playing the next track automatically!
      notifyListeners();
    });

    // Listen to OS-level or automatic track changes
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && _queue.isNotEmpty && index < _queue.length) {
        _currentIndex = index;
        _currentSong = _queue[index];
        notifyListeners();
      }
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
      _originalQueue = [song];
      _queue = [song];
      _currentIndex = 0;
    }

    notifyListeners();
    await _loadAndPlayQueue();
  }

  int _playRequestId = 0;

  Future<void> _loadAndPlayQueue() async {
    final requestId = ++_playRequestId;

    // Build the playlist for just_audio
    final audioSources = _queue.map((song) {
      final tag = MediaItem(
        id: song.filePath,
        title: song.title,
        artist: song.artist,
        album: song.album.isNotEmpty ? song.album : 'SoundWave',
        artUri: song.coverImage.isNotEmpty ? Uri.parse(song.coverImage) : null,
      );
      if (song.filePath.startsWith('assets/')) {
        return AudioSource.asset(song.filePath, tag: tag);
      } else {
        return AudioSource.uri(Uri.parse(song.filePath), tag: tag);
      }
    }).toList();

    try {
      await _playlist.clear();
      await _playlist.addAll(audioSources);

      await _audioPlayer.setAudioSource(_playlist, initialIndex: _currentIndex);
      if (_playRequestId == requestId) {
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('=== Lỗi phát nhạc: $e');
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
    if (_audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
    } else {
      if (_queue.isNotEmpty) {
        await _audioPlayer.seek(Duration.zero, index: 0);
      }
    }
    if (!_isPlaying) await _audioPlayer.play();
  }

  Future<void> prev() async {
    if (_position.inSeconds > 3) {
      await seekTo(Duration.zero);
      return;
    }
    
    if (_audioPlayer.hasPrevious) {
      await _audioPlayer.seekToPrevious();
    } else {
      if (_queue.isNotEmpty) {
        await _audioPlayer.seek(Duration.zero, index: _queue.length - 1);
      }
    }
    if (!_isPlaying) await _audioPlayer.play();
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
    
    // Re-build playlist with new order
    _loadAndPlayQueue();
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    // LoopMode.one = repeat single song. LoopMode.off = no repeat (will stop at end of ConcatenatingAudioSource)
    _audioPlayer.setLoopMode(_isRepeat ? LoopMode.one : LoopMode.all);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
