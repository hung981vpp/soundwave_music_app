import 'package:flutter/material.dart';
import '../data/firebase_service.dart';
import '../data/database_helper.dart';
import '../models/song.dart';
import '../models/genre.dart';

class DiscoverProvider extends ChangeNotifier {
  // Genre → danh sách tracks
  final Map<String, List<Song>> _genreTracks = {};
  final Map<String, bool> _loadingGenres = {};

  // Artist detail
  String? _selectedArtist;
  List<Song> _artistTracks = [];
  bool _loadingArtist = false;

  // Search kết nối Database trực tiếp
  List<Song> _apiSearchResults = [];
  bool _searchLoading = false;

  // Getters
  Map<String, List<Song>> get genreTracks => _genreTracks;
  String? get selectedArtist => _selectedArtist;
  List<Song> get artistTracks => _artistTracks;
  bool get loadingArtist => _loadingArtist;
  List<Song> get apiSearchResults => _apiSearchResults;
  bool get searchLoading => _searchLoading;

  bool isGenreLoading(String genre) => _loadingGenres[genre] ?? false;
  List<Song> tracksForGenre(String genre) => _genreTracks[genre] ?? [];

  // ── Discover by Genre ─────────────────────────────────────────────────────

  /// Load tracks cho 1 genre (lazy, cached)
  Future<void> loadGenre(String genre) async {
    if (_genreTracks.containsKey(genre)) return; // cached
    _loadingGenres[genre] = true;
    notifyListeners();

    try {
      final tracks =
          await FirebaseService.instance.discoverByGenre(genre, limit: 20);
      _genreTracks[genre] = tracks;
    } catch (e) {
      _genreTracks[genre] = [];
    }

    _loadingGenres[genre] = false;
    notifyListeners();
  }

  /// Load 4 genre đầu song song khi vào Discover tab
  Future<void> loadInitialGenres() async {
    final genres = AppGenre.all.take(4).map((g) => g.key).toList();
    await Future.wait(genres.map(loadGenre));
  }

  /// Force reload genre (pull-to-refresh)
  Future<void> refreshGenre(String genre) async {
    _genreTracks.remove(genre);
    await loadGenre(genre);
  }

  // ── Artist / User ──────────────────────────────────────────────────────────

  Future<void> loadArtistProfile(String artistName) async {
    _loadingArtist = true;
    _selectedArtist = artistName;
    _artistTracks = [];
    notifyListeners();

    try {
      _artistTracks = await FirebaseService.instance.getRelatedTracks(artistName, limit: 20);
    } catch (e) {
      print('=== loadArtistProfile error: $e');
    }

    _loadingArtist = false;
    notifyListeners();
  }

  // ── Live Search (Database) ────────────────────────────────

  Future<void> searchLive(String query) async {
    if (query.isEmpty) {
      _apiSearchResults = [];
      notifyListeners();
      return;
    }
    _searchLoading = true;
    notifyListeners();

    try {
      _apiSearchResults =
          await FirebaseService.instance.searchSongs(query, limit: 20);
    } catch (e) {
      _apiSearchResults = [];
    }

    _searchLoading = false;
    notifyListeners();
  }

  // ── Save to local DB ──────────────────────────────────────────────────────

  Future<void> saveTrackToLibrary(Song song) async {
    await DatabaseHelper.instance.insertSongIfNotExists(song);
  }
}
