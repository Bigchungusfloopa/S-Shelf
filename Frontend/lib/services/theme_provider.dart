import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class ThemeProvider extends ChangeNotifier {
  final SettingsService _settings = SettingsService();
  Color _accentColor = Color(0xFF667eea);
  String? _backgroundImagePath;
  bool _useCustomBackground = false;
  
  Color get accentColor => _accentColor;
  String? get backgroundImagePath => _backgroundImagePath;
  bool get useCustomBackground => _useCustomBackground;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    _accentColor = await _settings.getAccentColor();
    _backgroundImagePath = await _settings.getBackgroundImage();
    _useCustomBackground = await _settings.getUseCustomBackground();
    notifyListeners();
  }
  
  Future<void> updateAccentColor(Color color) async {
    _accentColor = color;
    await _settings.saveAccentColor(color);
    notifyListeners();
  }
  
  Future<void> updateBackgroundImage(String? path) async {
    _backgroundImagePath = path;
    await _settings.saveBackgroundImage(path);
    await _settings.setUseCustomBackground(path != null);
    _useCustomBackground = path != null;
    notifyListeners();
  }
  
  // Generate gradient from accent color
  LinearGradient get accentGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _accentColor,
        _accentColor.withOpacity(0.7),
      ],
    );
  }
  
  // Generate darker version for cards
  Color get accentDark {
    return Color.lerp(_accentColor, Colors.black, 0.3)!;
  }
  
  // Generate lighter version for highlights
  Color get accentLight {
    return Color.lerp(_accentColor, Colors.white, 0.3)!;
  }
}
