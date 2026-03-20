class Song {
  final int? id;
  final String title;
  final String artist;
  final String album;
  final String filePath;   // URL SoundCloud hoặc assets path
  final String coverImage; // URL ảnh bìa hoặc assets path
  final String createdAt;

  Song({
    this.id,
    required this.title,
    required this.artist,
    this.album = '',
    required this.filePath,
    this.coverImage = '',
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'filePath': filePath,
    'coverImage': coverImage,
    'createdAt': createdAt,
  };

  factory Song.fromMap(Map<String, dynamic> map) => Song(
    id: map['id'],
    title: map['title'] ?? '',
    artist: map['artist'] ?? '',
    album: map['album'] ?? '',
    filePath: map['filePath'] ?? '',
    coverImage: map['coverImage'] ?? '',
    createdAt: map['createdAt'],
  );

  factory Song.fromFirestore(Map<String, dynamic> map, String docId) => Song(
    id: map['id'], // ID (nếu có lưu)
    title: map['title'] ?? '',
    artist: map['artist'] ?? '',
    album: map['genre'] ?? map['album'] ?? '',
    filePath: map['url'] ?? map['filePath'] ?? '',
    coverImage: map['thumbnail'] ?? map['coverImage'] ?? '',
    createdAt: map['createdAt'],
  );
}
