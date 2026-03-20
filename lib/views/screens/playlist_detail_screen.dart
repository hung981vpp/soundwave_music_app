import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/playlist.dart';
import '../../models/song.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/player_provider.dart';
import '../../utils/app_colors.dart';
import 'now_playing_screen.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;
  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistProvider>().loadSongsInPlaylist(widget.playlist.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();
    final playerProvider = context.watch<PlayerProvider>();
    final songs = playlistProvider.currentPlaylistSongs;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header với cover image
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.of(context).bg,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  if (songs.isNotEmpty && songs.first.coverImage.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: songs.first.coverImage,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFF1A1A1A),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFF5500).withOpacity(0.3),
                            const Color(0xFF1A1A1A),
                          ],
                        ),
                      ),
                    ),
                  // Blur overlay
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Playlist cover
                        Center(
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: songs.isNotEmpty && songs.first.coverImage.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: songs.first.coverImage,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => _placeholderCover(),
                                    )
                                  : _placeholderCover(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Playlist name
                        Text(
                          widget.playlist.name,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Description & song count
                        Text(
                          widget.playlist.description.isNotEmpty
                              ? widget.playlist.description
                              : '${songs.length} bài hát',
                          style: GoogleFonts.nunito(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Play button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: songs.isEmpty
                          ? null
                          : () {
                              playerProvider.playSong(songs.first, queue: songs);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NowPlayingScreen(song: songs.first),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5500),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 26),
                      label: Text(
                        'Phát',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Shuffle button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: songs.isEmpty
                          ? null
                          : () {
                              final shuffled = List.of(songs)..shuffle();
                              playerProvider.playSong(shuffled.first, queue: shuffled);
                              if (!playerProvider.isShuffle) {
                                playerProvider.toggleShuffle();
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NowPlayingScreen(song: shuffled.first),
                                ),
                              );
                            },
                      icon: const Icon(Icons.shuffle_rounded, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // More options
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => _showPlaylistOptions(context),
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Songs list
          if (songs.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.music_note_outlined,
                        color: Colors.black12, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có bài hát',
                      style: GoogleFonts.nunito(
                        color: AppColors.of(context).textTertiary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thêm bài hát vào playlist',
                      style: GoogleFonts.nunito(
                        color: AppColors.of(context).textDisabled,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = songs[index];
                  final isPlaying = playerProvider.currentSong?.filePath == song.filePath &&
                      playerProvider.isPlaying;

                  return _SongTile(
                    song: song,
                    index: index,
                    isPlaying: isPlaying,
                    onTap: () {
                      playerProvider.playSong(song, queue: songs);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NowPlayingScreen(song: song),
                        ),
                      );
                    },
                    onRemove: () {
                      playlistProvider.removeSongFromPlaylist(
                        widget.playlist.id!,
                        song.id!,
                      );
                    },
                  );
                },
                childCount: songs.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _placeholderCover() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: const Icon(
        Icons.queue_music_rounded,
        color: Colors.white24,
        size: 60,
      ),
    );
  }

  void _showPlaylistOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.of(context).surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: Color(0xFFFF5500)),
              title: Text('Chỉnh sửa thông tin',
                  style: GoogleFonts.nunito(color: Colors.white, fontSize: 15)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement edit dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: Text('Xóa playlist',
                  style: GoogleFonts.nunito(color: Colors.redAccent, fontSize: 15)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.of(context).surface3,
        title: Text('Xóa playlist?',
            style: GoogleFonts.nunito(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.bold)),
        content: Text(
          'Bạn có chắc muốn xóa "${widget.playlist.name}"?',
          style: GoogleFonts.nunito(color: AppColors.of(context).textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy', style: GoogleFonts.nunito(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              context.read<PlaylistProvider>().deletePlaylist(widget.playlist.id!);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Xóa',
                style: GoogleFonts.nunito(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// Song Tile Widget
class _SongTile extends StatelessWidget {
  final Song song;
  final int index;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SongTile({
    required this.song,
    required this.index,
    required this.isPlaying,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.of(context).surface3,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: song.coverImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: song.coverImage,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.music_note,
                        color: Colors.white24,
                      ),
                    )
                  : const Icon(Icons.music_note, color: Colors.white24),
            ),
          ),
          if (isPlaying)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.graphic_eq_rounded,
                color: Color(0xFFFF5500),
                size: 24,
              ),
            ),
        ],
      ),
      title: Text(
        song.title,
        style: GoogleFonts.nunito(
          color: isPlaying ? AppColors.brand : AppColors.of(context).textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: GoogleFonts.nunito(
          color: AppColors.of(context).textSecondary,
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(Icons.remove_circle_outline, color: AppColors.of(context).textTertiary),
        onPressed: onRemove,
      ),
    );
  }
}
