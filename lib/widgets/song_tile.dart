import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/playlist_provider.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Hero(
        tag: 'cover_${song.id}',
        child: CircleAvatar(
            backgroundColor: Colors.deepPurple.shade100,
            backgroundImage: song.coverImage.isEmpty
                ? null
                : song.coverImage.startsWith('http')
                    ? NetworkImage(song.coverImage)
                    : AssetImage(song.coverImage) as ImageProvider,
            child: song.coverImage.isEmpty
                ? const Icon(Icons.music_note, color: Colors.deepPurple)
                : null,
        ),
    ),

      title: Text(
        song.title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isPlaying ? Colors.deepPurple : null,
        ),
      ),
      subtitle: Text(song.artist),
      trailing: isPlaying
          ? const Icon(Icons.equalizer, color: Colors.deepPurple)
          : IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showOptions(context),
            ),
      onTap: onTap,
    );
  }

  void _showOptions(BuildContext context) {
    final playlists = context.read<PlaylistProvider>().playlists;
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Thêm vào Playlist',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (playlists.isEmpty)
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Chưa có playlist nào'),
            )
          else
            ...playlists.map((p) => ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title: Text(p.name),
                  onTap: () {
                    context
                        .read<PlaylistProvider>()
                        .addSongToPlaylist(p.id!, song.id!);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã thêm vào ${p.name}')),
                    );
                  },
                )),
        ],
      ),
    );
  }
}
