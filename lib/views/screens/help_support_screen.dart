import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text('Trợ giúp & Hỗ trợ', style: GoogleFonts.nunito(color: c.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: c.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text('Chúng tôi có thể giúp gì cho bạn?', style: GoogleFonts.nunito(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildItem(Icons.article_outlined, 'Các câu hỏi thường gặp (FAQ)', c),
          _buildItem(Icons.contact_support_outlined, 'Liên hệ chăm sóc khách hàng', c),
          _buildItem(Icons.bug_report_outlined, 'Báo cáo lỗi', c),
          _buildItem(Icons.policy_outlined, 'Điều khoản & Hướng dẫn cộng đồng', c),
          const SizedBox(height: 40),
          Center(
            child: Text('Phiên bản 1.0.0', style: GoogleFonts.nunito(color: c.textTertiary)),
          ),
          Center(
            child: Text('© 2026 SoundWave Music', style: GoogleFonts.nunito(color: c.textTertiary, fontSize: 11)),
          )
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, AppColors c) {
    return Card(
      color: c.surface1,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: c.subtleBorder)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.brand),
        title: Text(title, style: GoogleFonts.nunito(color: c.textPrimary, fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.chevron_right, color: c.textSecondary),
        onTap: () {},
      ),
    );
  }
}
