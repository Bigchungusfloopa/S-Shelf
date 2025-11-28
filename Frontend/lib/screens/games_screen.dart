import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/theme_provider.dart';
import '../models/models.dart';
import '../widgets/game_dialog.dart';
import '../widgets/themed_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final ApiService _apiService = ApiService();
  List<Game> _gamesList = [];
  List<Game> _filteredGamesList = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGames();
    _searchController.addListener(_filterGames);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    final games = await _apiService.getGamesList(
      status: _selectedStatus == 'all' ? null : _selectedStatus,
    );
    setState(() {
      _gamesList = games;
      _filteredGamesList = games;
      _isLoading = false;
    });
  }

  void _filterGames() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredGamesList = _gamesList;
      } else {
        _filteredGamesList = _gamesList.where((game) {
          return game.title.toLowerCase().contains(query) ||
                 (game.notes?.toLowerCase().contains(query) ?? false) ||
                 (game.platformPlayedOn?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _showGameDialog([Game? game]) async {
    final result = await showDialog(
      context: context,
      builder: (context) => GameDialog(game: game),
    );
    
    if (result == true) {
      _loadGames();
    }
  }

  Future<void> _deleteGame(Game game) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: Text('Delete Game', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${game.title}"?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white54,
            ),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.withOpacity(0.5)),
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await _apiService.deleteGame(game.id);
      _loadGames();
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
                      'My Games',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: themeProvider.accentColor, size: 28),
                      onPressed: () => _showGameDialog(),
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
                    hintText: 'Search by title, platform or notes...',
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: themeProvider.accentColor.withOpacity(0.7)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.white54),
                            onPressed: () {
                              _searchController.clear();
                              _filterGames();
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

              // Games List
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: themeProvider.accentColor))
                    : _filteredGamesList.isEmpty
                        ? _buildEmptyState(themeProvider)
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: _filteredGamesList.length,
                            itemBuilder: (context, index) {
                              return _buildGameCard(_filteredGamesList[index], themeProvider);
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
      {'value': 'playing', 'label': 'Playing'},
      {'value': 'completed', 'label': 'Completed'},
      {'value': 'plan_to_play', 'label': 'Plan to Play'},
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
              _loadGames();
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

  Widget _buildGameCard(Game game, ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: EdgeInsets.all(16),
        opacity: 0.08,
        child: Row(
          children: [
            // Game Cover
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(8),
                gradient: themeProvider.accentGradient,
                border: Border.all(color: themeProvider.accentColor.withOpacity(0.3)),
              ),
              child: game.coverUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        game.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.sports_esports, color: Colors.white),
                      ),
                    )
                  : Icon(Icons.sports_esports, color: Colors.white),
            ),
            SizedBox(width: 16),

            // Game Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  if (game.platformPlayedOn != null)
                    Text(
                      game.platformPlayedOn!,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  if (game.playtimeHours > 0)
                    Text(
                      '${game.playtimeHours.toStringAsFixed(1)} hours',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      _buildStatusChip(game.status, themeProvider),
                      if (game.userScore != null) ...[
                        SizedBox(width: 8),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          ' ${game.userScore!.toStringAsFixed(1)}',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton(
              icon: Icon(Icons.more_vert, color: themeProvider.accentColor.withOpacity(0.7)),
              color: AppTheme.cardBackground,
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: themeProvider.accentColor, size: 20),
                      SizedBox(width: 10),
                      Text('Edit', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  onTap: () => Future.delayed(
                    Duration.zero,
                    () => _showGameDialog(game),
                  ),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 10),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  onTap: () => Future.delayed(
                    Duration.zero,
                    () => _deleteGame(game),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeProvider themeProvider) {
    Color color;
    switch (status) {
      case 'playing':
        color = Colors.green;
        break;
      case 'completed':
        color = themeProvider.accentColor;
        break;
      case 'plan_to_play':
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
          Icon(Icons.sports_esports_outlined, size: 80, color: themeProvider.accentColor.withOpacity(0.3)),
          SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'No games found'
                : 'No games yet',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try a different search'
                : 'Tap + to add your first game',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
