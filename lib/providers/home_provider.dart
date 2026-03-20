import 'package:flutter/material.dart';
import '../data/firebase_service.dart';
import '../models/song.dart';
import '../data/database_helper.dart';

/// State quản lý cho Home Screen – trending/mixes/related
class HomeProvider extends ChangeNotifier {
  // ── Trending ("More of what you like") ──
  List<Song> _trendingTracks = [];
  bool _loadingTrending = false;

  // ── Mixes ("Mixed for you") ──
  List<List<Song>> _mixes = [];
  bool _loadingMixes = false;

  // ── Recent (local DB) ──
  List<Song> _recentSongs = [];

  // ── Related (last artist played) ──
  List<Song> _relatedTracks = [];
  String _relatedArtist = '';

  List<Song> get trendingTracks => _trendingTracks;
  bool get loadingTrending => _loadingTrending;
  List<List<Song>> get mixes => _mixes;
  bool get loadingMixes => _loadingMixes;
  List<Song> get recentSongs => _recentSongs;
  List<Song> get relatedTracks => _relatedTracks;
  String get relatedArtist => _relatedArtist;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Tải song song
    await Future.wait([
      _loadTrending(),
      _loadMixes(),
      _loadRecent(),
    ]);
  }

  Future<void> refresh() async {
    _initialized = false;
    _trendingTracks = [];
    _mixes = [];
    notifyListeners();
    await init();
  }

  // ── Trending ("Khám phá thêm") ──────────────────────────────────────────
  Future<void> _loadTrending() async {
    _loadingTrending = true;
    notifyListeners();

    try {
      // Lấy từ 3 genre hot, mỗi genre 8 tracks → shuffle → lấy 18
      final results = await Future.wait([
        FirebaseService.instance.getTrendingByGenre('Pop', limit: 8),
        FirebaseService.instance.getTrendingByGenre('Rap', limit: 8),
        FirebaseService.instance.getTrendingByGenre('EDM', limit: 8),
      ]);
      _trendingTracks = results.expand((r) => r).toList()..shuffle();
      _trendingTracks = _trendingTracks.take(18).toList();
    } catch (e) {
      print('HomeProvider._loadTrending error: $e');
    }

    _loadingTrending = false;
    notifyListeners();
  }

  // ── Mixes ────────────────────────────────────────────────────────────────
  Future<void> _loadMixes() async {
    _loadingMixes = true;
    notifyListeners();

    try {
      _mixes = await FirebaseService.instance.discoverMixes();
    } catch (e) {
      print('HomeProvider._loadMixes error: $e');
    }

    _loadingMixes = false;
    notifyListeners();
  }

  // ── Recent songs từ local DB ─────────────────────────────────────────────
  Future<void> _loadRecent() async {
    try {
      final all = await DatabaseHelper.instance.getAllSongs();
      _recentSongs = all.take(6).toList();
    } catch (e) {
      _recentSongs = [];
    }
    notifyListeners();
  }

  // ── Related tracks khi bài hát thay đổi ─────────────────────────────────
  Future<void> loadRelatedFor(String artist) async {
    if (artist == _relatedArtist || artist.isEmpty) return;
    _relatedArtist = artist;
    notifyListeners();

    try {
      _relatedTracks =
          await FirebaseService.instance.getRelatedTracks(artist, limit: 8);
    } catch (e) {
      _relatedTracks = [];
    }
    notifyListeners();
  }

  // ── Lưu track vào thư viện ───────────────────────────────────────────────
  Future<void> saveTrack(Song song) async {
    await DatabaseHelper.instance.insertSongIfNotExists(song);
    await _loadRecent();
  }
}
