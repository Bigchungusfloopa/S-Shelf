import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/theme_provider.dart';
import '../models/models.dart';
import '../widgets/themed_screen.dart';
import 'anime_screen.dart';
import 'manga_screen.dart';
import 'music_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  Stats? _stats;
  List<Map<String, dynamic>> _trendingAnime = [];
  List<Map<String, dynamic>> _trendingManga = [];
  List<Map<String, dynamic>> _newReleases = [];
  bool _loadingStats = true;
  bool _loadingTrendingAnime = true;
  bool _loadingTrendingManga = true;
  bool _loadingNewReleases = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadStats(),
      _loadTrendingAnime(),
      _loadTrendingManga(),
      _loadNewReleases(),
    ]);
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _loadingStats = true);
    try {
      final stats = await _apiService.getStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _loadingStats = false;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        setState(() => _loadingStats = false);
      }
    }
  }

  Future<void> _loadTrendingAnime() async {
    if (!mounted) return;
    setState(() => _loadingTrendingAnime = true);
    try {
      final trending = await _apiService.getTrendingAnime();
      if (mounted) {
        setState(() {
          _trendingAnime = trending;
          _loadingTrendingAnime = false;
        });
      }
    } catch (e) {
      print('Error loading trending anime: $e');
      if (mounted) {
        setState(() => _loadingTrendingAnime = false);
      }
    }
  }

  Future<void> _loadTrendingManga() async {
    if (!mounted) return;
    setState(() => _loadingTrendingManga = true);
    try {
      final trending = await _apiService.getTrendingManga();
      if (mounted) {
        setState(() {
          _trendingManga = trending;
          _loadingTrendingManga = false;
        });
      }
    } catch (e) {
      print('Error loading trending manga: $e');
      if (mounted) {
        setState(() => _loadingTrendingManga = false);
      }
    }
  }

  Future<void> _loadNewReleases() async {
    if (!mounted) return;
    setState(() => _loadingNewReleases = true);
    
    try {
      final releases = await _apiService.getSpotifyNewReleases();
      
      if (mounted) {
        setState(() {
          _newReleases = releases;
          _loadingNewReleases = false;
        });
      }
    } catch (e) {
      print('Error loading new releases: $e');
      if (mounted) {
        setState(() => _loadingNewReleases = false);
      }
    }
  }

  void _navigateAndRefresh(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    // Refresh stats when returning
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: ThemedScreen(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadAllData,
            color: themeProvider.accentColor,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Home',
                              style: theme.textTheme.displayLarge,
                            ),
                            Text(
                              '...',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.settings_outlined, color: Colors.white),
                          onPressed: () => _navigateAndRefresh(SettingsScreen()),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats Overview
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OVERVIEW',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 16),
                        _loadingStats
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator(
                                    color: themeProvider.accentColor,
                                  ),
                                ),
                              )
                            : _stats != null
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: _buildCompactStatCard(
                                          'Anime',
                                          _stats!.totalAnime,
                                          '${_stats!.animeWatching} watching',
                                          Icons.tv_outlined,
                                          theme,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: _buildCompactStatCard(
                                          'Manga',
                                          _stats!.totalManga,
                                          '${_stats!.mangaReading} reading',
                                          Icons.menu_book_outlined,
                                          theme,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: _buildCompactStatCard(
                                          'Music',
                                          _stats!.totalMusic,
                                          '${_stats!.musicListening} listening',
                                          Icons.music_note_outlined,
                                          theme,
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 30)),

                // Library Navigation
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LIBRARY',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCompactNavCard(
                                context,
                                title: 'Anime',
                                icon: Icons.tv_outlined,
                                count: _stats?.totalAnime ?? 0,
                                color: themeProvider.accentColor,
                                onTap: () => _navigateAndRefresh(AnimeScreen()),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildCompactNavCard(
                                context,
                                title: 'Manga',
                                icon: Icons.menu_book_outlined,
                                count: _stats?.totalManga ?? 0,
                                color: themeProvider.accentColor,
                                onTap: () => _navigateAndRefresh(MangaScreen()),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCompactNavCard(
                                context,
                                title: 'Music',
                                icon: Icons.music_note_outlined,
                                count: _stats?.totalMusic ?? 0,
                                color: themeProvider.accentColor,
                                onTap: () => _navigateAndRefresh(MusicScreen()),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildCompactNavCard(
                                context,
                                title: 'Stats',
                                icon: Icons.bar_chart_outlined,
                                count: 0,
                                color: themeProvider.accentColor,
                                onTap: () => _navigateAndRefresh(StatsScreen()),
                                hideCount: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 40)),

                // Trending Anime
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TRENDING ANIME',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'Currently Airing',
                              style: TextStyle(
                                color: themeProvider.accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _loadingTrendingAnime
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator(
                                    color: themeProvider.accentColor,
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 280,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _trendingAnime.length,
                                  itemBuilder: (context, index) {
                                    final anime = _trendingAnime[index];
                                    return _buildTrendingCard(anime, theme);
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 40)),

                // Popular Manga
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'POPULAR MANGA',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'Most Favorited',
                              style: TextStyle(
                                color: themeProvider.accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _loadingTrendingManga
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator(
                                    color: themeProvider.accentColor,
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 280,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _trendingManga.length,
                                  itemBuilder: (context, index) {
                                    final manga = _trendingManga[index];
                                    return _buildTrendingCard(manga, theme);
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 40)),

                // New Releases from Followed Artists
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'NEW RELEASES',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            if (_newReleases.isNotEmpty)
                              TextButton(
                                onPressed: () => _navigateAndRefresh(MusicScreen()),
                                child: Text(
                                  'View All',
                                  style: TextStyle(
                                    color: Color(0xFF1DB954),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _loadingNewReleases
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF1DB954),
                                  ),
                                ),
                              )
                            : _newReleases.isEmpty
                                ? Container(
                                    padding: EdgeInsets.all(40),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.03),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Color(0xFF1DB954).withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.music_note,
                                          size: 48,
                                          color: Color(0xFF1DB954).withOpacity(0.3),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Connect Spotify to see new releases',
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: () => _navigateAndRefresh(MusicScreen()),
                                          icon: Icon(Icons.music_note, size: 16),
                                          label: Text('Connect Spotify'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF1DB954),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(
                                    height: 240,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _newReleases.length,
                                      itemBuilder: (context, index) {
                                        final album = _newReleases[index];
                                        return _buildNewReleaseCard(album, theme);
                                      },
                                    ),
                                  ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStatCard(
    String label,
    int value,
    String subtitle,
    IconData icon,
    ThemeData theme,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.accentColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: themeProvider.accentColor, size: 20),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNavCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
    bool hideCount = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!hideCount)
                      Text(
                        '$count items',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCard(Map<String, dynamic> item, ThemeData theme) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: themeProvider.accentColor.withOpacity(0.2),
              ),
            ),
            child: item['image_url'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.image, color: Colors.white30),
                    ),
                  )
                : Icon(Icons.image, color: Colors.white30),
          ),
          SizedBox(height: 8),
          Text(
            item['title'] ?? 'Unknown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          if (item['score'] != null)
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 14),
                SizedBox(width: 4),
                Text(
                  item['score'].toString(),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNewReleaseCard(Map<String, dynamic> album, ThemeData theme) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: Color(0xFF1DB954).withOpacity(0.2),
              ),
            ),
            child: album['image_url'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      album['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.album, color: Colors.white30, size: 60),
                    ),
                  )
                : Icon(Icons.album, color: Colors.white30, size: 60),
          ),
          SizedBox(height: 8),
          Text(
            album['name'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            album['artist'],
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFF1DB954).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  album['album_type'].toString().toUpperCase(),
                  style: TextStyle(
                    color: Color(0xFF1DB954),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 6),
              Text(
                album['release_date'].toString().substring(0, 4),
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
