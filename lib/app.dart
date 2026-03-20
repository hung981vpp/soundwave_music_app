import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final isDark = themeProvider.isDarkMode;

    final textTheme = GoogleFonts.nunitoTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme);

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF5500),
        secondary: Color(0xFFFF7733),
        surface: Color(0xFF1A1A1A),
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF111111),
        indicatorColor: const Color(0xFFFF5500).withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.nunito(
                color: const Color(0xFFFF5500),
                fontSize: 11,
                fontWeight: FontWeight.w700);
          }
          return GoogleFonts.nunito(
              color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFFFF5500));
          }
          return const IconThemeData(color: Colors.grey);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFFFF5500),
        inactiveTrackColor: Colors.white24,
        thumbColor: const Color(0xFFFF5500),
        overlayColor: const Color(0xFFFF5500).withOpacity(0.2),
        trackHeight: 3,
      ),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF5500),
        secondary: Color(0xFFFF7733),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: Color(0xFF1A1A1A),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF5F5F5),
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        titleTextStyle: GoogleFonts.nunito(
          color: const Color(0xFF1A1A1A),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFF5500).withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.nunito(
                color: const Color(0xFFFF5500),
                fontSize: 11,
                fontWeight: FontWeight.w700);
          }
          return GoogleFonts.nunito(
              color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFFFF5500));
          }
          return const IconThemeData(color: Colors.grey);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFFFF5500),
        inactiveTrackColor: Colors.black12,
        thumbColor: const Color(0xFFFF5500),
        overlayColor: const Color(0xFFFF5500).withOpacity(0.2),
        trackHeight: 3,
      ),
    );

    return MaterialApp(
      title: 'SoundWave',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: authProvider.isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
