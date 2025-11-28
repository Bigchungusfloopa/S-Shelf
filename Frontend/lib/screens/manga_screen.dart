import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/theme_provider.dart';
import '../models/models.dart';
import '../widgets/manga_dialog.dart';
import '../widgets/manga_info_modal.dart';
import '../widgets/themed_screen.dart';

class MangaScreen extends StatefulWidget {
  const MangaScreen({super.key});

  @override
  State<MangaScreen> createState() => _MangaScreenState();
}

class _MangaScreenState extends State<MangaScreen> {
  final ApiService _apiService = ApiService();
  List<Manga> _mangaList = [];
  List<Manga> _filteredMangaList = [];
  List<String> _availableGenres = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  String? _selectedGenre;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadManga();
    _loadGenres();
    _searchController.addListener(_filterManga);
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

  Future<void> _loadManga() async {
    setState(() => _isLoading = true);
    final manga = await _apiService.getMangaList(
      status: _selectedStatus == 'all' ? null : _selectedStatus,
      genre: _selectedGenre,
    );
    setState(() {
      _mangaList = manga;
      _filteredMangaList = manga;
      _isLoading = false;
    });
  }

  void _filterManga() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMangaList = _mangaList;
      } else {
        _filteredMangaList = _mangaList.where((manga) {
          return manga.title.toLowerCase().contains(query) ||
                 (manga.notes?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  void _showMangaDialog({Manga? manga}) {
    showDialog(
      context: context,
      builder: (context) => MangaDialog(
        manga: manga,
        onSave: (savedManga) async {
          if (manga == null) {
            // Create new manga
            final success = await _apiService.createManga(savedManga.toJson());
            if (success) {
              _loadManga();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Manga added successfully')),
                );
              }
            }
          } else {
            // Update existing manga
            final success = await _apiService.updateManga(
              manga.id,
              savedManga.toJson(),
            );
            if (success) {
              _loadManga();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Manga updated successfully')),
                );
              }
            }
          }
        },
        onDelete: manga != null ? () async {
          final success = await _apiService.deleteManga(manga.id);
          if (success) {
            _loadManga();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Manga deleted')),
              );
            }
          }
        } : null,
      ),
    );
  }

  Future<void> _showMangaInfo(Manga manga) async {
    await showDialog(
      context: context,
      builder: (context) => MangaInfoModal(
        manga: manga,
        onUpdate: _loadManga,
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
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'My Manga',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: themeProvider.accentColor, size: 28),
                      onPressed: () => _showMangaDialog(),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by title or notes...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: themeProvider.accentColor.withOpacity(0.7)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white54),
                            onPressed: () {
                              _searchController.clear();
                              _filterManga();
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
              const SizedBox(height: 15),

              // Status Filter
              _buildStatusFilter(themeProvider),
              const SizedBox(height: 15),

              // Genre Filter
              if (_availableGenres.isNotEmpty)
                _buildGenreFilter(themeProvider),
              if (_availableGenres.isNotEmpty)
                const SizedBox(height: 15),

              // Manga List
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: themeProvider.accentColor))
                    : _filteredMangaList.isEmpty
                        ? _buildEmptyState(themeProvider)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: _filteredMangaList.length,
                            itemBuilder: (context, index) {
                              return _buildMangaCard(_filteredMangaList[index], themeProvider);
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
      {'value': 'reading', 'label': 'Reading'},
      {'value': 'completed', 'label': 'Completed'},
      {'value': 'plan_to_read', 'label': 'Plan to Read'},
      {'value': 'dropped', 'label': 'Dropped'},
    ];

    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = _selectedStatus == status['value'];
          
          return GestureDetector(
            onTap: () {
              setState(() => _selectedStatus = status['value']!);
              _loadManga();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _availableGenres.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedGenre == null;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedGenre = null);
                _loadManga();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              _loadManga();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildMangaCard(Manga manga, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () => _showMangaInfo(manga),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          opacity: 0.08,
          child: Row(
            children: [
              // Manga Cover
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  gradient: themeProvider.accentGradient,
                  border: Border.all(color: themeProvider.accentColor.withOpacity(0.3)),
                ),
                child: manga.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          manga.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.menu_book, color: Colors.white),
                        ),
                      )
                    : Icon(Icons.menu_book, color: Colors.white),
              ),
              const SizedBox(width: 16),

              // Manga Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manga.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ch: ${manga.currentChapter}/${manga.totalChapters ?? '?'} | Vol: ${manga.currentVolume}/${manga.totalVolumes ?? '?'}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatusChip(manga.status, themeProvider),
                        SizedBox(width: 8),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          ' ${manga.rating.toStringAsFixed(1)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
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
      case 'reading':
        color = Colors.green;
        break;
      case 'completed':
        color = themeProvider.accentColor;
        break;
      case 'plan_to_read':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          Icon(Icons.menu_book_outlined, size: 80, color: themeProvider.accentColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty || _selectedGenre != null
                ? 'No manga found'
                : 'No manga yet',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty || _selectedGenre != null
                ? 'Try different filters'
                : 'Tap + to add your first manga',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}