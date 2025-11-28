import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/theme_provider.dart';

class AnimeHoverCard extends StatefulWidget {
  final Anime anime;
  final Widget child;

  const AnimeHoverCard({
    Key? key,
    required this.anime,
    required this.child,
  }) : super(key: key);

  @override
  State<AnimeHoverCard> createState() => _AnimeHoverCardState();
}

class _AnimeHoverCardState extends State<AnimeHoverCard> {
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
                        widget.anime.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.anime.titleEnglish != null) ...[
                        SizedBox(height: 4),
                        Text(
                          widget.anime.titleEnglish!,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      SizedBox(height: 16),
                      
                      // Rating
                      if (widget.anime.userScore != null)
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Your Rating: ${widget.anime.userScore!.toStringAsFixed(1)}/10',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      
                      SizedBox(height: 12),
                      
                      // Episodes
                      Row(
                        children: [
                          Icon(Icons.play_circle_outline, color: themeProvider.accentColor, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Episodes: ${widget.anime.currentEpisode}/${widget.anime.episodes ?? '?'}',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                      
                      // Genres
                      if (widget.anime.genres != null && widget.anime.genres!.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.anime.genres!.map((genre) {
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
                      if (widget.anime.synopsis != null && widget.anime.synopsis!.isNotEmpty) ...[
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
                          widget.anime.synopsis!,
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
                      if (widget.anime.notes != null && widget.anime.notes!.isNotEmpty) ...[
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
                          widget.anime.notes!,
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
