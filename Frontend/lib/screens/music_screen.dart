import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/theme_provider.dart';
import '../services/api_service.dart';
import '../widgets/themed_screen.dart';
import '../widgets/playlist_modal.dart';
import '../widgets/album_modal.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> with SingleTickerProviderStateMixin {
  String _selectedMonth = 'All Time';
  late TabController _tabController;
  
  // Spotify data
  bool _isSpotifyConnected = false;
  bool _isLoading = true;
  
  List<Map<String, dynamic>> _playlists = [];
  List<Map<String, dynamic>> _likedAlbums = [];
  List<Map<String, dynamic>> _followedArtists = [];
  Map<String, dynamic>? _wrappedStats;
  
  List<Map<String, dynamic>> _currentTracks = [];
  List<Map<String, dynamic>> _currentArtists = [];
  bool _isLoadingMonth = false;

  // Add ApiService instance
  final ApiService _apiService = ApiService();

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
    'All Time'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkAuthentication();
    _loadDataForTimeRange('All Time');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthentication() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(Uri.parse('http://localhost:8000/spotify/check-auth'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _isSpotifyConnected = data['authenticated'] == true;
        });
        
        if (_isSpotifyConnected) {
          await _loadSpotifyData();
        }
      }
    } catch (e) {
      print('Error checking Spotify auth: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadSpotifyData() async {
    try {
      final playlistsResponse = await http.get(Uri.parse('http://localhost:8000/spotify/playlists'));
      if (playlistsResponse.statusCode == 200) {
        final data = json.decode(playlistsResponse.body);
        setState(() {
          _playlists = List<Map<String, dynamic>>.from(data['playlists']);
        });
      }

      final albumsResponse = await http.get(Uri.parse('http://localhost:8000/spotify/liked-albums?limit=50'));
      if (albumsResponse.statusCode == 200) {
        final data = json.decode(albumsResponse.body);
        setState(() {
          _likedAlbums = List<Map<String, dynamic>>.from(data['albums']);
        });
      }

      final artistsResponse = await http.get(Uri.parse('http://localhost:8000/spotify/followed-artists'));
      if (artistsResponse.statusCode == 200) {
        final data = json.decode(artistsResponse.body);
        setState(() {
          _followedArtists = List<Map<String, dynamic>>.from(data['artists']);
        });
      }

      await _loadWrappedStats();
    } catch (e) {
      print('Error loading Spotify data: $e');
    }
  }

  Future<void> _loadWrappedStats() async {
    try {
      final statsResponse = await http.get(Uri.parse('http://localhost:8000/spotify/user-stats'));
      if (statsResponse.statusCode == 200) {
        setState(() {
          _wrappedStats = json.decode(statsResponse.body);
        });
      }
    } catch (e) {
      print('Error loading Spotify stats: $e');
    }
  }

  Future<void> _loadDataForTimeRange(String month) async {
    setState(() => _isLoadingMonth = true);
    
    try {
      String timeRange;
      
      if (month == 'All Time') {
        timeRange = 'long_term';
      } else {
        int currentMonth = DateTime.now().month;
        List<String> monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
                                    'July', 'August', 'September', 'October', 'November', 'December'];
        int selectedMonthIndex = monthNames.indexOf(month) + 1;
        
        if (selectedMonthIndex == 0) {
          timeRange = 'medium_term';
        } else {
          int monthDiff = (currentMonth - selectedMonthIndex).abs();
          timeRange = monthDiff <= 1 ? 'short_term' : 'medium_term';
        }
      }
      
      final tracksResponse = await http.get(
        Uri.parse('http://localhost:8000/spotify/top-tracks?time_range=$timeRange&limit=20')
      );
      
      final artistsResponse = await http.get(
        Uri.parse('http://localhost:8000/spotify/top-artists?time_range=$timeRange&limit=20')
      );
      
      if (tracksResponse.statusCode == 200 && artistsResponse.statusCode == 200) {
        final tracksData = json.decode(tracksResponse.body);
        final artistsData = json.decode(artistsResponse.body);
        
        setState(() {
          _currentTracks = List<Map<String, dynamic>>.from(tracksData['tracks']);
          _currentArtists = List<Map<String, dynamic>>.from(artistsData['artists']);
          _isLoadingMonth = false;
        });
      } else {
        setState(() => _isLoadingMonth = false);
      }
    } catch (e) {
      print('Error loading data for time range: $e');
      setState(() => _isLoadingMonth = false);
    }
  }

  void _showArtistDetails(Map<String, dynamic> artist) {
    showDialog(
      context: context,
      builder: (context) => ArtistDetailsModal(artist: artist),
    );
  }

  // Updated modal methods
  void _showPlaylistModal(Map<String, dynamic> playlist) async {
    try {
      final tracks = await _apiService.getPlaylistTracks(playlist['id']);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => PlaylistModal(
          playlist: playlist,
          tracks: tracks,
        ),
      );
    } catch (e) {
      print('Error loading playlist tracks: $e');
      // Fallback: Show basic playlist info without tracks
      showDialog(
        context: context,
        builder: (context) => PlaylistModal(
          playlist: playlist,
          tracks: [],
        ),
      );
    }
  }

  void _showAlbumModal(Map<String, dynamic> album) async {
    try {
      final tracks = await _apiService.getAlbumTracks(album['id']);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlbumModal(
          album: album,
          tracks: tracks,
        ),
      );
    } catch (e) {
      print('Error loading album tracks: $e');
      // Fallback: Show basic album info without tracks
      showDialog(
        context: context,
        builder: (context) => AlbumModal(
          album: album,
          tracks: [],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      body: ThemedScreen(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Music',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFF1DB954).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFF1DB954), width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.music_note, color: Color(0xFF1DB954), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Spotify',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _buildSpotifyContent(themeProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpotifyContent(ThemeProvider theme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Color(0xFF1DB954)),
      );
    }

    if (!_isSpotifyConnected) {
      return _buildConnectPrompt(theme);
    }

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Color(0xFF1DB954),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Playlists'),
              Tab(text: 'Albums'),
              Tab(text: 'Artists'),
              Tab(text: 'Wrapped'),
            ],
          ),
        ),
        SizedBox(height: 20),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPlaylistsTab(theme),
              _buildAlbumsTab(theme),
              _buildArtistsTab(theme),
              _buildWrappedTab(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectPrompt(ThemeProvider theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note, size: 80, color: Color(0xFF1DB954).withOpacity(0.3)),
          SizedBox(height: 20),
          Text(
            'Connect Spotify',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'View your playlists, albums, artists, and Wrapped stats',
              style: TextStyle(color: Colors.white54, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Run: python spotify_oauth_server.py'),
                  backgroundColor: Color(0xFF1DB954),
                ),
              );
            },
            icon: Icon(Icons.music_note, size: 18),
            label: Text('Connect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1DB954),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsTab(ThemeProvider theme) {
    if (_playlists.isEmpty) {
      return Center(
        child: Text('No playlists found', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: _playlists.length,
      itemBuilder: (context, index) {
        final playlist = _playlists[index];
        return GestureDetector(
          onTap: () => _showPlaylistModal(playlist),
          child: _buildMusicCard(
            title: playlist['name'],
            subtitle: '${playlist['tracks_count']} songs • ${playlist['owner']}',
            imageUrl: playlist['image_url'],
            theme: theme,
          ),
        );
      },
    );
  }

  Widget _buildAlbumsTab(ThemeProvider theme) {
    if (_likedAlbums.isEmpty) {
      return Center(
        child: Text('No liked albums found', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: _likedAlbums.length,
      itemBuilder: (context, index) {
        final album = _likedAlbums[index];
        return GestureDetector(
          onTap: () => _showAlbumModal(album),
          child: _buildMusicCard(
            title: album['name'],
            subtitle: '${album['artist']} • ${album['total_tracks']} tracks',
            imageUrl: album['image_url'],
            theme: theme,
          ),
        );
      },
    );
  }

  Widget _buildArtistsTab(ThemeProvider theme) {
    if (_followedArtists.isEmpty) {
      return Center(
        child: Text('No followed artists found', style: TextStyle(color: Colors.white54)),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _followedArtists.length,
      itemBuilder: (context, index) {
        final artist = _followedArtists[index];
        return _buildArtistCard(
          artist: artist,
          theme: theme,
          onTap: () => _showArtistDetails(artist),
        );
      },
    );
  }

  Widget _buildWrappedTab(ThemeProvider theme) {
    if (_wrappedStats == null) {
      return Center(
        child: CircularProgressIndicator(color: Color(0xFF1DB954)),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SELECT MONTH',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(0xFF1DB954).withOpacity(0.3),
                  ),
                ),
                child: DropdownButton<String>(
                  value: _selectedMonth,
                  dropdownColor: Color(0xFF1a1a1a),
                  underline: SizedBox(),
                  icon: Icon(Icons.arrow_drop_down, color: Color(0xFF1DB954)),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  items: _months.map((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(month),
                    );
                  }).toList(),
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      setState(() => _selectedMonth = newValue);
                      await _loadDataForTimeRange(newValue);
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          Row(
            children: [
              Expanded(child: _buildStatCard('Songs', '${_wrappedStats!['total_saved_tracks']}', Icons.music_note, theme)),
              SizedBox(width: 12),
              Expanded(child: _buildStatCard('Playlists', '${_wrappedStats!['total_playlists']}', Icons.playlist_play, theme)),
              SizedBox(width: 12),
              Expanded(child: _buildStatCard('Artists', '${_wrappedStats!['total_followed_artists']}', Icons.person, theme)),
            ],
          ),
          SizedBox(height: 30),

          Text(
            'TOP TRACKS - ${_selectedMonth.toUpperCase()}',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 16),
          
          if (_isLoadingMonth)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Color(0xFF1DB954)),
              ),
            )
          else if (_currentTracks.isNotEmpty)
            ..._buildWrappedList(_currentTracks, theme)
          else
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No tracks found', style: TextStyle(color: Colors.white54)),
              ),
            ),
          
          SizedBox(height: 30),

          Text(
            'TOP ARTISTS - ${_selectedMonth.toUpperCase()}',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 16),
          
          if (_isLoadingMonth)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Color(0xFF1DB954)),
              ),
            )
          else if (_currentArtists.isNotEmpty)
            ..._buildWrappedList(_currentArtists, theme)
          else
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No artists found', style: TextStyle(color: Colors.white54)),
              ),
            ),

          SizedBox(height: 30),

          Text(
            'TOP GENRES',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_wrappedStats!['top_genres'] as List).map((genre) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF1DB954).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFF1DB954).withOpacity(0.5)),
                ),
                child: Text(
                  genre['genre'],
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWrappedList(List items, ThemeProvider theme) {
    return items.take(10).map((item) {
      return _buildMusicCard(
        title: item['name'],
        subtitle: item['artist'] ?? '',
        imageUrl: item['image_url'],
        theme: theme,
      );
    }).toList();
  }

  Widget _buildStatCard(String label, String value, IconData icon, ThemeProvider theme) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF1DB954).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF1DB954), size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicCard({
    required String title,
    required String subtitle,
    String? imageUrl,
    required ThemeProvider theme,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.accentColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withOpacity(0.05),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.music_note, color: Colors.white30),
                    ),
                  )
                : Icon(Icons.music_note, color: Colors.white30),
          ),
          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistCard({
    required Map<String, dynamic> artist,
    required ThemeProvider theme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.accentColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.white.withOpacity(0.05),
                ),
                child: artist['image_url'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          artist['image_url'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Icon(Icons.person, color: Colors.white30, size: 30),
                        ),
                      )
                    : Center(child: Icon(Icons.person, color: Colors.white30, size: 30)),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    artist['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${_formatNumber(artist['followers'])} followers',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

// Artist Details Modal - Moved outside the state class
class ArtistDetailsModal extends StatelessWidget {
  final Map<String, dynamic> artist;

  const ArtistDetailsModal({required this.artist});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(
          color: Color(0xFF121212),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color(0xFF1DB954).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xFF121212),
                      ],
                    ),
                  ),
                  child: artist['image_url'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            artist['image_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.person, size: 100, color: Colors.white30),
                          ),
                        )
                      : Icon(Icons.person, size: 100, color: Colors.white30),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // Only show rank if it exists and is <= 999
                  if (artist['rank'] != null && artist['rank'] <= 999) ...[
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFF1DB954),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '#${artist['rank']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'in the world',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],

                  Text(
                    _formatFollowers(artist['followers']),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Followers',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 24),

                  Text(
                    _formatFollowers((artist['followers'] * 1.5).toInt()),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Monthly Listeners',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 24),

                  if (artist['genres'] != null && (artist['genres'] as List).isNotEmpty) ...[
                    Text(
                      'GENRES',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: (artist['genres'] as List).take(5).map((genre) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF1DB954).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Color(0xFF1DB954).withOpacity(0.5)),
                          ),
                          child: Text(
                            genre.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFollowers(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}