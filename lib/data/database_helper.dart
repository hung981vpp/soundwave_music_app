import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/song.dart';
import '../models/playlist.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('music_app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        album TEXT,
        filePath TEXT NOT NULL,
        coverImage TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        coverImage TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE playlist_songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlistId INTEGER NOT NULL,
        songId INTEGER NOT NULL,
        orderIndex INTEGER DEFAULT 0,
        FOREIGN KEY (playlistId) REFERENCES playlists(id) ON DELETE CASCADE,
        FOREIGN KEY (songId) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');
  }

  // ───────── SONG CRUD ─────────
  Future<int> insertSong(Song song) async {
    final db = await database;
    return await db.insert('songs', song.toMap());
  }

  Future<List<Song>> getAllSongs() async {
    final db = await database;
    final maps = await db.query('songs', orderBy: 'createdAt DESC');
    return maps.map((m) => Song.fromMap(m)).toList();
  }

  Future<List<Song>> searchSongs(String query) async {
    final db = await database;
    final maps = await db.query(
      'songs',
      where: 'title LIKE ? OR artist LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((m) => Song.fromMap(m)).toList();
  }

  Future<int> updateSong(Song song) async {
    final db = await database;
    return await db.update('songs', song.toMap(),
        where: 'id = ?', whereArgs: [song.id]);
  }

  Future<int> deleteSong(int id) async {
    final db = await database;
    return await db.delete('songs', where: 'id = ?', whereArgs: [id]);
  }

  // ───────── PLAYLIST CRUD ─────────
  Future<int> insertPlaylist(Playlist playlist) async {
    final db = await database;
    return await db.insert('playlists', playlist.toMap());
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final db = await database;
    final maps = await db.query('playlists', orderBy: 'createdAt DESC');
    return maps.map((m) => Playlist.fromMap(m)).toList();
  }

  Future<int> updatePlaylist(Playlist playlist) async {
    final db = await database;
    return await db.update('playlists', playlist.toMap(),
        where: 'id = ?', whereArgs: [playlist.id]);
  }

  Future<int> deletePlaylist(int id) async {
    final db = await database;
    return await db.delete('playlists', where: 'id = ?', whereArgs: [id]);
  }

  // ───────── PLAYLIST_SONGS ─────────
  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    final db = await database;
    
    // Kiểm tra xem bài hát đã có trong playlist chưa
    final existing = await db.query(
      'playlist_songs',
      where: 'playlistId = ? AND songId = ?',
      whereArgs: [playlistId, songId],
    );
    
    if (existing.isNotEmpty) {
      print('=== Bài hát đã có trong playlist');
      return; // Không thêm nếu đã có
    }
    
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM playlist_songs WHERE playlistId = ?',
      [playlistId],
    )) ?? 0;
    
    await db.insert('playlist_songs', {
      'playlistId': playlistId,
      'songId': songId,
      'orderIndex': count,
    });
    print('=== Đã thêm bài hát vào playlist');
  }

  Future<List<Song>> getSongsInPlaylist(int playlistId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT s.* FROM songs s
      INNER JOIN playlist_songs ps ON s.id = ps.songId
      WHERE ps.playlistId = ?
      ORDER BY ps.orderIndex ASC
    ''', [playlistId]);
    return maps.map((m) => Song.fromMap(m)).toList();
  }

  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    final db = await database;
    await db.delete('playlist_songs',
        where: 'playlistId = ? AND songId = ?',
        whereArgs: [playlistId, songId]);
  }

  Future<void> insertSongIfNotExists(Song song) async {
    final db = await database;
    // Kiểm tra trùng theo filePath (URL)
    final existing = await db.query(
      'songs',
      where: 'filePath = ?',
      whereArgs: [song.filePath],
    );
    if (existing.isEmpty) {
      await db.insert('songs', song.toMap());
      print('=== Đã thêm bài hát: ${song.title}');
    } else {
      print('=== Bài hát đã tồn tại trong DB: ${song.title}');
    }
  }


  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<void> clearAllSongs() async {
  final db = await database;
  await db.delete('songs');
  print('=== Đã xóa toàn bộ songs');
}

}
