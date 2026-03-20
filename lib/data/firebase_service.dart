import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();
  FirebaseService._init();

  final _db = FirebaseFirestore.instance;

  // Lấy danh sách bài hát từ Firestore
  Future<List<Song>> fetchSongs() async {
    final snapshot = await _db
        .collection('songs')
        .orderBy('title')
        .get();

    return snapshot.docs
        .map((doc) => Song.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Tìm kiếm bài hát
  Future<List<Song>> searchSongs(String query, {int limit = 20}) async {
    final snapshot = await _db.collection('songs').get();
    final allSongs = snapshot.docs.map((doc) => Song.fromFirestore(doc.data(), doc.id)).toList();
    final q = query.toLowerCase();
    return allSongs
        .where((s) => s.title.toLowerCase().contains(q) || s.artist.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }

  // Lấy theo genre
  Future<List<Song>> discoverByGenre(String genre, {int limit = 20}) async {
    final snapshot = await _db.collection('songs')
        .where('genre', isEqualTo: genre)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => Song.fromFirestore(doc.data(), doc.id)).toList();
  }

  // Lấy trending (hiện giả lập bằng việc lấy theo genre và giới hạn)
  Future<List<Song>> getTrendingByGenre(String genre, {int limit = 8}) async {
    final snapshot = await _db.collection('songs')
        .where('genre', isEqualTo: genre)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => Song.fromFirestore(doc.data(), doc.id)).toList();
  }

  // Lấy bài hát liên quan (hiện dùng cùng tác giả)
  Future<List<Song>> getRelatedTracks(String artist, {int limit = 10}) async {
    final snapshot = await _db.collection('songs')
        .where('artist', isEqualTo: artist)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => Song.fromFirestore(doc.data(), doc.id)).toList();
  }

  // Mixes
  Future<List<List<Song>>> discoverMixes() async {
    final mixGenres = [
      ['Pop', 'Indie'],          // MIX 1
      ['Electronic', 'House'],   // MIX 2
      ['Lo-Fi', 'Jazz', 'Ballad'], // MIX 3
    ];
    final results = await Future.wait(mixGenres.map((genres) async {
       List<Song> mix = [];
       for (var g in genres) {
         mix.addAll(await discoverByGenre(g, limit: 5));
       }
       mix.shuffle();
       return mix.take(10).toList();
    }));
    return results;
  }
}
