import 'package:flutter/material.dart';
import '../models/song.dart';
import '../data/database_helper.dart';

class SongProvider extends ChangeNotifier {
  List<Song> _songs = [];
  List<Song> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;

  List<Song> get songs => _songs;
  List<Song> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;

  // Load từ SQLite (nguồn chính)
  Future<void> loadSongs() async {
    _isLoading = true;
    notifyListeners();

    _songs = await DatabaseHelper.instance.getAllSongs();
    print('=== loadSongs: ${_songs.length} bài hát');

    _isLoading = false;
    notifyListeners();
  }

  // Tìm kiếm trong SQLite
  Future<void> searchSongs(String query) async {
    if (query.isEmpty) {
      _isSearching = false;
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isSearching = true;
    _searchResults = await DatabaseHelper.instance.searchSongs(query);
    notifyListeners();
  }

  Future<void> addSong(Song song) async {
    // Kiểm tra xem bài hát đã tồn tại chưa (theo filePath)
    final existing = _songs.where((s) => s.filePath == song.filePath).toList();
    if (existing.isNotEmpty) {
      print('=== Bài hát đã tồn tại: ${song.title}');
      return; // Không thêm nếu đã có
    }
    
    await DatabaseHelper.instance.insertSongIfNotExists(song);
    await loadSongs();
  }

  Future<void> updateSong(Song song) async {
    await DatabaseHelper.instance.updateSong(song);
    await loadSongs();
  }

  Future<void> deleteSong(int id) async {
    await DatabaseHelper.instance.deleteSong(id);
    await loadSongs();
  }

  Future<void> removeSong(Song song) async {
    if (song.id != null) {
      await DatabaseHelper.instance.deleteSong(song.id!);
    } else {
      // fallback: xóa theo filePath
      _songs.removeWhere((s) => s.filePath == song.filePath);
    }
    await loadSongs();
  }
}
