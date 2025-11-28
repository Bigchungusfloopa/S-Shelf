import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/theme_provider.dart';
import '../theme/app_theme.dart';

class AnimeDialog extends StatefulWidget {
  final Anime? anime;

  const AnimeDialog({Key? key, this.anime}) : super(key: key);

  @override
  State<AnimeDialog> createState() => _AnimeDialogState();
}

class _AnimeDialogState extends State<AnimeDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  late TextEditingController _titleController;
  late TextEditingController _titleEnglishController;
  late TextEditingController _episodesController;
  late TextEditingController _currentEpisodeController;
  late TextEditingController _notesController;
  late TextEditingController _imageUrlController;
  late TextEditingController _synopsisController;
  late TextEditingController _searchController;
  
  String _selectedStatus = 'plan_to_watch';
  double _userScore = 5.0;
  bool _isSaving = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  int? _malId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.anime?.title ?? '');
    _titleEnglishController = TextEditingController(text: widget.anime?.titleEnglish ?? '');
    _episodesController = TextEditingController(text: widget.anime?.episodes?.toString() ?? '');
    _currentEpisodeController = TextEditingController(text: widget.anime?.currentEpisode.toString() ?? '0');
    _notesController = TextEditingController(text: widget.anime?.notes ?? '');
    _imageUrlController = TextEditingController(text: widget.anime?.imageUrl ?? '');
    _synopsisController = TextEditingController(text: widget.anime?.synopsis ?? '');
    _searchController = TextEditingController();
    _selectedStatus = widget.anime?.status ?? 'plan_to_watch';
    _userScore = widget.anime?.userScore ?? 5.0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleEnglishController.dispose();
    _episodesController.dispose();
    _currentEpisodeController.dispose();
    _notesController.dispose();
    _imageUrlController.dispose();
    _synopsisController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchMAL() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() => _isSearching = true);
    final results = await _apiService.searchAnimeMAL(_searchController.text);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _selectAnime(Map<String, dynamic> anime) {
    setState(() {
      _malId = anime['mal_id'];
      _titleController.text = anime['title'] ?? '';
      _titleEnglishController.text = anime['title_english'] ?? '';
      _episodesController.text = anime['episodes']?.toString() ?? '';
      _synopsisController.text = anime['synopsis'] ?? '';
      _imageUrlController.text = anime['image_url'] ?? '';
      _searchResults = [];
      _searchController.clear();
    });
  }

  Future<void> _saveAnime() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'mal_id': _malId,
      'title': _titleController.text,
      'title_english': _titleEnglishController.text.isEmpty ? null : _titleEnglishController.text,
      'episodes': _episodesController.text.isEmpty ? null : int.parse(_episodesController.text),
      'current_episode': int.parse(_currentEpisodeController.text),
      'status': _selectedStatus,
      'user_score': _userScore,
      'notes': _notesController.text.isEmpty ? null : _notesController.text,
      'image_url': _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
      'synopsis': _synopsisController.text.isEmpty ? null : _synopsisController.text,
    };

    final success = widget.anime == null
        ? await _apiService.createAnime(data)
        : await _apiService.updateAnime(widget.anime!.id, data);

    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save anime')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: themeProvider.accentColor.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: themeProvider.accentGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.movie, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    widget.anime == null ? 'Add Anime' : 'Edit Anime',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.withOpacity(0.5), width: 1.5),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MAL Search
                      Text(
                        'Search MyAnimeList',
                        style: TextStyle(color: themeProvider.accentColor, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search anime...',
                                hintStyle: TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                              ),
                              onSubmitted: (_) => _searchMAL(),
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isSearching ? null : _searchMAL,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.accentColor,
                              padding: EdgeInsets.all(16),
                            ),
                            child: _isSearching
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Icon(Icons.search),
                          ),
                        ],
                      ),
                      
                      // Search Results
                      if (_searchResults.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Container(
                          constraints: BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: themeProvider.accentColor.withOpacity(0.3)),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final anime = _searchResults[index];
                              return ListTile(
                                leading: anime['image_url'] != null
                                    ? Image.network(anime['image_url'], width: 40, fit: BoxFit.cover)
                                    : Icon(Icons.movie, color: Colors.white54),
                                title: Text(anime['title'], style: TextStyle(color: Colors.white)),
                                subtitle: Text(
                                  '${anime['episodes'] ?? '?'} episodes',
                                  style: TextStyle(color: Colors.white54),
                                ),
                                onTap: () => _selectAnime(anime),
                              );
                            },
                          ),
                        ),
                      ],
                      
                      SizedBox(height: 24),
                      
                      // Title
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Title *',
                          labelStyle: TextStyle(color: themeProvider.accentColor),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: themeProvider.accentColor.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: themeProvider.accentColor),
                          ),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      SizedBox(height: 16),

                      // English Title
                      TextFormField(
                        controller: _titleEnglishController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'English Title',
                          labelStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Episodes Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _currentEpisodeController,
                              style: TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Current Episode *',
                                labelStyle: TextStyle(color: themeProvider.accentColor),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: themeProvider.accentColor),
                                ),
                              ),
                              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _episodesController,
                              style: TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Total Episodes',
                                labelStyle: TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Status
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        dropdownColor: AppTheme.cardBackground,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: TextStyle(color: themeProvider.accentColor),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(value: 'watching', child: Text('Watching')),
                          DropdownMenuItem(value: 'completed', child: Text('Completed')),
                          DropdownMenuItem(value: 'plan_to_watch', child: Text('Plan to Watch')),
                          DropdownMenuItem(value: 'dropped', child: Text('Dropped')),
                        ],
                        onChanged: (value) => setState(() => _selectedStatus = value!),
                      ),
                      SizedBox(height: 16),

                      // Score
                      Text('Your Score: ${_userScore.toStringAsFixed(1)}', style: TextStyle(color: themeProvider.accentColor)),
                      Slider(
                        value: _userScore,
                        min: 0,
                        max: 10,
                        divisions: 20,
                        activeColor: themeProvider.accentColor,
                        inactiveColor: Colors.white24,
                        onChanged: (value) => setState(() => _userScore = value),
                      ),
                      SizedBox(height: 16),

                      // Synopsis
                      TextFormField(
                        controller: _synopsisController,
                        style: TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Synopsis',
                          labelStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        style: TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          labelStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Image URL
                      TextFormField(
                        controller: _imageUrlController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Image URL',
                          labelStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.red.withOpacity(0.5), width: 1.5),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveAnime,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.accentColor.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        side: BorderSide(color: themeProvider.accentColor, width: 1.5),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text('Save'),
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
}
