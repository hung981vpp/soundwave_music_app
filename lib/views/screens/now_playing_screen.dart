import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../../providers/player_provider.dart';
import '../../providers/song_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../widgets/marquee_widget.dart';
import '../../utils/app_colors.dart';

class NowPlayingScreen extends StatefulWidget {
  final Song song;
  const NowPlayingScreen({super.key, required this.song});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _likeCtrl;
  late final Animation<double> _likeScale;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();

    _likeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _likeCtrl, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  void _toggleLike(Song currentSong, bool isLiked) async {
    final provider = context.read<SongProvider>();
    if (isLiked) {
      // Bỏ thích
      await provider.removeSong(currentSong);
    } else {
      // Thích
      await provider.addSong(currentSong);
    }
    _likeCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _likeCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showMoreOptions(BuildContext context, Song currentSong) {
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
              leading: const Icon(Icons.playlist_add_rounded, color: Color(0xFFFF5500)),
              title: Text('Thêm vào playlist',
                  style: GoogleFonts.nunito(color: AppColors.of(context).textPrimary, fontSize: 15)),
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylistDialog(context, currentSong);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded, color: Color(0xFFFF5500)),
              title: Text('Chia sẻ',
                  style: GoogleFonts.nunito(color: AppColors.of(context).textPrimary, fontSize: 15)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đang chia sẻ "${currentSong.title}"',
                        style: GoogleFonts.nunito()),
                    backgroundColor: const Color(0xFFFF5500),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_rounded, color: Color(0xFFFF5500)),
              title: Text('Tải xuống',
                  style: GoogleFonts.nunito(color: AppColors.of(context).textPrimary, fontSize: 15)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đang tải xuống "${currentSong.title}"',
                        style: GoogleFonts.nunito()),
                    backgroundColor: const Color(0xFFFF5500),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, Song currentSong) async {
    final playlistProvider = context.read<PlaylistProvider>();
    await playlistProvider.loadPlaylists();
    
    if (!mounted) return;
    
    final playlists = playlistProvider.playlists;
    
    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chưa có playlist nào. Hãy tạo playlist trước!',
              style: GoogleFonts.nunito()),
          backgroundColor: const Color(0xFFFF5500),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Thêm vào playlist',
                style: GoogleFonts.nunito(
                  color: AppColors.of(context).textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.queue_music_rounded,
                        color: Colors.white24,
                      ),
                    ),
                    title: Text(
                      playlist.name,
                      style: GoogleFonts.nunito(
                        color: AppColors.of(context).textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      playlist.description.isNotEmpty
                          ? playlist.description
                          : 'Playlist cá nhân',
                      style: GoogleFonts.nunito(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      
                      final songProvider = context.read<SongProvider>();
                      
                      // Kiểm tra xem bài hát đã có trong thư viện chưa
                      var savedSong = songProvider.songs.firstWhere(
                        (s) => s.filePath == currentSong.filePath,
                        orElse: () => Song(
                          title: '',
                          artist: '',
                          album: '',
                          filePath: '',
                          coverImage: '',
                        ),
                      );
                      
                      // Nếu chưa có, thêm vào thư viện
                      if (savedSong.filePath.isEmpty) {
                        await songProvider.addSong(currentSong);
                        await songProvider.loadSongs(); // Reload để lấy ID
                        
                        savedSong = songProvider.songs.firstWhere(
                          (s) => s.filePath == currentSong.filePath,
                          orElse: () => currentSong,
                        );
                      }
                      
                      // Thêm vào playlist
                      if (savedSong.id != null) {
                        await playlistProvider.addSongToPlaylist(
                          playlist.id!,
                          savedSong.id!,
                        );
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đã thêm "${currentSong.title}" vào "${playlist.name}"',
                                style: GoogleFonts.nunito(),
                              ),
                              backgroundColor: const Color(0xFFFF5500),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Không thể thêm bài hát vào playlist',
                                style: GoogleFonts.nunito(),
                              ),
                              backgroundColor: Colors.redAccent,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final currentSong = player.currentSong ?? widget.song;
    final songProvider = context.watch<SongProvider>();
    final isLiked = songProvider.songs.any((s) => s.filePath == currentSong.filePath);

    final coverUrl = currentSong.coverImage;

    return Scaffold(
      body: Stack(
        children: [
          // ── Blurred background ──
          Positioned.fill(
            child: coverUrl.isNotEmpty
                ? Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: const Color(0xFF1A1A1A)),
                  )
                : Container(color: const Color(0xFF1A1A1A)),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.of(context).isDark
                        ? [
                            Colors.black.withOpacity(0.55),
                            Colors.black.withOpacity(0.92),
                          ]
                        : [
                            Colors.white.withOpacity(0.30),
                            Colors.black.withOpacity(0.75),
                          ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──
          PageView(
            physics: const BouncingScrollPhysics(),
            children: [
              // Page 1: Main Player
              SafeArea(
            child: Column(
              children: [
                // ── Top Bar ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 22),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text('ĐANG PHÁT',
                                style: GoogleFonts.nunito(
                                    color: Colors.white54,
                                    fontSize: 10,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w700)),
                            Text(
                              currentSong.album.isNotEmpty
                                  ? currentSong.album
                                  : 'SoundWave',
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.more_horiz,
                              color: Colors.white, size: 22),
                        ),
                        onPressed: () {
                          _showMoreOptions(context, currentSong);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Album Cover Art ──
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5500).withOpacity(0.25),
                        blurRadius: 40,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: coverUrl.isNotEmpty
                        ? Image.network(
                            coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF2A2A2A),
                              child: const Icon(Icons.music_note,
                                  color: Colors.white24, size: 80),
                            ),
                          )
                        : Container(
                            color: const Color(0xFF2A2A2A),
                            child: const Icon(Icons.music_note,
                                color: Colors.white24, size: 80),
                          ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Song Info + Like ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 30,
                              child: MarqueeWidget(
                                child: Text(
                                  currentSong.title,
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentSong.artist,
                              style: GoogleFonts.nunito(
                                  color: Colors.white60, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Like button
                      ScaleTransition(
                        scale: _likeScale,
                        child: GestureDetector(
                          onTap: () => _toggleLike(currentSong, isLiked),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isLiked
                                  ? const Color(0xFFFF5500).withOpacity(0.15)
                                  : Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isLiked
                                  ? const Color(0xFFFF5500)
                                  : Colors.white60,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Seek Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StreamBuilder<Duration>(
                    stream: player.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration = player.duration;
                      final progress = duration.inMilliseconds > 0
                          ? (position.inMilliseconds /
                                  duration.inMilliseconds)
                              .clamp(0.0, 1.0)
                          : 0.0;

                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFFFF5500),
                              inactiveTrackColor: Colors.white24,
                              thumbColor: Colors.white,
                              overlayColor:
                                  const Color(0xFFFF5500).withOpacity(0.2),
                              trackHeight: 3.5,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6),
                            ),
                            child: Slider(
                              value: progress,
                              onChanged: (v) {
                                final newPos = Duration(
                                  milliseconds:
                                      (v * duration.inMilliseconds).round(),
                                );
                                context
                                    .read<PlayerProvider>()
                                    .seekTo(newPos);
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(position),
                                    style: GoogleFonts.nunito(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                Text(_formatDuration(duration),
                                    style: GoogleFonts.nunito(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ── Controls ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Shuffle
                      _ControlButton(
                        icon: Icons.shuffle_rounded,
                        size: 22,
                        onTap: () => player.toggleShuffle(),
                        color: player.isShuffle ? AppColors.brand : Colors.white54,
                      ),

                      // Previous
                      _ControlButton(
                        icon: Icons.skip_previous_rounded,
                        size: 36,
                        onTap: () {
                          player.prev();
                        },
                        color: Colors.white,
                      ),

                      // Play / Pause
                      GestureDetector(
                        onTap: () => player.togglePlayPause(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFF7700),
                                Color(0xFFFF3300)
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFFFF5500).withOpacity(0.55),
                                blurRadius: 24,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            player.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),

                      // Next
                      _ControlButton(
                        icon: Icons.skip_next_rounded,
                        size: 36,
                        onTap: () {
                          player.next();
                        },
                        color: Colors.white,
                      ),

                      // Repeat
                      _ControlButton(
                        icon: Icons.repeat_rounded,
                        size: 22,
                        onTap: () => player.toggleRepeat(),
                        color: player.isRepeat ? AppColors.brand : Colors.white54,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // Page 2: Queue List
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Tiếp theo',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: player.queue.length,
                    itemBuilder: (context, index) {
                      final item = player.queue[index];
                      final isPlaying = item.filePath == player.currentSong?.filePath;
                      return ListTile(
                        onTap: () {
                           // Tùy chọn: Nhấn để phát bài trong danh sách
                           // (Phải update currentIndex, tạm thời đơn giản skip qua list)
                           player.playSong(item, queue: player.queue);
                        },
                        leading: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(item.coverImage.isNotEmpty
                                  ? item.coverImage
                                  : 'https://via.placeholder.com/150'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            color: isPlaying ? const Color(0xFFFF5500) : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          item.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                        trailing: isPlaying
                            ? const Icon(Icons.graphic_eq_rounded,
                                color: Color(0xFFFF5500), size: 20)
                            : null,
                      );
                    },
                  ),
                ), // Closes Expanded
              ],
            ),
          ),
        ],
      ), // Closes PageView
        ],
      ), // Closes Stack
    ); // Closes Scaffold
  }
}

// ── Control Button ───────────────────────────────────────────────────────
class _ControlButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final Color color;

  const _ControlButton(
      {required this.icon,
      required this.size,
      required this.onTap,
      required this.color});

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Icon(widget.icon, color: widget.color, size: widget.size),
      ),
    );
  }
}

// ── Action Chip ──────────────────────────────────────────────────────────
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 15),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
