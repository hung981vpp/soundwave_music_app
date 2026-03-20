import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/discover_provider.dart';
import '../../providers/player_provider.dart';
import '../../models/song.dart';
import 'now_playing_screen.dart';

class ArtistScreen extends StatefulWidget {
  final String name;
  final String avatarUrl;

  const ArtistScreen({
    super.key,
    required this.name,
    this.avatarUrl = '',
  });

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoverProvider>().loadArtistProfile(widget.name);
    });
  }

  void _playSong(Song song, {List<Song>? queue}) {
    context.read<PlayerProvider>().playSong(song, queue: queue);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => NowPlayingScreen(song: song),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 360),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discover = context.watch<DiscoverProvider>();
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: discover.loadingArtist
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF5500)))
          : _buildProfile(discover, player),
    );
  }

  Widget _buildProfile(DiscoverProvider discover, PlayerProvider player) {
    final tracks = discover.artistTracks;

    return CustomScrollView(
      slivers: [
        // ── Hero Header ──
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: const Color(0xFF0D0D0D),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Avatar blurred background
                widget.avatarUrl.isNotEmpty
                    ? Image.network(
                        widget.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: const Color(0xFF1A1A1A)),
                      )
                    : Container(color: const Color(0xFF1A1A1A)),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.9),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
                // Artist info
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFFF5500), width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5500).withOpacity(0.4),
                              blurRadius: 16,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: widget.avatarUrl.isNotEmpty
                              ? Image.network(widget.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white54, size: 36))
                              : const Icon(Icons.person,
                                  color: Colors.white54, size: 36),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Tracks Title ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bài hát',
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                Text('${tracks.length} tracks',
                    style: GoogleFonts.nunito(
                        color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
        ),

        // ── Track list ──
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final track = tracks[index];
              final isPlaying =
                  player.currentSong?.filePath == track.filePath &&
                      player.isPlaying;
              return _ArtistTrackTile(
                track: track,
                index: index,
                isPlaying: isPlaying,
                onTap: () => _playSong(track, queue: tracks),
              );
            },
            childCount: tracks.length,
          ),
        ),

        if (tracks.isEmpty && !discover.loadingArtist)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text('Không có bài hát nào',
                    style: GoogleFonts.nunito(
                        color: Colors.white38, fontSize: 14)),
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }
}

class _ArtistTrackTile extends StatelessWidget {
  final Song track;
  final int index;
  final bool isPlaying;
  final VoidCallback onTap;

  const _ArtistTrackTile({
    required this.track,
    required this.index,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: isPlaying
            ? const Color(0xFFFF5500).withOpacity(0.08)
            : Colors.transparent,
        child: Row(
          children: [
            Text(
              '${index + 1}'.padLeft(2, '0'),
              style: GoogleFonts.nunito(
                  color: isPlaying
                      ? const Color(0xFFFF5500)
                      : Colors.white24,
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 14),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF2A2A2A)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: track.coverImage.isNotEmpty
                    ? Image.network(track.coverImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.music_note,
                            color: Colors.white24,
                            size: 20))
                    : const Icon(Icons.music_note,
                        color: Colors.white24, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        color: isPlaying
                            ? const Color(0xFFFF5500)
                            : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
            if (isPlaying)
              const _MiniWave()
            else
              const Icon(Icons.play_arrow, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}

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
        vsync: this, duration: const Duration(milliseconds: 700))
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
          final h = 5.0 + 9.0 * ((_ctrl.value + i * 0.33) % 1.0);
          return Container(
            width: 3,
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
