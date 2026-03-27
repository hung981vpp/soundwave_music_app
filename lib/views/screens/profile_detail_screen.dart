import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_colors.dart';
import '../../providers/auth_provider.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late TextEditingController _nameCtrl;
  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 30, // Compress to save space in base64
        maxWidth: 300,
        maxHeight: 300,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl = TextEditingController(text: auth.currentUser?.displayName ?? 'Khách');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final auth = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text('Hồ sơ', style: GoogleFonts.nunito(color: c.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: c.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.brand.withOpacity(0.2),
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!) as ImageProvider
                        : (auth.avatarBase64 != null
                            ? MemoryImage(base64Decode(auth.avatarBase64!))
                            : null),
                    child: (_imageFile == null && auth.avatarBase64 == null)
                        ? Text(
                            (auth.currentUser?.displayName?.isNotEmpty == true)
                                ? auth.currentUser!.displayName!.substring(0, 1).toUpperCase()
                                : 'K',
                            style: GoogleFonts.nunito(fontSize: 40, color: AppColors.brand, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.brand,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField('Tên hiển thị', _nameCtrl, c),
            const SizedBox(height: 20),
            _buildTextField('Email', TextEditingController(text: auth.currentUser?.email ?? 'Chưa cập nhật'), c, enabled: false),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isUploading ? null : () async {
                  final newName = _nameCtrl.text.trim();
                  if (newName.isNotEmpty && auth.currentUser != null) {
                    setState(() => _isUploading = true);
                    try {
                      if (_imageFile != null) {
                        final bytes = await _imageFile!.readAsBytes();
                        final base64String = base64Encode(bytes);
                        await context.read<AuthProvider>().updateAvatar(base64String);
                      }

                      await auth.currentUser!.updateDisplayName(newName);
                      
                      // Notify UI via AuthProvider
                      if (context.mounted) {
                        await context.read<AuthProvider>().reloadUser();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã cập nhật hồ sơ', style: GoogleFonts.nunito()), 
                            backgroundColor: AppColors.brand,
                            behavior: SnackBarBehavior.floating,
                          )
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: $e', style: GoogleFonts.nunito()), 
                            backgroundColor: Colors.red,
                          )
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isUploading = false);
                    }
                  }
                },
                child: _isUploading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Lưu thay đổi', style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, AppColors c, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.nunito(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          style: GoogleFonts.nunito(color: enabled ? c.textPrimary : c.textSecondary),
          decoration: InputDecoration(
            filled: true,
            fillColor: c.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.subtleBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.subtleBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.brand),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.subtleBorder.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }
}
