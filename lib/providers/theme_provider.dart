import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AudioQuality { low, medium, high }

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  AudioQuality _audioQuality = AudioQuality.high;
  bool _wifiOnly = true;

  bool get isDarkMode => _isDarkMode;
  AudioQuality get audioQuality => _audioQuality;
  bool get wifiOnly => _wifiOnly;

  String get audioQualityLabel {
    switch (_audioQuality) {
      case AudioQuality.low:
        return 'Thấp';
      case AudioQuality.medium:
        return 'Trung bình';
      case AudioQuality.high:
        return 'Cao';
    }
  }

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    _wifiOnly = prefs.getBool('wifiOnly') ?? true;
    final qualityIndex = prefs.getInt('audioQuality') ?? 2;
    _audioQuality = AudioQuality.values[qualityIndex.clamp(0, 2)];
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleWifiOnly() async {
    _wifiOnly = !_wifiOnly;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wifiOnly', _wifiOnly);
    notifyListeners();
  }

  Future<void> setAudioQuality(AudioQuality quality) async {
    _audioQuality = quality;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('audioQuality', quality.index);
    notifyListeners();
  }
}
