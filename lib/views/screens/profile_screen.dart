import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/song_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_colors.dart';
import 'login_screen.dart';
import 'profile_detail_screen.dart';
import 'notifications_screen.dart';
import 'privacy_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final songProvider = context.watch<SongProvider>();
    final player = context.watch<PlayerProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final email = auth.currentUser?.email ?? 'Người dùng';
    final pName = auth.currentUser?.displayName;
    final username = (pName != null && pName.isNotEmpty) ? pName : email.split('@').first;

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
                      color: AppColors.brand.withOpacity(0.1),
                      gradient: auth.avatarBase64 == null ? const LinearGradient(
                        colors: [Color(0xFFFF5500), Color(0xFFCA2C92)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ) : null,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5500).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                      image: auth.avatarBase64 != null
                          ? DecorationImage(
                              image: MemoryImage(base64Decode(auth.avatarBase64!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: auth.avatarBase64 == null ? Center(
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
                    ) : null,
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
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileDetailScreen()));
                  },
                ),
                _Tile(
                  icon: Icons.notifications_outlined,
                  label: 'Thông báo',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                  },
                ),
                _Tile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Riêng tư & Bảo mật',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen()));
                  },
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
                  onTap: () {
                    _showAppRatingDialog(context);
                  },
                ),
                _Tile(
                  icon: Icons.help_outline_rounded,
                  label: 'Trợ giúp & Hỗ trợ',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                  },
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

  void _showAudioQualityDialog(BuildContext context, ThemeProvider themeProvider) {
    final c = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: c.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Chất lượng âm thanh',
                    style: GoogleFonts.nunito(
                        color: c.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              _QualityTile(
                label: 'Thấp',
                description: 'Tiết kiệm dữ liệu (96 kbps)',
                quality: AudioQuality.low,
                selected: themeProvider.audioQuality,
                onTap: () {
                  themeProvider.setAudioQuality(AudioQuality.low);
                  Navigator.pop(ctx);
                },
              ),
              _QualityTile(
                label: 'Trung bình',
                description: 'Cân bằng (160 kbps)',
                quality: AudioQuality.medium,
                selected: themeProvider.audioQuality,
                onTap: () {
                  themeProvider.setAudioQuality(AudioQuality.medium);
                  Navigator.pop(ctx);
                },
              ),
              _QualityTile(
                label: 'Cao',
                description: 'Âm thanh sắc nét (320 kbps)',
                quality: AudioQuality.high,
                selected: themeProvider.audioQuality,
                onTap: () {
                  themeProvider.setAudioQuality(AudioQuality.high);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAppRatingDialog(BuildContext context) {
    final c = AppColors.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.surface1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Center(
          child: Column(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFF5500), size: 48),
              const SizedBox(height: 12),
              Text('Đánh giá ứng dụng',
                  style: GoogleFonts.nunito(color: c.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
        content: Text('Bạn có thích SoundWave không? Đánh giá 5 sao trên cửa hàng ứng dụng để ủng hộ chúng tôi nhé!',
            style: GoogleFonts.nunito(color: c.textSecondary, fontSize: 14), textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Để sau', style: GoogleFonts.nunito(color: c.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cảm ơn bạn đã phản hồi!', style: GoogleFonts.nunito()),
                  backgroundColor: const Color(0xFFFF5500),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Đánh giá ngay', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
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
