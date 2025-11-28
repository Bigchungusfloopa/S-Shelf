import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../services/theme_provider.dart';

class ThemedScreen extends StatelessWidget {
  final Widget child;

  const ThemedScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: themeProvider.useCustomBackground && 
               themeProvider.backgroundImagePath != null &&
               _canAccessFile(themeProvider.backgroundImagePath!)
            ? DecorationImage(
                image: FileImage(File(themeProvider.backgroundImagePath!)),
                fit: BoxFit.cover,
                opacity: 0.2,
                onError: (exception, stackTrace) {
                  print('Error loading background image: $exception');
                },
              )
            : null,
      ),
      child: child,
    );
  }
  
  bool _canAccessFile(String path) {
    try {
      final file = File(path);
      return file.existsSync();
    } catch (e) {
      return false;
    }
  }
}
