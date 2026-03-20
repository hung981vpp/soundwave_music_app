import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../data/database_helper.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Playlist> _playlists = [];
  List<Song> _currentPlaylistSongs = [];
  bool _isLoading = false;

  List<Playlist> get playlists => _playlists;
  List<Song> get currentPlaylistSongs => _currentPlaylistSongs;
  bool get isLoading => _isLoading;

  Future<void> loadPlaylists() async {
    _isLoading = true;
    notifyListeners();

    _playlists = await DatabaseHelper.instance.getAllPlaylists();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createPlaylist(String name, String description) async {
    final playlist = Playlist(name: name, description: description);
    await DatabaseHelper.instance.insertPlaylist(playlist);
    await loadPlaylists();
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    await DatabaseHelper.instance.updatePlaylist(playlist);
    await loadPlaylists();
  }

  Future<void> deletePlaylist(int id) async {
    await DatabaseHelper.instance.deletePlaylist(id);
    await loadPlaylists();
  }

  Future<void> loadSongsInPlaylist(int playlistId) async {
    _currentPlaylistSongs =
        await DatabaseHelper.instance.getSongsInPlaylist(playlistId);
    notifyListeners();
  }

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    await DatabaseHelper.instance.addSongToPlaylist(playlistId, songId);
    await loadSongsInPlaylist(playlistId);
  }

  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    await DatabaseHelper.instance.removeSongFromPlaylist(playlistId, songId);
    await loadSongsInPlaylist(playlistId);
  }
}
