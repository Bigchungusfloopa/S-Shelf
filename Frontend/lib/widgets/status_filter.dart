import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';

class StatusFilter extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;
  final List<Map<String, String>> statuses;

  const StatusFilter({
    Key? key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.statuses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = selectedStatus == status['value'];
          
          return GestureDetector(
            onTap: () => onStatusChanged(status['value']!),
            child: Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected ? themeProvider.accentGradient : null,
                color: isSelected ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected 
                      ? themeProvider.accentColor.withOpacity(0.5)
                      : Colors.white.withOpacity(0.1),
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: themeProvider.accentColor.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ] : null,
              ),
              child: Text(
                status['label']!,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
