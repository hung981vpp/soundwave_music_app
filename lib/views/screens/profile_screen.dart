import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/song_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_colors.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final songProvider = context.watch<SongProvider>();
    final player = context.watch<PlayerProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final email = auth.currentUser?.email ?? 'Người dùng';
    final username = email.split('@').first;

    return Scaffold(
      backgroundColor: AppColors.of(context).bg,
      body: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.of(context).isDark
                        ? const Color(0xFF1A0A00)
                        : const Color(0xFFFFF0EA),
                    AppColors.of(context).bg,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5500), Color(0xFFCA2C92)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5500).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        username.isNotEmpty
                            ? username[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    username,
                    style: GoogleFonts.nunito(
                      color: AppColors.of(context).textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: GoogleFonts.nunito(
                        color: AppColors.of(context).textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Stat(
                          label: 'Bài hát',
                          value: '${songProvider.songs.length}'),
                      _divider(context),
                      const _Stat(label: 'Follows', value: '–'),
                      _divider(context),
                      const _Stat(label: 'Followers', value: '–'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Status bar (đang phát) ──
          if (player.currentSong != null)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5500).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFFF5500).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.graphic_eq_rounded,
                        color: Color(0xFFFF5500), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Đang phát',
                              style: GoogleFonts.nunito(
                                  color: const Color(0xFFFF5500),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                          Text(
                            player.currentSong!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                                color: AppColors.of(context).textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Account section ──
          SliverToBoxAdapter(
            child: _Section(
              title: 'Tài khoản',
              children: [
                _Tile(
                  icon: Icons.person_outline_rounded,
                  label: 'Hồ sơ',
                  onTap: () {},
                ),
                _Tile(
                  icon: Icons.notifications_outlined,
                  label: 'Thông báo',
                  onTap: () {},
                ),
                _Tile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Riêng tư & Bảo mật',
                  onTap: () {},
                ),
              ],
            ),
          ),

          // ── App settings section ──
          SliverToBoxAdapter(
            child: _Section(
              title: 'Ứng dụng',
              children: [
                // Dark mode toggle – kết nối ThemeProvider
                _Tile(
                  icon: Icons.dark_mode_outlined,
                  label: 'Giao diện tối',
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeColor: const Color(0xFFFF5500),
                  ),
                  onTap: () => themeProvider.toggleTheme(),
                ),
                // Audio quality – mở dialog chọn
                _Tile(
                  icon: Icons.high_quality_outlined,
                  label: 'Chất lượng âm thanh',
                  subtitle: themeProvider.audioQualityLabel,
                  onTap: () => _showAudioQualityDialog(context, themeProvider),
                ),
                // WiFi-only download toggle
                _Tile(
                  icon: Icons.wifi_outlined,
                  label: 'Tải về bằng WiFi',
                  trailing: Switch(
                    value: themeProvider.wifiOnly,
                    onChanged: (_) => themeProvider.toggleWifiOnly(),
                    activeColor: const Color(0xFFFF5500),
                  ),
                  onTap: () => themeProvider.toggleWifiOnly(),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: _Section(
              title: 'Thông tin',
              children: [
                _Tile(
                  icon: Icons.info_outline_rounded,
                  label: 'Phiên bản',
                  subtitle: '1.0.0',
                  onTap: () {},
                ),
                _Tile(
                  icon: Icons.star_outline_rounded,
                  label: 'Đánh giá ứng dụng',
                  onTap: () {},
                ),
                _Tile(
                  icon: Icons.help_outline_rounded,
                  label: 'Trợ giúp & Hỗ trợ',
                  onTap: () {},
                ),
              ],
            ),
          ),

          // ── Logout ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: GestureDetector(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.of(context).surface1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: Text('Đăng xuất',
                          style: GoogleFonts.nunito(
                              color: AppColors.of(context).textPrimary,
                              fontWeight: FontWeight.w700)),
                      content: Text('Bạn có chắc muốn đăng xuất?',
                          style: GoogleFonts.nunito(
                              color: AppColors.of(context).textSecondary)),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: Text('Huỷ',
                              style: GoogleFonts.nunito(
                                  color: AppColors.of(context).textSecondary)),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, true),
                          child: Text('Đăng xuất',
                              style: GoogleFonts.nunito(
                                  color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      );
                    }
                  }
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.red.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 10),
                      Text('Đăng xuất',
                          style: GoogleFonts.nunito(
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: AppColors.of(context).divider);

  void _showAudioQualityDialog(
      BuildContext context, ThemeProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.of(context).surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
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
              child: Text('Chất lượng âm thanh',
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            _QualityTile(
              label: 'Thấp',
              description: 'Tiết kiệm data, chất lượng cơ bản',
              quality: AudioQuality.low,
              selected: provider.audioQuality,
              onTap: () {
                provider.setAudioQuality(AudioQuality.low);
                Navigator.pop(ctx);
              },
            ),
            _QualityTile(
              label: 'Trung bình',
              description: 'Cân bằng giữa chất lượng và data',
              quality: AudioQuality.medium,
              selected: provider.audioQuality,
              onTap: () {
                provider.setAudioQuality(AudioQuality.medium);
                Navigator.pop(ctx);
              },
            ),
            _QualityTile(
              label: 'Cao',
              description: 'Âm thanh tốt nhất, tốn nhiều data hơn',
              quality: AudioQuality.high,
              selected: provider.audioQuality,
              onTap: () {
                provider.setAudioQuality(AudioQuality.high);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Quality Tile ────────────────────────────────────────────────────────────
class _QualityTile extends StatelessWidget {
  final String label;
  final String description;
  final AudioQuality quality;
  final AudioQuality selected;
  final VoidCallback onTap;

  const _QualityTile({
    required this.label,
    required this.description,
    required this.quality,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = quality == selected;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.nunito(
                          color: isSelected
                              ? AppColors.brand
                              : AppColors.of(context).textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  Text(description,
                      style: GoogleFonts.nunito(
                          color: AppColors.of(context).textTertiary, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFFFF5500), size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Stat widget ───────────────────────────────────────────────────────────
class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.nunito(
                color: AppColors.of(context).textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        Text(label,
            style:
                GoogleFonts.nunito(color: AppColors.of(context).textSecondary, fontSize: 11)),
      ],
    );
  }
}

// ── Section ───────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(title.toUpperCase(),
                style: GoogleFonts.nunito(
                    color: AppColors.of(context).textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2)),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.of(context).surface1,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────
class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  const _Tile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.of(context).textSecondary, size: 22),
      title: Text(label,
          style: GoogleFonts.nunito(
              color: AppColors.of(context).textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style:
                  GoogleFonts.nunito(color: AppColors.of(context).textTertiary, fontSize: 11))
          : null,
      trailing: trailing ??
          Icon(Icons.chevron_right_rounded,
              color: AppColors.of(context).textDisabled, size: 20),
    );
  }
}
