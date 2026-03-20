class Playlist {
  final int? id;
  final String name;
  final String description;
  final String coverImage;
  final String createdAt;

  Playlist({
    this.id,
    required this.name,
    this.description = '',
    this.coverImage = '',
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'coverImage': coverImage,
    'createdAt': createdAt,
  };

  factory Playlist.fromMap(Map<String, dynamic> map) => Playlist(
    id: map['id'],
    name: map['name'],
    description: map['description'] ?? '',
    coverImage: map['coverImage'] ?? '',
    createdAt: map['createdAt'],
  );
}
