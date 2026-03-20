import 'package:flutter/material.dart';

class AppGenre {
  final String key;
  final String label;
  final IconData icon;

  const AppGenre({required this.key, required this.label, required this.icon});

  static const List<AppGenre> all = [
    AppGenre(key: 'Pop', label: 'Pop', icon: Icons.music_note_rounded),
    AppGenre(key: 'Ballad', label: 'Ballad', icon: Icons.favorite_rounded),
    AppGenre(key: 'R&B', label: 'R&B', icon: Icons.album_rounded),
    AppGenre(key: 'EDM', label: 'EDM', icon: Icons.graphic_eq_rounded),
    AppGenre(key: 'Rap', label: 'Rap', icon: Icons.mic_rounded),
    AppGenre(key: 'Lo-Fi', label: 'Lo-Fi', icon: Icons.coffee_rounded),
  ];
}
