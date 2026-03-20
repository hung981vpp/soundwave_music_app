import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

// ── Floating Music Note Particle ─────────────────────────────────────────────
class _MusicParticle {
  double x, y, size, speed, opacity;
  IconData icon;
  _MusicParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.icon,
  });
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late final AnimationController _bgAnimCtrl;
  late final AnimationController _enterAnimCtrl;
  late final AnimationController _pulseAnimCtrl;

  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _fieldsFade;
  late final Animation<Offset> _fieldsSlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  final List<_MusicParticle> _particles = [];
  final _random = Random();

  // Password strength
  double _passwordStrength = 0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.transparent;

  @override
  void initState() {
    super.initState();

    _bgAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _enterAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterAnimCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterAnimCtrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    ));
    _fieldsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterAnimCtrl,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOut),
      ),
    );
    _fieldsSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterAnimCtrl,
      curve: const Interval(0.2, 0.55, curve: Curves.easeOutCubic),
    ));
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterAnimCtrl,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
      ),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterAnimCtrl,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic),
    ));

    _enterAnimCtrl.forward();

    _passwordController.addListener(_updatePasswordStrength);

    // Generate particles
    final icons = [
      Icons.music_note,
      Icons.headphones,
      Icons.audiotrack,
      Icons.queue_music,
      Icons.equalizer,
    ];
    for (int i = 0; i < 18; i++) {
      _particles.add(_MusicParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 18 + 10,
        speed: _random.nextDouble() * 0.3 + 0.1,
        opacity: _random.nextDouble() * 0.12 + 0.03,
        icon: icons[_random.nextInt(icons.length)],
      ));
    }
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 10) strength += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.2;

    String label;
    Color color;
    if (strength <= 0.25) {
      label = 'Yếu';
      color = const Color(0xFFFF4444);
    } else if (strength <= 0.5) {
      label = 'Trung bình';
      color = const Color(0xFFFFAA00);
    } else if (strength <= 0.75) {
      label = 'Mạnh';
      color = const Color(0xFF44BB44);
    } else {
      label = 'Rất mạnh';
      color = const Color(0xFF00CC88);
    }

    setState(() {
      _passwordStrength = strength.clamp(0.0, 1.0);
      _passwordStrengthLabel = password.isEmpty ? '' : label;
      _passwordStrengthColor = color;
    });
  }

  @override
  void dispose() {
    _bgAnimCtrl.dispose();
    _enterAnimCtrl.dispose();
    _pulseAnimCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await context.read<AuthProvider>().register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(error)),
            ],
          ),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Animated Gradient Background ──
          AnimatedBuilder(
            animation: _bgAnimCtrl,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      -1.0 + sin(_bgAnimCtrl.value * 2 * pi) * 0.3,
                      -1.0 + cos(_bgAnimCtrl.value * 2 * pi) * 0.3,
                    ),
                    end: Alignment(
                      1.0 + cos(_bgAnimCtrl.value * 2 * pi) * 0.3,
                      1.0 + sin(_bgAnimCtrl.value * 2 * pi) * 0.3,
                    ),
                    colors: const [
                      Color(0xFF0A0A0F),
                      Color(0xFF0D0516),
                      Color(0xFF1A0A00),
                      Color(0xFF0A0A0F),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              );
            },
          ),

          // ── Floating Particles ──
          AnimatedBuilder(
            animation: _bgAnimCtrl,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: _ParticlePainter(
                  particles: _particles,
                  animValue: _bgAnimCtrl.value,
                ),
              );
            },
          ),

          // ── Glow Orbs ──
          Positioned(
            top: size.height * 0.05,
            left: -60,
            child: AnimatedBuilder(
              animation: _pulseAnimCtrl,
              builder: (context, _) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7B2FFF)
                            .withOpacity(0.12 * _pulseAnimCtrl.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: size.height * 0.1,
            right: -40,
            child: AnimatedBuilder(
              animation: _pulseAnimCtrl,
              builder: (context, _) {
                return Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF5500)
                            .withOpacity(0.1 * (1 - _pulseAnimCtrl.value)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Main Content ──
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // ── Back Button ──
                    FadeTransition(
                      opacity: _headerFade,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white70, size: 18),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Header ──
                    FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: Column(
                          children: [
                            // Animated icon
                            AnimatedBuilder(
                              animation: _pulseAnimCtrl,
                              builder: (context, _) {
                                final glowOpacity =
                                    0.25 + 0.2 * _pulseAnimCtrl.value;
                                return Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF7B2FFF),
                                        Color(0xFFFF5500),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF7B2FFF)
                                            .withOpacity(glowOpacity),
                                        blurRadius: 35,
                                        spreadRadius: 6,
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFFFF5500)
                                            .withOpacity(glowOpacity * 0.5),
                                        blurRadius: 50,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.person_add_rounded,
                                      color: Colors.white, size: 38),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Tạo tài khoản',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                colors: [
                                  Color(0xFF7B5FFF),
                                  Color(0xFFFF8855),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'Tham gia SoundWave ngay hôm nay',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Input Fields ──
                    FadeTransition(
                      opacity: _fieldsFade,
                      child: SlideTransition(
                        position: _fieldsSlide,
                        child: Column(
                          children: [
                            _PremiumTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'you@example.com',
                              icon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Email không được để trống';
                                }
                                if (!v.contains('@')) {
                                  return 'Email không hợp lệ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            _PremiumTextField(
                              controller: _passwordController,
                              label: 'Mật khẩu',
                              hint: '••••••••',
                              icon: Icons.lock_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: Colors.white38,
                                  size: 20,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Mật khẩu không được để trống';
                                }
                                if (v.length < 6) return 'Tối thiểu 6 ký tự';
                                return null;
                              },
                            ),

                            // ── Password Strength Indicator ──
                            if (_passwordController.text.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 400),
                                        height: 4,
                                        child: LinearProgressIndicator(
                                          value: _passwordStrength,
                                          backgroundColor:
                                              Colors.white.withOpacity(0.08),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  _passwordStrengthColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _passwordStrengthLabel,
                                    style: GoogleFonts.nunito(
                                      color: _passwordStrengthColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 16),

                            _PremiumTextField(
                              controller: _confirmPasswordController,
                              label: 'Xác nhận mật khẩu',
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscureConfirm,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                                child: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: Colors.white38,
                                  size: 20,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Vui lòng xác nhận mật khẩu';
                                }
                                if (v != _passwordController.text) {
                                  return 'Mật khẩu không khớp';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Register Button & Socials ──
                    FadeTransition(
                      opacity: _buttonFade,
                      child: SlideTransition(
                        position: _buttonSlide,
                        child: Column(
                          children: [
                            // ── Terms ──
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text.rich(
                                TextSpan(
                                  text: 'Bằng cách đăng ký, bạn đồng ý với ',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white30,
                                    fontSize: 12,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Điều khoản sử dụng',
                                      style: GoogleFonts.nunito(
                                        color: const Color(0xFFFF7744),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: ' và '),
                                    TextSpan(
                                      text: 'Chính sách bảo mật',
                                      style: GoogleFonts.nunito(
                                        color: const Color(0xFFFF7744),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Register Button ──
                            _isLoading
                                ? const SizedBox(
                                    height: 56,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFFF5500),
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  )
                                : _PremiumButton(
                                    label: 'Tạo tài khoản',
                                    onTap: _register,
                                    gradientColors: const [
                                      Color(0xFF7B2FFF),
                                      Color(0xFFFF5500),
                                    ],
                                    shadowColor: const Color(0xFF7B2FFF),
                                  ),

                            const SizedBox(height: 28),

                            // ── Login Link ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Đã có tài khoản?',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white38,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          const LoginScreen(),
                                      transitionsBuilder:
                                          (_, animation, __, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                      transitionDuration:
                                          const Duration(milliseconds: 400),
                                    ),
                                  ),
                                  child: Text(
                                    'Đăng nhập',
                                    style: GoogleFonts.nunito(
                                      color: const Color(0xFFFF5500),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Premium TextField ────────────────────────────────────────────────────────
class _PremiumTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<_PremiumTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: GoogleFonts.nunito(
              color: _isFocused ? const Color(0xFFFF7744) : Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: _isFocused
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused
                  ? const Color(0xFFFF5500).withOpacity(0.5)
                  : Colors.white.withOpacity(0.08),
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF5500).withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Focus(
            onFocusChange: (focused) => setState(() => _isFocused = focused),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              style: GoogleFonts.nunito(color: Colors.white, fontSize: 15),
              validator: widget.validator,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: GoogleFonts.nunito(
                  color: Colors.white24,
                  fontSize: 14,
                ),
                prefixIcon: Icon(widget.icon,
                    color: _isFocused
                        ? const Color(0xFFFF5500)
                        : Colors.white30,
                    size: 20),
                suffixIcon: widget.suffixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: widget.suffixIcon,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                errorStyle: GoogleFonts.nunito(
                  color: const Color(0xFFFF6B6B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Premium Button ───────────────────────────────────────────────────────────
class _PremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final List<Color>? gradientColors;
  final Color? shadowColor;

  const _PremiumButton({
    required this.label,
    required this.onTap,
    this.gradientColors,
    this.shadowColor,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors ??
        [
          const Color(0xFFFF5500),
          const Color(0xFFFF7733),
          const Color(0xFFFF9944),
        ];
    final shadowClr = widget.shadowColor ?? const Color(0xFFFF5500);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowClr.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: shadowClr.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Social Button ────────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Particle Painter ─────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final List<_MusicParticle> particles;
  final double animValue;

  _ParticlePainter({required this.particles, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final yOffset = ((p.y + animValue * p.speed) % 1.2) - 0.1;
      final xOffset = p.x + sin(animValue * 2 * pi + p.y * 5) * 0.03;

      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(p.icon.codePoint),
          style: TextStyle(
            fontSize: p.size,
            fontFamily: p.icon.fontFamily,
            package: p.icon.fontPackage,
            color: const Color(0xFFFF5500).withOpacity(p.opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xOffset * size.width, yOffset * size.height),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
