import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/firebase_service.dart';
import '../../providers/player_provider.dart';
import '../../providers/song_provider.dart';
import '../../models/song.dart';
import '../../utils/app_colors.dart';
import 'now_playing_screen.dart';
import 'artist_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;

  List<Song> _results = [];
  bool _loading = false;
  String _query = '';

  // Quick genre chips
  static const _quickGenres = [
    ('Pop', 'pop', Icons.music_note_rounded),
    ('Ballad', 'ballad', Icons.favorite_rounded),
    ('R&B', 'r&b', Icons.album_rounded),
    ('EDM', 'edm', Icons.graphic_eq_rounded),
    ('Rap', 'rap', Icons.mic_rounded),
    ('Lo-Fi', 'lofi', Icons.coffee_rounded),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String q) {
    setState(() => _query = q);
    _debounce?.cancel();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(q));
  }

  Future<void> _search(String q) async {
    final results = await FirebaseService.instance.searchSongs(q);
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  void _play(Song track) {
    final queue = _results;
    
    context.read<PlayerProvider>().playSong(track, queue: queue);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => NowPlayingScreen(song: track),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final songProvider = context.watch<SongProvider>();

    return Scaffold(
      backgroundColor: AppColors.of(context).bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.of(context).inputFill,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.of(context).subtleBorder),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search_rounded,
                        color: AppColors.of(context).textTertiary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        style: GoogleFonts.nunito(
                            color: AppColors.of(context).textPrimary, fontSize: 15),
                        decoration: InputDecoration(
                          hintText:
                              'Tìm bài hát, nghệ sĩ, thể loại...',
                          hintStyle: GoogleFonts.nunito(
                              color: AppColors.of(context).textTertiary, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: _onChanged,
                      ),
                    ),
                    if (_query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white38, size: 18),
                        onPressed: () {
                          _ctrl.clear();
                          _onChanged('');
                          _focus.unfocus();
                        },
                      ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _query.isEmpty
                  ? _buildBrowse(songProvider, player)
                  : _buildResults(player),
            ),
          ],
        ),
      ),
    );
  }

  // ── Browse view (khi chưa search) ────────────────────────────────────────
  Widget _buildBrowse(SongProvider songProvider, PlayerProvider player) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 20, 14, 10),
            child: Text('Khám phá theo thể loại',
                style: GoogleFonts.nunito(
                    color: AppColors.of(context).textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
          ),
        ),

        // Genre grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final (label, key, icon) = _quickGenres[i];
                return _GenreChip(
                  label: label,
                  icon: icon,
                  genreKey: key,
                  onTap: () {
                    _ctrl.text = key;
                    _onChanged(key);
                    _focus.requestFocus();
                  },
                );
              },
              childCount: _quickGenres.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
          ),
        ),

        // Recent from library
        if (songProvider.songs.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 24, 14, 8),
              child: Text('Trong thư viện',
                  style: GoogleFonts.nunito(
                      color: AppColors.of(context).textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final song = songProvider.songs[i];
                final isPlaying =
                    player.currentSong?.filePath == song.filePath &&
                        player.isPlaying;
                return _LocalSongTile(
                  song: song,
                  isPlaying: isPlaying,
                  onTap: () {
                    final queue = songProvider.songs;
                    context.read<PlayerProvider>().playSong(song, queue: queue);
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            NowPlayingScreen(song: song),
                        transitionsBuilder: (_, a, __, child) =>
                            SlideTransition(
                          position: Tween<Offset>(
                                  begin: const Offset(0, 1),
                                  end: Offset.zero)
                              .animate(CurvedAnimation(
                                  parent: a,
                                  curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                        transitionDuration:
                            const Duration(milliseconds: 350),
                      ),
                    );
                  },
                );
              },
              childCount: songProvider.songs.length,
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  // ── Results view ──────────────────────────────────────────────────────────
  Widget _buildResults(PlayerProvider player) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(
              color: Color(0xFFFF5500), strokeWidth: 2));
    }
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                color: Colors.black26, size: 56),
            const SizedBox(height: 12),
            Text('Không tìm thấy "$_query"',
                style: GoogleFonts.nunito(
                    color: AppColors.of(context).textTertiary, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final track = _results[i];
        final isPlaying = player.currentSong?.filePath == track.filePath &&
            player.isPlaying;
        return _SearchResultTile(
          track: track,
          isPlaying: isPlaying,
          onPlay: () => _play(track),
          onArtist: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ArtistScreen(
                name: track.artist,
              ),
              transitionsBuilder: (_, a, __, child) => SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0, 1), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: a, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Genre Chip ─────────────────────────────────────────────────────────────
class _GenreChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String genreKey;
  final VoidCallback onTap;
  const _GenreChip(
      {required this.label, required this.icon, required this.genreKey, required this.onTap});

  static const _colors = {
    'pop': [Color(0xFFFF5500), Color(0xFFCA2C92)],
    'ballad': [Color(0xFF880E4F), Color(0xFFAD1457)],
    'r&b': [Color(0xFF4A148C), Color(0xFF6A1B9A)],
    'edm': [Color(0xFF006064), Color(0xFF1565C0)],
    'rap': [Color(0xFF1C1C1C), Color(0xFF4A148C)],
    'lofi': [Color(0xFF3E2723), Color(0xFF6D4C41)],
  };

  @override
  Widget build(BuildContext context) {
    final colors = _colors[genreKey] ??
        [const Color(0xFF333333), const Color(0xFF222222)];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Local Song Tile ────────────────────────────────────────────────────────
class _LocalSongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;
  const _LocalSongTile(
      {required this.song, required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: song.coverImage.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: song.coverImage,
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _placeholder(context))
            : _placeholder(context),
      ),
      title: Text(
        song.title,
        style: GoogleFonts.nunito(
          color: isPlaying ? AppColors.brand : AppColors.of(context).textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(song.artist,
          style: GoogleFonts.nunito(color: AppColors.of(context).textSecondary, fontSize: 12),
          maxLines: 1),
      trailing: const Icon(Icons.bookmark,
          color: Color(0xFFFF5500), size: 16),
      onTap: onTap,
    );
  }

  Widget _placeholder(BuildContext context) => Container(
      width: 46,
      height: 46,
      color: AppColors.of(context).surface3,
      child: Icon(Icons.music_note, color: AppColors.of(context).textDisabled, size: 20));
}

// ── SC Result Tile ─────────────────────────────────────────────────────────
class _SearchResultTile extends StatelessWidget {
  final Song track;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onArtist;
  const _SearchResultTile(
      {required this.track,
      required this.isPlaying,
      required this.onPlay,
      required this.onArtist});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: isPlaying
            ? const Color(0xFFFF5500).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlaying
              ? const Color(0xFFFF5500).withOpacity(0.35)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPlay,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF2A2A2A),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: track.coverImage.isNotEmpty
                    ? Image.network(track.coverImage, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _artPlaceholder(context))
                    : _artPlaceholder(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onPlay,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        color: isPlaying
                            ? AppColors.brand
                            : AppColors.of(context).textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      )),
                  GestureDetector(
                    onTap: onArtist,
                    child: Text(track.artist,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFFFF7733),
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFFFF7733),
                        )),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                color: AppColors.of(context).textTertiary, size: 20),
            color: AppColors.of(context).surface2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (v) {
              if (v == 'play') onPlay();
              if (v == 'artist') onArtist();
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
                value: 'artist',
                child: Row(children: [
                  const Icon(Icons.person_rounded, color: Colors.white70),
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

  Widget _artPlaceholder(BuildContext context) => Container(
      color: AppColors.of(context).surface3,
      child: Icon(Icons.music_note, color: AppColors.of(context).textDisabled, size: 22));
}
