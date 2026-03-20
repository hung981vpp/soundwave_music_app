import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/genre.dart';
import '../../providers/discover_provider.dart';
import '../../providers/player_provider.dart';
import '../../models/song.dart';
import '../../utils/app_colors.dart';
import 'now_playing_screen.dart';
import 'artist_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  final _genres = AppGenre.all;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _genres.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoverProvider>().loadInitialGenres();
    });
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        final genre = _genres[_tabCtrl.index].key;
        context.read<DiscoverProvider>().loadGenre(genre);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _playSong(BuildContext context, Song track, {List<Song>? queue}) {
    context.read<PlayerProvider>().playSong(track, queue: queue);
    Navigator.push(
      context,
      _slideUp(NowPlayingScreen(song: track)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discover = context.watch<DiscoverProvider>();
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      backgroundColor: AppColors.of(context).bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          _buildAppBar(discover),
        ],
        body: _isSearching
            ? _buildSearchResults(discover, player)
            : _buildGenreTabs(discover, player),
      ),
    );
  }

  // ── App Bar with Search ──────────────────────────────────────────────────
  Widget _buildAppBar(DiscoverProvider discover) {
    return SliverAppBar(
      backgroundColor: AppColors.of(context).bg,
      floating: true,
      snap: true,
      pinned: false,
      title: _isSearching
          ? TextField(
              controller: _searchCtrl,
              autofocus: true,
              style:
                  GoogleFonts.nunito(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Tìm nghệ sĩ, bài hát, thể loại...',
                hintStyle:
                    GoogleFonts.nunito(color: AppColors.of(context).textTertiary, fontSize: 15),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (q) => discover.searchLive(q),
            )
          : Text('Khám phá',
              style: GoogleFonts.nunito(
                  color: AppColors.of(context).textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _isSearching
                  ? const Color(0xFFFF5500).withOpacity(0.2)
                  : AppColors.of(context).inputFill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: _isSearching ? const Color(0xFFFF5500) : AppColors.of(context).textPrimary,
              size: 20,
            ),
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchCtrl.clear();
                discover.searchLive('');
              }
            });
          },
        ),
        const SizedBox(width: 6),
      ],
      bottom: _isSearching
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _buildGenreTabBar(),
            ),
    );
  }

  // ── Genre Tab Bar ─────────────────────────────────────────────────────────
  Widget _buildGenreTabBar() {
    return TabBar(
      controller: _tabCtrl,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicatorColor: const Color(0xFFFF5500),
      indicatorWeight: 3,
      dividerColor: Colors.transparent,
      labelColor: AppColors.of(context).textPrimary,
      unselectedLabelColor: AppColors.of(context).textTertiary,
      labelStyle:
          GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13),
      unselectedLabelStyle:
          GoogleFonts.nunito(fontWeight: FontWeight.w500, fontSize: 13),
      tabs: _genres
          .map((g) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(g.icon, size: 16),
                    const SizedBox(width: 6),
                    Text(g.label),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // ── Genre Tabs Body ───────────────────────────────────────────────────────
  Widget _buildGenreTabs(DiscoverProvider discover, PlayerProvider player) {
    return TabBarView(
      controller: _tabCtrl,
      children: _genres.map((genre) {
        return _GenreTabContent(
          genre: genre,
          discover: discover,
          player: player,
          onPlay: (t, q) => _playSong(context, t, queue: q),
          onSave: (t) => discover.saveTrackToLibrary(t),
          onArtistTap: (name) => Navigator.push(
            context,
            _slideUp(ArtistScreen(name: name)),
          ),
        );
      }).toList(),
    );
  }

  // ── Search Results ────────────────────────────────────────────────────────
  Widget _buildSearchResults(DiscoverProvider discover, PlayerProvider player) {
    if (discover.searchLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF5500)));
    }
    if (_searchCtrl.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, color: AppColors.of(context).textDisabled, size: 60),
            const SizedBox(height: 12),
            Text('Tìm kiếm bài hát, nghệ sĩ',
                style: GoogleFonts.nunito(
                    color: AppColors.of(context).textTertiary, fontSize: 15)),
          ],
        ),
      );
    }
    if (discover.apiSearchResults.isEmpty) {
      return Center(
          child: Text('Không tìm thấy kết quả',
              style:
                  GoogleFonts.nunito(color: AppColors.of(context).textSecondary, fontSize: 15)));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: discover.apiSearchResults.length,
      itemBuilder: (context, index) {
        final track = discover.apiSearchResults[index];
        final isPlaying = player.currentSong?.filePath == track.filePath;
        return _SearchResultTile(
          track: track,
          isPlaying: isPlaying && player.isPlaying,
          onPlay: () => _playSong(context, track, queue: discover.apiSearchResults),
          onSave: () async {
            await discover.saveTrackToLibrary(track);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã thêm vào thư viện: ${track.title}',
                    style: GoogleFonts.nunito()),
                backgroundColor: const Color(0xFFFF5500),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          onArtistTap: () {
            Navigator.push(
              context,
              _slideUp(ArtistScreen(
                name: track.artist,
              )),
            );
          },
        );
      },
    );
  }

  PageRouteBuilder _slideUp(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 360),
      );
}

// ── Genre Tab Content ─────────────────────────────────────────────────────
class _GenreTabContent extends StatelessWidget {
  final AppGenre genre;
  final DiscoverProvider discover;
  final PlayerProvider player;
  final void Function(Song, List<Song>) onPlay;
  final void Function(Song) onSave;
  final void Function(String name) onArtistTap;

  const _GenreTabContent({
    required this.genre,
    required this.discover,
    required this.player,
    required this.onPlay,
    required this.onSave,
    required this.onArtistTap,
  });

  @override
  Widget build(BuildContext context) {
    if (discover.isGenreLoading(genre.key)) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF5500)));
    }

    final tracks = discover.tracksForGenre(genre.key);

    if (tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(genre.icon, color: AppColors.of(context).textDisabled, size: 48),
            const SizedBox(height: 12),
            Text('Không có kết quả cho ${genre.label}',
                style: GoogleFonts.nunito(
                    color: AppColors.of(context).textDisabled, fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.brand,
      backgroundColor: AppColors.of(context).surface1,
      onRefresh: () => discover.refreshGenre(genre.key),
      child: CustomScrollView(
        slivers: [
          // ── Genre Banner ──
          SliverToBoxAdapter(
            child: _GenreBanner(genre: genre, tracks: tracks),
          ),

          // ── Track list ──
          SliverPadding(
            padding: const EdgeInsets.only(top: 4),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = tracks[index];
                  final isPlaying =
                      player.currentSong?.filePath == track.filePath;
                  return _SearchResultTile(
                    track: track,
                    isPlaying: isPlaying && player.isPlaying,
                    onPlay: () => onPlay(track, tracks),
                    onSave: () => onSave(track),
                    onArtistTap: () => onArtistTap(track.artist),
                  );
                },
                childCount: tracks.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

// ── Genre Banner ──────────────────────────────────────────────────────────
class _GenreBanner extends StatelessWidget {
  final AppGenre genre;
  final List<Song> tracks;

  const _GenreBanner({required this.genre, required this.tracks});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _genreColors(genre.key),
        ),
      ),
      child: Stack(
        children: [
          // Artwork mosaic
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 140,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: tracks
                    .take(4)
                    .map((t) => t.coverImage.isNotEmpty
                        ? Image.network(t.coverImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.black26))
                        : Container(color: Colors.black26))
                    .toList(),
              ),
            ),
          ),
          // Gradient over mosaic
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 160,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _genreColors(genre.key).first,
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Text
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(genre.icon, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(genre.label,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    )),
                Text('${tracks.length} bài hát',
                    style: GoogleFonts.nunito(
                        color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _genreColors(String genre) {
    switch (genre) {
      case 'pop':
        return [const Color(0xFFFF5500), const Color(0xFFCA2C92)];
      case 'ballad':
        return [const Color(0xFF880E4F), const Color(0xFFAD1457)];
      case 'r%26b':
        return [const Color(0xFF4A148C), const Color(0xFF6A1B9A)];
      case 'edm':
        return [const Color(0xFF006064), const Color(0xFF1565C0)];
      case 'rap':
        return [const Color(0xFF1C1C1C), const Color(0xFF4A148C)];
      case 'lofi':
        return [const Color(0xFF3E2723), const Color(0xFF6D4C41)];
      default:
        return [const Color(0xFFFF5500), const Color(0xFF222222)];
    }
  }
}

// ── SC Track Tile ──────────────────────────────────────────────────────────
class _SearchResultTile extends StatefulWidget {
  final Song track;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onSave;
  final VoidCallback? onArtistTap;

  const _SearchResultTile({
    required this.track,
    required this.isPlaying,
    required this.onPlay,
    required this.onSave,
    this.onArtistTap,
  });

  @override
  State<_SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<_SearchResultTile> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: widget.isPlaying
            ? AppColors.brand.withOpacity(0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isPlaying
              ? AppColors.brand.withOpacity(0.35)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Cover
          GestureDetector(
            onTap: widget.onPlay,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.of(context).surface3,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: widget.track.coverImage.isNotEmpty
                    ? Image.network(
                        widget.track.coverImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.music_note,
                                color: Colors.white24, size: 22),
                      )
                    : const Icon(Icons.music_note,
                        color: Colors.white24, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: GestureDetector(
              onTap: widget.onPlay,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: widget.isPlaying
                          ? AppColors.brand
                          : AppColors.of(context).textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onArtistTap,
                    child: Row(
                      children: [
                        Text(
                          widget.track.artist,
                          style: GoogleFonts.nunito(
                            color: widget.onArtistTap != null
                                ? const Color(0xFFFF7733)
                                : Colors.white54,
                            fontSize: 12,
                            decoration: widget.onArtistTap != null
                                ? TextDecoration.underline
                                : null,
                            decorationColor: const Color(0xFFFF7733),
                          ),
                        ),
                        if (widget.track.album.isNotEmpty) ...[
                          Text(' • ',
                              style: GoogleFonts.nunito(
                                  color: Colors.white24, fontSize: 11)),
                          Text(widget.track.album,
                              style: GoogleFonts.nunito(
                                  color: Colors.white24, fontSize: 11)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Waveform or add
          if (widget.isPlaying)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: _WaveBars(),
            ),

          // More menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                color: AppColors.of(context).textTertiary, size: 20),
            color: AppColors.of(context).surface2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (val) {
              if (val == 'play') widget.onPlay();
              if (val == 'save') widget.onSave();
              if (val == 'artist' && widget.onArtistTap != null) {
                widget.onArtistTap!();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'play',
                child: Row(children: [
                  const Icon(Icons.play_arrow, color: Color(0xFFFF5500)),
                  const SizedBox(width: 8),
                  Text('Phát ngay',
                      style: GoogleFonts.nunito(color: Colors.white)),
                ]),
              ),
              PopupMenuItem(
                value: 'save',
                child: Row(children: [
                  const Icon(Icons.add_to_queue, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text('Thêm vào thư viện',
                      style: GoogleFonts.nunito(color: Colors.white)),
                ]),
              ),
              if (widget.onArtistTap != null)
                PopupMenuItem(
                  value: 'artist',
                  child: Row(children: [
                    const Icon(Icons.person, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text('Xem nghệ sĩ',
                        style: GoogleFonts.nunito(color: Colors.white)),
                  ]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Animated Wave Bars ────────────────────────────────────────────────────
class _WaveBars extends StatefulWidget {
  const _WaveBars();

  @override
  State<_WaveBars> createState() => _WaveBarsState();
}

class _WaveBarsState extends State<_WaveBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
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
          final height = 6.0 +
              12.0 *
                  (0.3 + 0.7 * ((_ctrl.value + i * 0.3) % 1.0));
          return Container(
            width: 3,
            height: height,
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
