import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0D0D0D),
            floating: true,
            title: Text('Cài đặt',
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account section
                  _SettingsSection(title: 'Tài khoản', children: [
                    _SettingsTile(
                      icon: Icons.person_outline,
                      label: 'Thông tin cá nhân',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      label: 'Thông báo',
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _SettingsSection(title: 'Ứng dụng', children: [
                    _SettingsTile(
                      icon: Icons.music_note_outlined,
                      label: 'Chất lượng âm thanh',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.download_outlined,
                      label: 'Tải xuống',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.storage_outlined,
                      label: 'Bộ nhớ cache',
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _SettingsSection(title: 'Về ứng dụng', children: [
                    _SettingsTile(
                      icon: Icons.info_outline,
                      label: 'Phiên bản 1.0.0',
                      onTap: () {},
                      showArrow: false,
                    ),
                  ]),
                  const SizedBox(height: 28),

                  // Logout
                  GestureDetector(
                    onTap: () async {
                      await authProvider.logout();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.red.withOpacity(0.3), width: 1),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.logout_rounded,
                                color: Colors.redAccent, size: 20),
                            const SizedBox(width: 8),
                            Text('Đăng xuất',
                                style: GoogleFonts.nunito(
                                  color: Colors.redAccent,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      ),
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: GoogleFonts.nunito(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showArrow;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
            if (showArrow)
              const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}
