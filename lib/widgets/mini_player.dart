import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/player_provider.dart';
import '../utils/app_colors.dart';

class MiniPlayer extends StatefulWidget {
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.onTap});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationCtrl;

  @override
  void initState() {
    super.initState();
    _rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong!;

    if (player.isPlaying) {
      _rotationCtrl.repeat();
    } else {
      _rotationCtrl.stop();
    }

    final duration = player.duration;

    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.of(context).surface1.withOpacity(0.92),
              border: Border(
                top: BorderSide(
                    color: AppColors.of(context).subtleBorder, width: 0.5),
                left: BorderSide(
                    color: AppColors.of(context).subtleBorder, width: 0.5),
                right: BorderSide(
                    color: AppColors.of(context).subtleBorder, width: 0.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Progress bar ──
                StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final progress = duration.inMilliseconds > 0
                        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
                        : 0.0;
                    return LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFFF5500)),
                      minHeight: 2,
                    );
                  },
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      // Vinyl disc cover
                      RotationTransition(
                        turns: _rotationCtrl,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2A2A2A),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF5500).withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: song.coverImage.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: song.coverImage,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Icon(
                                        Icons.music_note,
                                        color: Colors.white24,
                                        size: 20),
                                    errorWidget: (_, __, ___) => const Icon(
                                        Icons.music_note,
                                        color: Colors.white24,
                                        size: 20),
                                  )
                                : const Icon(Icons.music_note,
                                    color: Colors.white24, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title + Artist
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                color: AppColors.of(context).textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                  color: AppColors.of(context).textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),

                      // Prev
                      GestureDetector(
                        onTap: () {
                          context.read<PlayerProvider>().prev();
                        },
                        child: Icon(Icons.skip_previous_rounded,
                            color: AppColors.of(context).textPrimary, 
                            size: 28),
                      ),
                      const SizedBox(width: 8),

                      // Play/Pause
                      GestureDetector(
                        onTap: () =>
                            context.read<PlayerProvider>().togglePlayPause(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5500),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF5500).withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            player.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Next
                      GestureDetector(
                        onTap: () {
                          context.read<PlayerProvider>().next();
                        },
                        child: Icon(Icons.skip_next_rounded,
                            color: AppColors.of(context).textPrimary,
                            size: 28),
                      ),
                      const SizedBox(width: 12),

                      // Close
                      GestureDetector(
                        onTap: () => context.read<PlayerProvider>().stop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.of(context).subtleBorder,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close,
                              color: AppColors.of(context).textSecondary, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
