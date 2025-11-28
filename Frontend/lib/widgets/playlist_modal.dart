import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';

class PlaylistModal extends StatefulWidget {
  final Map<String, dynamic> playlist;
  final List<Map<String, dynamic>> tracks;

  const PlaylistModal({
    Key? key,
    required this.playlist,
    required this.tracks,
  }) : super(key: key);

  @override
  State<PlaylistModal> createState() => _PlaylistModalState();
}

class _PlaylistModalState extends State<PlaylistModal> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(
          color: Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF1DB954).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Stack(
              children: [
                // Cover Image with Gradient
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    image: widget.playlist['image_url'] != null
                        ? DecorationImage(
                            image: NetworkImage(widget.playlist['image_url']!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1DB954).withOpacity(0.3),
                        Color(0xFF1a1a1a),
                      ],
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
                
                // Playlist Info
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLAYLIST',
                        style: TextStyle(
                          color: Color(0xFF1DB954),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.playlist['name'] ?? 'Unknown Playlist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${widget.tracks.length} tracks • ${widget.playlist['owner'] ?? 'Spotify'}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Tracks List
            Expanded(
              child: Column(
                children: [
                  // Header Row
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      border: Border(
                        bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text('#', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        SizedBox(width: 40),
                        Expanded(
                          flex: 3,
                          child: Text('TITLE', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('ALBUM', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ),
                        Text('DURATION', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),

                  // Tracks
                  Expanded(
                    child: widget.tracks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.music_off, size: 60, color: Colors.white30),
                                SizedBox(height: 16),
                                Text(
                                  'No tracks available',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: widget.tracks.length,
                            itemBuilder: (context, index) {
                              final track = widget.tracks[index];
                              return _buildTrackItem(track, index + 1, themeProvider);
                            },
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

  Widget _buildTrackItem(Map<String, dynamic> track, int trackNumber, ThemeProvider theme) {
    final durationMs = track['duration_ms'] ?? 0;
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$trackNumber',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track['name'] ?? 'Unknown Track',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  track['artists']?.join(', ') ?? 'Unknown Artist',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              track['album']?['name'] ?? 'Unknown Album',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$minutes:${seconds}',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}