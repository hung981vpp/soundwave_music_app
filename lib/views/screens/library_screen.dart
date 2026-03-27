import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/song_provider.dart';
import '../../providers/player_provider.dart';
import '../../models/song.dart';
import '../../utils/app_colors.dart';
import 'now_playing_screen.dart';
import 'playlist_manager_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SongProvider>().loadSongs();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = context.watch<SongProvider>();
    final player = context.watch<PlayerProvider>();
    return Scaffold(
      backgroundColor: AppColors.of(context).bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.of(context).bg,
            title: Text('Thư viện',
                style: GoogleFonts.nunito(
                    color: AppColors.of(context).textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),

            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: AppColors.brand,
              indicatorWeight: 3,
              dividerColor: Colors.transparent,
              labelColor: AppColors.of(context).textPrimary,
              unselectedLabelColor: AppColors.of(context).textTertiary,
              labelStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700, fontSize: 14),
              unselectedLabelStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.w500, fontSize: 14),
              tabs: const [
                Tab(text: 'Đã thích'),
                Tab(text: 'Danh sách phát'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // ── Tab 1: Songs ──
            _buildSongsTab(context, songProvider, player),
            // ── Tab 2: Playlists ──
            const PlaylistManagerScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsTab(BuildContext context, SongProvider songProvider, PlayerProvider player) {
    if (songProvider.isLoading) {
      return const Center(
          child: CircularProgressIndicator(
              color: Color(0xFFFF5500), strokeWidth: 2));
    }
    if (songProvider.songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.library_music_outlined,
                color: Colors.white12, size: 60),
            const SizedBox(height: 14),
            Text('Chưa có bài hát nào',
                style: GoogleFonts.nunito(
                    color: AppColors.of(context).textTertiary, fontSize: 15)),
            const SizedBox(height: 8),
            Text('Khám phá và lưu nhạc từ SoundWave',
                style: GoogleFonts.nunito(
                    color: AppColors.of(context).textDisabled, fontSize: 12)),
          ],
        ),
      );
    }

    final songs = songProvider.songs;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: songs.length,
      itemBuilder: (context, i) {
        final song = songs[i];
        final isPlaying =
            player.currentSong?.filePath == song.filePath &&
                player.isPlaying;

        return _LibrarySongTile(
          song: song,
          index: i,
          isPlaying: isPlaying,
          onPlay: () {
            player.playSong(song);
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => NowPlayingScreen(song: song),
                transitionsBuilder: (_, a, __, child) => SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0, 1), end: Offset.zero)
                      .animate(CurvedAnimation(
                          parent: a, curve: Curves.easeOutCubic)),
                  child: child,
                ),
                transitionDuration: const Duration(milliseconds: 350),
              ),
            );
          },
          onRemove: () => songProvider.removeSong(song),
        );
      },
    );
  }
}

// ── Library Song Tile ──────────────────────────────────────────────────────
class _LibrarySongTile extends StatelessWidget {
  final Song song;
  final int index;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onRemove;

  const _LibrarySongTile({
    required this.song,
    required this.index,
    required this.isPlaying,
    required this.onPlay,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: isPlaying
            ? AppColors.brand.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlaying
              ? AppColors.brand.withOpacity(0.35)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Number / waveform
          SizedBox(
            width: 28,
            child: isPlaying
                ? const _MiniWave()
                : Text('${index + 1}'.padLeft(2, '0'),
                    style: GoogleFonts.nunito(
                        color: AppColors.of(context).textTertiary, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          // Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: song.coverImage.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: song.coverImage,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _ph(context))
                : _ph(context),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: GestureDetector(
              onTap: onPlay,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        color: isPlaying
                            ? AppColors.brand
                            : AppColors.of(context).textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      )),
                  Text(song.artist,
                      maxLines: 1,
                      style: GoogleFonts.nunito(
                          color: AppColors.of(context).textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ),
          // More
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                color: AppColors.of(context).textTertiary, size: 20),
            color: AppColors.of(context).surface2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (v) {
              if (v == 'play') onPlay();
              if (v == 'remove') onRemove();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'play',
                child: Row(children: [
                  const Icon(Icons.play_arrow_rounded,
                      color: Color(0xFFFF5500)),
                  const SizedBox(width: 8),
                  Text('Phát ngay',
                      style: GoogleFonts.nunito(color: Colors.white)),
                ]),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Row(children: [
                  const Icon(Icons.delete_outline,
                      color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text('Xóa khỏi thư viện',
                      style:
                          GoogleFonts.nunito(color: Colors.redAccent)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ph(BuildContext context) => Container(
      width: 48,
      height: 48,
      color: AppColors.of(context).surface3,
      child: Icon(Icons.music_note, color: AppColors.of(context).textDisabled, size: 22));
}

// ── Mini Wave ──────────────────────────────────────────────────────────────
class _MiniWave extends StatefulWidget {
  const _MiniWave();

  @override
  State<_MiniWave> createState() => _MiniWaveState();
}

class _MiniWaveState extends State<_MiniWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final h = 4.0 + 8.0 * ((_ctrl.value + i * 0.33) % 1.0);
          return Container(
            width: 2.5,
            height: h,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5500),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
