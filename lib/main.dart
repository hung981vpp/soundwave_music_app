import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'data/database_helper.dart';
import 'providers/song_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/player_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/discover_provider.dart';
import 'providers/home_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Đã xóa dòng clearAllSongs() để giữ dữ liệu khi restart

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SongProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => DiscoverProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
