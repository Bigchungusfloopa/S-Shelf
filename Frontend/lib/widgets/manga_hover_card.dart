import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/theme_provider.dart';

class MangaHoverCard extends StatefulWidget {
  final Manga manga;
  final Widget child;

  const MangaHoverCard({
    Key? key,
    required this.manga,
    required this.child,
  }) : super(key: key);

  @override
  State<MangaHoverCard> createState() => _MangaHoverCardState();
}

class _MangaHoverCardState extends State<MangaHoverCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        children: [
          widget.child,
          if (_isHovering)
            Positioned.fill(
              child: Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: themeProvider.accentColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: themeProvider.accentColor.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.manga.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.manga.titleEnglish != null) ...[
                        SizedBox(height: 4),
                        Text(
                          widget.manga.titleEnglish!,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      SizedBox(height: 16),
                      
                      // Rating
                      if (widget.manga.userScore != null)
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Your Rating: ${widget.manga.userScore!.toStringAsFixed(1)}/10',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      
                      SizedBox(height: 12),
                      
                      // Chapters & Volumes
                      Row(
                        children: [
                          Icon(Icons.book_outlined, color: themeProvider.accentColor, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Chapters: ${widget.manga.currentChapter}/${widget.manga.chapters ?? '?'}',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.library_books_outlined, color: themeProvider.accentColor, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Volumes: ${widget.manga.currentVolume}/${widget.manga.volumes ?? '?'}',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                      
                      // Genres
                      if (widget.manga.genres != null && widget.manga.genres!.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.manga.genres!.map((genre) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: themeProvider.accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: themeProvider.accentColor.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                genre,
                                style: TextStyle(
                                  color: themeProvider.accentColor,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      
                      // Synopsis
                      if (widget.manga.synopsis != null && widget.manga.synopsis!.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Text(
                          'Synopsis',
                          style: TextStyle(
                            color: themeProvider.accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.manga.synopsis!,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      // Notes
                      if (widget.manga.notes != null && widget.manga.notes!.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Text(
                          'Your Notes',
                          style: TextStyle(
                            color: themeProvider.accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.manga.notes!,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
