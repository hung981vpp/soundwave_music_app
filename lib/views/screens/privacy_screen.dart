import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_colors.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _privateProfile = false;
  bool _showActivity = true;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text('Riêng tư & Bảo mật', style: GoogleFonts.nunito(color: c.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: c.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Quyền riêng tư', style: GoogleFonts.nunito(color: AppColors.brand, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
          ),
          SwitchListTile(
            title: Text('Hồ sơ riêng tư', style: GoogleFonts.nunito(color: c.textPrimary, fontWeight: FontWeight.w600)),
            subtitle: Text('Người khác sẽ không thể xem playlist của bạn', style: GoogleFonts.nunito(color: c.textSecondary, fontSize: 13)),
            value: _privateProfile,
            onChanged: (v) => setState(() => _privateProfile = v),
            activeColor: AppColors.brand,
          ),
          SwitchListTile(
            title: Text('Hiển thị hoạt động', style: GoogleFonts.nunito(color: c.textPrimary, fontWeight: FontWeight.w600)),
            subtitle: Text('Cho phép bạn bè thấy bạn đang nghe gì', style: GoogleFonts.nunito(color: c.textSecondary, fontSize: 13)),
            value: _showActivity,
            onChanged: (v) => setState(() => _showActivity = v),
            activeColor: AppColors.brand,
          ),
          Divider(color: c.subtleBorder, height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Bảo mật', style: GoogleFonts.nunito(color: AppColors.brand, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
          ),
          ListTile(
            leading: Icon(Icons.password_rounded, color: c.textPrimary),
            title: Text('Đổi mật khẩu', style: GoogleFonts.nunito(color: c.textPrimary, fontWeight: FontWeight.w600)),
            trailing: Icon(Icons.chevron_right, color: c.textSecondary),
            onTap: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && user.email != null) {
                _showChangePasswordDialog(context, user);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.security_rounded, color: c.textPrimary),
            title: Text('Xác thực 2 yếu tố', style: GoogleFonts.nunito(color: c.textPrimary, fontWeight: FontWeight.w600)),
            trailing: Icon(Icons.chevron_right, color: c.textSecondary),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: c.surface1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: [
                      const Icon(Icons.security, color: AppColors.brand),
                      const SizedBox(width: 8),
                      Text('Khóa bảo mật 2FA', style: GoogleFonts.nunito(color: c.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  content: Text('Tính năng Xác thực 2 bước qua SMS (Firebase Identity Platform) yêu cầu thẻ thanh toán để thiết lập Server.\n\nHiện tại tính năng này đang hiển thị dưới dạng Demo (vui lòng nâng cấp cấu hình Firebase để kích hoạt).', style: GoogleFonts.nunito(color: c.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Đã rõ', style: GoogleFonts.nunito(color: c.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
          Divider(color: c.subtleBorder, height: 32),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
            title: Text('Xóa tài khoản', style: GoogleFonts.nunito(color: Colors.redAccent, fontWeight: FontWeight.w600)),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, User user) {
    final c = AppColors.of(context);
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    String? errorMsg;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: c.surface1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Đổi mật khẩu', style: GoogleFonts.nunito(color: c.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(errorMsg!, style: GoogleFonts.nunito(color: Colors.redAccent, fontSize: 13)),
                    ),
                  TextFormField(
                    controller: currentPassCtrl,
                    obscureText: true,
                    style: GoogleFonts.nunito(color: c.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu cũ của bạn',
                      labelStyle: GoogleFonts.nunito(color: c.textSecondary),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.subtleBorder)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.brand)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập mật khẩu hiện tại' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newPassCtrl,
                    obscureText: true,
                    style: GoogleFonts.nunito(color: c.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới',
                      labelStyle: GoogleFonts.nunito(color: c.textSecondary),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.subtleBorder)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.brand)),
                    ),
                    validator: (val) => val == null || val.length < 6 ? 'Mật khẩu dài ít nhất 6 ký tự' : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: Text('Đóng', style: GoogleFonts.nunito(color: c.textSecondary, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: isLoading ? null : () async {
                  if (formKey.currentState?.validate() == true) {
                    setState(() { isLoading = true; errorMsg = null; });
                    try {
                      // 1. Xác thực lại với mật khẩu cũ
                      AuthCredential credential = EmailAuthProvider.credential(
                        email: user.email!, 
                        password: currentPassCtrl.text
                      );
                      await user.reauthenticateWithCredential(credential);
                      
                      // 2. Cập nhật mật khẩu mới
                      await user.updatePassword(newPassCtrl.text);
                      
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cập nhật mật khẩu mới thành công!', style: GoogleFonts.nunito()), backgroundColor: Colors.green));
                      }
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        isLoading = false;
                        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                          errorMsg = 'Mật khẩu hiện tại không đúng!';
                        } else {
                          errorMsg = 'Lỗi hệ thống: ${e.message}';
                        }
                      });
                    } catch (e) {
                      setState(() { isLoading = false; errorMsg = 'Đã có lỗi xảy ra: $e'; });
                    }
                  }
                },
                child: isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Lưu thay đổi', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }
}
