import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsService {
  static const String _accentColorKey = 'accent_color';
  static const String _backgroundImageKey = 'background_image';
  static const String _useCustomBackgroundKey = 'use_custom_background';
  
  // Save accent color
  Future<void> saveAccentColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.value);
  }
  
  // Get accent color
  Future<Color> getAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_accentColorKey);
    if (colorValue != null) {
      return Color(colorValue);
    }
    return Color(0xFF667eea); // Default purple
  }
  
  // Save background image path
  Future<void> saveBackgroundImage(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString(_backgroundImageKey, path);
    } else {
      await prefs.remove(_backgroundImageKey);
    }
  }
  
  // Get background image path
  Future<String?> getBackgroundImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_backgroundImageKey);
  }
  
  // Toggle custom background
  Future<void> setUseCustomBackground(bool use) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useCustomBackgroundKey, use);
  }
  
  // Get use custom background
  Future<bool> getUseCustomBackground() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useCustomBackgroundKey) ?? false;
  }
}
