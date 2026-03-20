import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/playlist_provider.dart';
import '../../models/playlist.dart';
import '../../utils/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'playlist_detail_screen.dart';

class PlaylistManagerScreen extends StatefulWidget {
  const PlaylistManagerScreen({super.key});

  @override
  State<PlaylistManagerScreen> createState() => _PlaylistManagerScreenState();
}

class _PlaylistManagerScreenState extends State<PlaylistManagerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistProvider>().loadPlaylists();
    });
  }

  void _showCreateDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text('Tạo Playlist mới',
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Tên Playlist',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF5500))),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Mô tả (tùy chọn)',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF5500))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                context
                    .read<PlaylistProvider>()
                    .createPlaylist(name, descCtrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tạo',
                style: TextStyle(
                    color: Color(0xFFFF5500), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(BuildContext context, Playlist playlist) {
    final c = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface1,
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
              title: Text('Chỉnh sửa',
                  style: GoogleFonts.nunito(color: AppColors.of(context).textPrimary, fontSize: 15)),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context, playlist);
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
                    content: Text('Đã sao chép link playlist "${playlist.name}"',
                        style: GoogleFonts.nunito()),
                    backgroundColor: const Color(0xFFFF5500),
                    behavior: SnackBarBehavior.floating,
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
                    content: Text('Đang tải xuống playlist "${playlist.name}"...',
                        style: GoogleFonts.nunito()),
                    backgroundColor: const Color(0xFFFF5500),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: Text('Xóa playlist',
                  style: GoogleFonts.nunito(color: Colors.redAccent, fontSize: 15)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, playlist);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Playlist playlist) {
    final nameCtrl = TextEditingController(text: playlist.name);
    final descCtrl = TextEditingController(text: playlist.description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text('Chỉnh sửa Playlist',
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Tên Playlist',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF5500))),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF5500))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                final updated = Playlist(
                  id: playlist.id,
                  name: name,
                  description: descCtrl.text.trim(),
                  coverImage: playlist.coverImage,
                  createdAt: playlist.createdAt,
                );
                context.read<PlaylistProvider>().updatePlaylist(updated);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Lưu',
                style: TextStyle(
                    color: Color(0xFFFF5500), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Playlist playlist) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text('Xóa playlist?',
            style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Bạn có chắc muốn xóa "${playlist.name}"?',
          style: GoogleFonts.nunito(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy', style: GoogleFonts.nunito(color: AppColors.of(context).textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<PlaylistProvider>().deletePlaylist(playlist.id!);
              Navigator.pop(ctx);
            },
            child: Text('Xóa',
                style: GoogleFonts.nunito(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaylistProvider>();

    return Scaffold(
      backgroundColor: AppColors.of(context).bg,
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFFFF5500), strokeWidth: 2))
          : provider.playlists.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.queue_music,
                          color: AppColors.of(context).textDisabled, size: 70),
                      const SizedBox(height: 16),
                      Text('Chưa có danh sách phát',
                          style: GoogleFonts.nunito(
                              color: AppColors.of(context).textTertiary, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: provider.playlists.length,
                  itemBuilder: (context, i) {
                    final pl = provider.playlists[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.of(context).surface2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.of(context).subtleBorder),
                        ),
                        child: pl.coverImage.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: pl.coverImage,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.music_note,
                                color: AppColors.of(context).textDisabled, size: 28),
                      ),
                      title: Text(
                        pl.name,
                        style: GoogleFonts.nunito(
                            color: AppColors.of(context).textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        pl.description.isNotEmpty
                            ? pl.description
                            : 'Playlist cá nhân',
                        style: GoogleFonts.nunito(
                            color: AppColors.of(context).textTertiary, fontSize: 13),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.more_vert,
                            color: AppColors.of(context).textSecondary),
                        onPressed: () {
                          _showPlaylistOptions(context, pl);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaylistDetailScreen(playlist: pl),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF5500),
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Tạo Playlist',
            style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ),
    );
  }
}
