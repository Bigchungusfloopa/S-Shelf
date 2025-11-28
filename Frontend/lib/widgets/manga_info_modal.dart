import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/theme_provider.dart';
import '../services/api_service.dart';
import 'manga_dialog.dart';

class MangaInfoModal extends StatelessWidget {
  final Manga manga;
  final VoidCallback onUpdate;

  const MangaInfoModal({
    Key? key,
    required this.manga,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final apiService = ApiService();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(
          color: Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: themeProvider.accentColor.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Image
            Stack(
              children: [
                // Cover Image
                if (manga.imageUrl != null)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(manga.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0xFF1a1a1a),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Close Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                      border: Border.all(color: Colors.red.withOpacity(0.5), width: 1.5),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      manga.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(manga.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getStatusColor(manga.status)),
                      ),
                      child: Text(
                        _getStatusLabel(manga.status),
                        style: TextStyle(
                          color: _getStatusColor(manga.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Info Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'Chapters',
                            '${manga.currentChapter}/${manga.totalChapters ?? '?'}',
                            Icons.menu_book_outlined,
                            themeProvider,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoItem(
                            'Volumes',
                            '${manga.currentVolume}/${manga.totalVolumes ?? '?'}',
                            Icons.collections_bookmark_outlined,
                            themeProvider,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildInfoItem(
                      'Your Score',
                      manga.rating.toStringAsFixed(1),
                      Icons.star_outlined,
                      themeProvider,
                    ),
                    SizedBox(height: 20),

                    // Notes
                    if (manga.notes != null && manga.notes!.isNotEmpty) ...[
                      Text(
                        'Your Notes',
                        style: TextStyle(
                          color: themeProvider.accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          manga.notes!,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        final result = await showDialog(
                          context: context,
                          builder: (context) => MangaDialog(
                            manga: manga,
                            onSave: (updatedManga) async {
                              // This is in the modal, so we just close it
                              // The parent screen will handle the actual save
                              Navigator.pop(context);
                            },
                            onDelete: () {
                              Navigator.pop(context);
                            },
                          ),  
                        );
                        if (result == true) onUpdate();
                      },
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.accentColor.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        side: BorderSide(color: themeProvider.accentColor, width: 1.5),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Color(0xFF1a1a1a),
                            title: Text('Delete Manga', style: TextStyle(color: Colors.white)),
                            content: Text(
                              'Are you sure you want to delete "${manga.title}"?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          final success = await apiService.deleteManga(manga.id);
                          Navigator.pop(context);
                          if (success) {
                            onUpdate();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Manga deleted')),
                            );
                          }
                        }
                      },
                      icon: Icon(Icons.delete_outline, size: 18),
                      label: Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.red.withOpacity(0.5), width: 1.5),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, ThemeProvider theme) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.accentColor, size: 20),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'reading':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'plan_to_read':
        return Colors.orange;
      case 'dropped':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'reading':
        return 'Reading';
      case 'completed':
        return 'Completed';
      case 'plan_to_read':
        return 'Plan to Read';
      case 'dropped':
        return 'Dropped';
      default:
        return status;
    }
  }
}