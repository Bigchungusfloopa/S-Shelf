import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../services/theme_provider.dart';
import '../models/models.dart';
import '../widgets/themed_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ApiService _apiService = ApiService();
  Stats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _apiService.getStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stats: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: ThemedScreen(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadStats,
            color: themeProvider.accentColor,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: themeProvider.accentColor,
                    ),
                  )
                : _stats == null
                    ? Center(
                        child: Text(
                          'No statistics available',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_back, color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Statistics',
                                    style: theme.textTheme.displayMedium,
                                  ),
                                ],
                              ),
                              SizedBox(height: 30),

                              // Overview Cards
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
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Anime',
                                      _stats!.totalAnime.toString(),
                                      Icons.tv_outlined,
                                      themeProvider.accentColor,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Manga',
                                      _stats!.totalManga.toString(),
                                      Icons.menu_book_outlined,
                                      themeProvider.accentColor,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Music',
                                      _stats!.totalMusic.toString(),
                                      Icons.music_note_outlined,
                                      Color(0xFF1DB954),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 40),

                              // Anime Stats
                              _buildSectionHeader('ANIME STATISTICS', themeProvider),
                              SizedBox(height: 16),
                              _buildDetailedStatsGrid(
                                [
                                  {'label': 'Watching', 'value': _stats!.animeWatching},
                                  {'label': 'Completed', 'value': _stats!.animeCompleted},
                                  {'label': 'Plan to Watch', 'value': _stats!.animePlanToWatch},
                                  {'label': 'Dropped', 'value': _stats!.animeDropped},
                                ],
                                themeProvider,
                              ),
                              SizedBox(height: 16),
                              _buildInfoCard(
                                'Episodes Watched',
                                _stats!.totalEpisodesWatched.toString(),
                                Icons.play_circle_outline,
                                themeProvider.accentColor,
                              ),

                              SizedBox(height: 40),

                              // Manga Stats
                              _buildSectionHeader('MANGA STATISTICS', themeProvider),
                              SizedBox(height: 16),
                              _buildDetailedStatsGrid(
                                [
                                  {'label': 'Reading', 'value': _stats!.mangaReading},
                                  {'label': 'Completed', 'value': _stats!.mangaCompleted},
                                  {'label': 'Plan to Read', 'value': _stats!.mangaPlanToRead},
                                  {'label': 'Dropped', 'value': _stats!.mangaDropped},
                                ],
                                themeProvider,
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoCard(
                                      'Chapters Read',
                                      _stats!.totalChaptersRead.toString(),
                                      Icons.auto_stories_outlined,
                                      themeProvider.accentColor,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _buildInfoCard(
                                      'Volumes Read',
                                      _stats!.totalVolumesRead.toString(),
                                      Icons.book_outlined,
                                      themeProvider.accentColor,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 40),

                              // Music Stats
                              _buildSectionHeader('MUSIC STATISTICS', themeProvider),
                              SizedBox(height: 16),
                              _buildDetailedStatsGrid(
                                [
                                  {'label': 'Listening', 'value': _stats!.musicListening},
                                  {'label': 'Completed', 'value': _stats!.musicCompleted},
                                  {'label': 'Favorites', 'value': _stats!.musicFavorites},
                                  {'label': 'Total Plays', 'value': _stats!.totalPlays},
                                ],
                                themeProvider,
                              ),

                              SizedBox(height: 40),

                              // Distribution Chart
                              _buildSectionHeader('LIBRARY DISTRIBUTION', themeProvider),
                              SizedBox(height: 16),
                              _buildDistributionChart(themeProvider),
                            ],
                          ),
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeProvider theme) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white60,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatsGrid(List<Map<String, dynamic>> stats, ThemeProvider theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.accentColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  stat['label'],
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                stat['value'].toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart(ThemeProvider theme) {
    final total = _stats!.totalAnime + _stats!.totalManga + _stats!.totalMusic;
    
    if (total == 0) {
      return Container(
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No data to display',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return Container(
      height: 300,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.accentColor.withOpacity(0.2),
        ),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: [
            PieChartSectionData(
              value: _stats!.totalAnime.toDouble(),
              title: '${((_stats!.totalAnime / total) * 100).toStringAsFixed(0)}%',
              color: theme.accentColor,
              radius: 100,
              titleStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            PieChartSectionData(
              value: _stats!.totalManga.toDouble(),
              title: '${((_stats!.totalManga / total) * 100).toStringAsFixed(0)}%',
              color: theme.accentColor.withOpacity(0.6),
              radius: 100,
              titleStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            PieChartSectionData(
              value: _stats!.totalMusic.toDouble(),
              title: '${((_stats!.totalMusic / total) * 100).toStringAsFixed(0)}%',
              color: Color(0xFF1DB954),
              radius: 100,
              titleStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
