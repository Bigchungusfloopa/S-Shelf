import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/theme_provider.dart';
import '../models/models.dart';
import '../widgets/anime_dialog.dart';
import '../widgets/anime_info_modal.dart';
import '../widgets/themed_screen.dart';

class AnimeScreen extends StatefulWidget {
  const AnimeScreen({super.key});

  @override
  State<AnimeScreen> createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
  final ApiService _apiService = ApiService();
  List<Anime> _animeList = [];
  List<Anime> _filteredAnimeList = [];
  List<String> _availableGenres = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  String? _selectedGenre;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAnime();
    _loadGenres();
    _searchController.addListener(_filterAnime);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGenres() async {
    final genres = await _apiService.getAnimeGenres();
    setState(() {
      _availableGenres = genres;
    });
  }

  Future<void> _loadAnime() async {
    setState(() => _isLoading = true);
    final anime = await _apiService.getAnimeList(
      status: _selectedStatus == 'all' ? null : _selectedStatus,
      genre: _selectedGenre,
    );
    setState(() {
      _animeList = anime;
      _filteredAnimeList = anime;
      _isLoading = false;
    });
  }

  void _filterAnime() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredAnimeList = _animeList;
      } else {
        _filteredAnimeList = _animeList.where((anime) {
          return anime.title.toLowerCase().contains(query) ||
                 (anime.titleEnglish?.toLowerCase().contains(query) ?? false) ||
                 (anime.notes?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _showAnimeDialog([Anime? anime]) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AnimeDialog(anime: anime),
    );
    
    if (result == true) {
      _loadAnime();
    }
  }

  Future<void> _showAnimeInfo(Anime anime) async {
    await showDialog(
      context: context,
      builder: (context) => AnimeInfoModal(
        anime: anime,
        onUpdate: _loadAnime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      body: ThemedScreen(
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                      'My Anime',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: themeProvider.accentColor, size: 28),
                      onPressed: () => _showAnimeDialog(),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by title or notes...',
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: themeProvider.accentColor.withOpacity(0.7)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.white54),
                            onPressed: () {
                              _searchController.clear();
                              _filterAnime();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: themeProvider.accentColor.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: themeProvider.accentColor.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: themeProvider.accentColor, width: 2),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Status Filter
              _buildStatusFilter(themeProvider),
              SizedBox(height: 15),

              // Genre Filter
              if (_availableGenres.isNotEmpty)
                _buildGenreFilter(themeProvider),
              if (_availableGenres.isNotEmpty)
                SizedBox(height: 15),

              // Anime List
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: themeProvider.accentColor))
                    : _filteredAnimeList.isEmpty
                        ? _buildEmptyState(themeProvider)
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: _filteredAnimeList.length,
                            itemBuilder: (context, index) {
                              return _buildAnimeCard(_filteredAnimeList[index], themeProvider);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter(ThemeProvider themeProvider) {
    final statuses = [
      {'value': 'all', 'label': 'All'},
      {'value': 'watching', 'label': 'Watching'},
      {'value': 'completed', 'label': 'Completed'},
      {'value': 'plan_to_watch', 'label': 'Plan to Watch'},
      {'value': 'dropped', 'label': 'Dropped'},
    ];

    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = _selectedStatus == status['value'];
          
          return GestureDetector(
            onTap: () {
              setState(() => _selectedStatus = status['value']!);
              _loadAnime();
            },
            child: Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected ? themeProvider.accentGradient : null,
                color: isSelected ? null : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected 
                      ? themeProvider.accentColor.withOpacity(0.5)
                      : Colors.white.withOpacity(0.1),
                  width: 1,
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

  Widget _buildGenreFilter(ThemeProvider themeProvider) {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: _availableGenres.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedGenre == null;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedGenre = null);
                _loadAnime();
              },
              child: Container(
                margin: EdgeInsets.only(right: 8),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? themeProvider.accentColor.withOpacity(0.3)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? themeProvider.accentColor
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  'All Genres',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }
          
          final genre = _availableGenres[index - 1];
          final isSelected = _selectedGenre == genre;
          
          return GestureDetector(
            onTap: () {
              setState(() => _selectedGenre = genre);
              _loadAnime();
            },
            child: Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? themeProvider.accentColor.withOpacity(0.3)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                      ? themeProvider.accentColor
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                genre,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimeCard(Anime anime, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () => _showAnimeInfo(anime),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        child: GlassContainer(
          padding: EdgeInsets.all(16),
          opacity: 0.08,
          child: Row(
            children: [
              // Anime Image
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  gradient: themeProvider.accentGradient,
                  border: Border.all(color: themeProvider.accentColor.withOpacity(0.3)),
                ),
                child: anime.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          anime.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.movie, color: Colors.white),
                        ),
                      )
                    : Icon(Icons.movie, color: Colors.white),
              ),
              SizedBox(width: 16),

              // Anime Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${anime.currentEpisode}/${anime.episodes ?? '?'} episodes',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatusChip(anime.status, themeProvider),
                        if (anime.userScore != null) ...[
                          SizedBox(width: 8),
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            ' ${anime.userScore!.toStringAsFixed(1)}',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Click indicator
              Icon(
                Icons.info_outline,
                color: themeProvider.accentColor.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeProvider themeProvider) {
    Color color;
    switch (status) {
      case 'watching':
        color = Colors.green;
        break;
      case 'completed':
        color = themeProvider.accentColor;
        break;
      case 'plan_to_watch':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 80, color: themeProvider.accentColor.withOpacity(0.3)),
          SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty || _selectedGenre != null
                ? 'No anime found'
                : 'No anime yet',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty || _selectedGenre != null
                ? 'Try different filters'
                : 'Tap + to add your first anime',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
