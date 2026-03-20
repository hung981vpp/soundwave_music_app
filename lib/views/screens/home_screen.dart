import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/song_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/home_provider.dart';
import '../../models/song.dart';
import '../../widgets/mini_player.dart';
import '../../utils/app_colors.dart';
import 'now_playing_screen.dart';
import 'discover_screen.dart';
import 'artist_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final homeProvider = context.read<HomeProvider>();
      final songProvider = context.read<SongProvider>();
      await songProvider.loadSongs();
      await homeProvider.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();

    // Khi bài đổi → load related
    final song = playerProvider.currentSong;
    if (song != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HomeProvider>().loadRelatedFor(song.artist);
      });
    }

    final List<Widget> bodies = [
      const _HomeBody(),      // 0 – Home
      const DiscoverScreen(), // 1 – Khám phá
      const SearchScreen(),   // 2 – Tìm kiếm
      const LibraryScreen(),  // 3 – Thư viện
      const ProfileScreen(),  // 4 – Tôi
    ];

    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: bodies[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playerProvider.currentSong != null)
            MiniPlayer(
              onTap: () => Navigator.push(
                context,
                _slideUp(NowPlayingScreen(song: playerProvider.currentSong!)),
              ),
            ),
          NavigationBar(
            selectedIndex: _currentIndex,
            backgroundColor: c.navBg,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.brand.withOpacity(0.15),
            height: 60,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (i) {
              setState(() => _currentIndex = i);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, size: 22),
                selectedIcon: Icon(Icons.home_rounded, size: 22),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined, size: 22),
                selectedIcon: Icon(Icons.explore_rounded, size: 22),
                label: 'Khám phá',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined, size: 22),
                selectedIcon: Icon(Icons.search_rounded, size: 22),
                label: 'Tìm kiếm',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined, size: 22),
                selectedIcon: Icon(Icons.library_music_rounded, size: 22),
                label: 'Thư viện',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, size: 22),
                selectedIcon: Icon(Icons.person_rounded, size: 22),
                label: 'Tôi',
              ),
            ],
          ),
        ],
      ),
    );
  }

  PageRouteBuilder _slideUp(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 380),
      );
}

// ── Home Body ─────────────────────────────────────────────────────────────
class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final song = context.read<SongProvider>();
    final player = context.watch<PlayerProvider>();

    return CustomScrollView(
      slivers: [
        // ── Top App Bar ──
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.of(context).bg,
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5500),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.graphic_eq,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Text('SoundWave',
                  style: GoogleFonts.nunito(
                      color: AppColors.of(context).textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          actions: const [
            SizedBox(width: 8),
          ],
        ),

        // ── 🎵 "Your Library" Banner ──────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: _LibraryBanner(songs: song.songs, player: player),
          ),
        ),

        // ── Recent small cards (2xN grid) ────────────────────────────────
        if (home.recentSongs.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: _RecentGrid(
                  songs: home.recentSongs, player: player),
            ),
          ),

        // ── "More of what you like" ───────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 20, 14, 8),
            child: Text('Có thể bạn thích',
                style: GoogleFonts.nunito(
                  color: AppColors.of(context).textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                )),
          ),
        ),

        if (home.loadingTrending)
          const SliverToBoxAdapter(
              child: _LoadingRow())
        else if (home.trendingTracks.isNotEmpty)
          SliverToBoxAdapter(
            child: _TrendingGrid(
              tracks: home.trendingTracks,
              player: player,
              onPlay: (t) => _playSong(context, t, trackList: home.trendingTracks),
              onArtist: (t) => _openArtist(context, t),
            ),
          ),

        // ── "Mixed for you" ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Mixes dành cho bạn',
            onSeeAll: null,
          ),
        ),

        if (home.loadingMixes)
          const SliverToBoxAdapter(child: _LoadingRow())
        else if (home.mixes.isNotEmpty)
          SliverToBoxAdapter(
            child: _MixesRow(
              mixes: home.mixes,
              player: player,
              onPlay: (t, mixTracks) => _playSong(context, t, trackList: mixTracks),
            ),
          ),

        // ── Related tracks ────────────────────────────────────────────────
        if (home.relatedTracks.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Vì bạn nghe ${home.relatedArtist}',
              onSeeAll: null,
            ),
          ),
          SliverToBoxAdapter(
            child: _HorizontalTrackList(
              tracks: home.relatedTracks,
              player: player,
              onPlay: (t) => _playSong(context, t, trackList: home.relatedTracks),
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  void _playSong(BuildContext context, Song track, {List<Song>? trackList}) {
    context.read<PlayerProvider>().playSong(track, queue: trackList);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => NowPlayingScreen(song: track),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _openArtist(BuildContext context, Song track) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ArtistScreen(
          name: track.artist,
        ),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

// ── Library Banner ─────────────────────────────────────────────────────────
class _LibraryBanner extends StatelessWidget {
  final List<Song> songs;
  final PlayerProvider player;
  const _LibraryBanner({required this.songs, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF3D1A00), Color(0xFF1A0A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Vinyl art ở bên trái
          Positioned(
            left: -6,
            top: -6,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFFF5500).withOpacity(0.6),
                  Colors.black.withOpacity(0.85),
                ]),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5500).withOpacity(0.3),
                    blurRadius: 16,
                  )
                ],
              ),
              child: const Icon(Icons.album_rounded,
                  color: Color(0xFFFF7722), size: 36),
            ),
          ),
          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(left: 88, right: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Thư viện của bạn',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            )),
                        Text('${songs.length} bài hát đã lưu',
                            style: GoogleFonts.nunito(
                                color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  // Shuffle button
                  GestureDetector(
                    onTap: () {
                      if (songs.isNotEmpty) {
                        final playerProvider = context.read<PlayerProvider>();
                        // Tạo queue shuffle
                        final shuffled = List.of(songs)..shuffle();
                        final song = shuffled.first;
                        
                        // Phát bài đầu tiên với queue đã shuffle
                        playerProvider.playSong(song, queue: shuffled);
                        
                        // Bật chế độ shuffle
                        if (!playerProvider.isShuffle) {
                          playerProvider.toggleShuffle();
                        }
                        
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                NowPlayingScreen(song: song),
                            transitionsBuilder: (_, a, __, child) =>
                                FadeTransition(opacity: a, child: child),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.15)),
                      ),
                      child: const Icon(Icons.shuffle_rounded,
                          color: Colors.white70, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Grid (2 columns) ────────────────────────────────────────────────
class _RecentGrid extends StatelessWidget {
  final List<Song> songs;
  final PlayerProvider player;
  const _RecentGrid({required this.songs, required this.player});

  @override
  Widget build(BuildContext context) {
    final items = songs.take(6).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final song = items[i];
        final isPlaying = player.currentSong?.filePath == song.filePath &&
            player.isPlaying;
        return GestureDetector(
          onTap: () {
            context.read<PlayerProvider>().playSong(song);
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => NowPlayingScreen(song: song),
                transitionsBuilder: (_, a, __, child) =>
                    FadeTransition(opacity: a, child: child),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isPlaying
                  ? AppColors.brand.withOpacity(0.15)
                  : AppColors.of(context).surface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPlaying
                    ? const Color(0xFFFF5500).withOpacity(0.4)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  child: song.coverImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: song.coverImage,
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              const _Placeholder(size: 46),
                        )
                      : const _Placeholder(size: 46),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    song.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: isPlaying
                          ? AppColors.brand
                          : AppColors.of(context).textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isPlaying)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: _MiniWave(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title,
                style: GoogleFonts.nunito(
                  color: AppColors.of(context).textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                )),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text('Xem tất cả',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFFFF5500),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  )),
            ),
        ],
      ),
    );
  }
}

// ── Trending 3-col grid ────────────────────────────────────────────────────
class _TrendingGrid extends StatelessWidget {
  final List<Song> tracks;
  final PlayerProvider player;
  final void Function(Song) onPlay;
  final void Function(Song) onArtist;
  const _TrendingGrid(
      {required this.tracks,
      required this.player,
      required this.onPlay,
      required this.onArtist});

  @override
  Widget build(BuildContext context) {
    final items = tracks.take(9).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 10,
          childAspectRatio: 0.72,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final track = items[i];
          final isPlaying = player.currentSong?.filePath == track.filePath;
          return GestureDetector(
            onTap: () => onPlay(track),
            onLongPress: () => onArtist(track),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF2A2A2A),
                      boxShadow: isPlaying
                          ? [
                              BoxShadow(
                                color:
                                    const Color(0xFFFF5500).withOpacity(0.5),
                                blurRadius: 14,
                              )
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          track.coverImage.isNotEmpty
                              ? Image.network(track.coverImage,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (_, __, ___) =>
                                      const _Placeholder())
                              : const _Placeholder(),
                          if (isPlaying && player.isPlaying)
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5500),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _MiniWaveWhite(),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: isPlaying
                          ? AppColors.brand
                          : AppColors.of(context).textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    )),
                Text(track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                        color: AppColors.of(context).textTertiary, fontSize: 10)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Mixes Row ──────────────────────────────────────────────────────────────
class _MixesRow extends StatelessWidget {
  final List<List<Song>> mixes;
  final PlayerProvider player;
  final void Function(Song, List<Song>) onPlay;

  static const _mixLabels = ['MIX 1', 'MIX 2', 'MIX 3'];
  static const _mixColors = [
    Color(0xFFFF5500),
    Color(0xFF6200EA),
    Color(0xFF00796B),
  ];
  static const _mixSubtitles = [
    'Chill Pop · Indie',
    'Electronic · House',
    'Lo-Fi · Jazz',
  ];

  const _MixesRow(
      {required this.mixes, required this.player, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: mixes.length.clamp(0, 3),
        itemBuilder: (context, i) {
          final mix = mixes[i];
          if (mix.isEmpty) return const SizedBox.shrink();
          final isPlaying = mix.any((t) =>
              player.currentSong?.filePath == t.filePath &&
              player.isPlaying);

          return GestureDetector(
            onTap: () => onPlay(mix.first, mix),
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2x2 mosaic cover
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF2A2A2A),
                        boxShadow: isPlaying
                            ? [
                                BoxShadow(
                                  color: _mixColors[i].withOpacity(0.45),
                                  blurRadius: 14,
                                )
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            // 4-image grid
                            GridView.count(
                              crossAxisCount: 2,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              children: mix
                                  .take(4)
                                  .map((t) => t.coverImage.isNotEmpty
                                      ? Image.network(t.coverImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                  color:
                                                      const Color(0xFF2A2A2A)))
                                      : Container(
                                          color: const Color(0xFF2A2A2A)))
                                  .toList(),
                            ),
                            // MIX label overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      _mixColors[i].withOpacity(0.85),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Text(
                                  _mixLabels[i],
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            if (isPlaying)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: _mixColors[i],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const _MiniWaveWhite(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_mixSubtitles[i],
                      style: GoogleFonts.nunito(
                          color: AppColors.of(context).textSecondary, fontSize: 10)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Horizontal track list ─────────────────────────────────────────────────
class _HorizontalTrackList extends StatelessWidget {
  final List<Song> tracks;
  final PlayerProvider player;
  final void Function(Song) onPlay;

  const _HorizontalTrackList(
      {required this.tracks, required this.player, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: tracks.length,
        itemBuilder: (context, i) {
          final track = tracks[i];
          final isPlaying = player.currentSong?.filePath == track.filePath;
          return GestureDetector(
            onTap: () => onPlay(track),
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF2A2A2A),
                      boxShadow: isPlaying
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF5500).withOpacity(0.4),
                                blurRadius: 12,
                              )
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: track.coverImage.isNotEmpty
                          ? Image.network(track.coverImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) =>
                                  const _Placeholder())
                          : const _Placeholder(),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        color: isPlaying
                            ? const Color(0xFFFF5500)
                            : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      )),
                  Text(track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                          color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Loading Row ────────────────────────────────────────────────────────────
class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
            child: CircularProgressIndicator(
                color: Color(0xFFFF5500), strokeWidth: 2)),
      );
}

// ── Cover Placeholder ─────────────────────────────────────────────────────
class _Placeholder extends StatelessWidget {
  final double? size;
  const _Placeholder({this.size});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Container(
          color: const Color(0xFF2A2A2A),
          child: const Icon(Icons.music_note, color: Colors.white12, size: 22),
        ),
      );
}

// ── Mini Wave (orange) ────────────────────────────────────────────────────
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

// ── Mini Wave (white – for overlays) ─────────────────────────────────────
class _MiniWaveWhite extends StatefulWidget {
  const _MiniWaveWhite();

  @override
  State<_MiniWaveWhite> createState() => _MiniWaveWhiteState();
}

class _MiniWaveWhiteState extends State<_MiniWaveWhite>
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
