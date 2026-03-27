import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _newReleases = true;
  bool _recommendations = true;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text('Thông báo', style: GoogleFonts.nunito(color: c.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: c.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      body: ListView(
        children: [
          _buildSwitch('Thông báo đẩy', 'Nhận thông báo trên thiết bị này', _pushEnabled, (v) => setState(() => _pushEnabled = v), c),
          _buildSwitch('Email', 'Nhận thông báo qua email', _emailEnabled, (v) => setState(() => _emailEnabled = v), c),
          Divider(color: c.subtleBorder, height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text('Tùy chỉnh', style: GoogleFonts.nunito(color: AppColors.brand, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
          ),
          _buildSwitch('Bài hát mới', 'Thông báo khi ca sĩ bạn theo dõi có bài mới', _newReleases, (v) => setState(() => _newReleases = v), c),
          _buildSwitch('Gợi ý cho bạn', 'Gợi ý nhạc dựa trên sở thích của bạn', _recommendations, (v) => setState(() => _recommendations = v), c),
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged, AppColors c) {
    return SwitchListTile(
      title: Text(title, style: GoogleFonts.nunito(color: c.textPrimary, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: GoogleFonts.nunito(color: c.textSecondary, fontSize: 13)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.brand,
    );
  }
}
