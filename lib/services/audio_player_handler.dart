import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Wraps [AudioPlayer] with [BaseAudioHandler] so the OS media session
/// (lock-screen / notification controls) stays in sync.
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  /// Set these from [PlayerProvider] after construction.
  Future<void> Function()? onSkipNext;
  Future<void> Function()? onSkipPrevious;

  AudioPlayerHandler() {
    // Forward player state → MediaItem state
    _player.playbackEventStream.map(_buildState).pipe(playbackState);

    // Forward duration changes to mediaItem
    _player.durationStream.listen((dur) {
      final current = mediaItem.value;
      if (current != null && dur != null) {
        mediaItem.add(current.copyWith(duration: dur));
      }
    });
  }

  // ── Internal helpers ────────────────────────────────────────────────────

  PlaybackState _buildState(PlaybackEvent event) {
    final playing = _player.playing;
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  // ── BaseAudioHandler overrides ──────────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => onSkipNext?.call() ?? Future.value();

  @override
  Future<void> skipToPrevious() => onSkipPrevious?.call() ?? Future.value();

  // ── Extra methods called by PlayerProvider ──────────────────────────────

  AudioPlayer get player => _player;

  /// Load and play a URL or asset, updating the notification metadata.
  Future<void> loadAndPlay(MediaItem item, String url) async {
    mediaItem.add(item);
    if (url.startsWith('assets/')) {
      await _player.setAsset(url);
    } else {
      await _player.setUrl(url);
    }
    await _player.play();
  }
}
