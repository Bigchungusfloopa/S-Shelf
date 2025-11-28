import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/theme_provider.dart';
import '../models/models.dart';

class MangaDialog extends StatefulWidget {
  final Manga? manga;
  final Function(Manga) onSave;
  final Function()? onDelete;

  const MangaDialog({
    super.key,
    this.manga,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<MangaDialog> createState() => _MangaDialogState();
}

class _MangaDialogState extends State<MangaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _searchController = TextEditingController();
  
  late TextEditingController _titleController;
  late TextEditingController _currentChapterController;
  late TextEditingController _currentVolumeController;
  late TextEditingController _totalChaptersController;
  late TextEditingController _totalVolumesController;
  late TextEditingController _notesController;
  
  String _status = 'plan_to_read';
  double _rating = 0;
  String? _imageUrl;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.manga?.title ?? '');
    _currentChapterController = TextEditingController(
      text: widget.manga?.currentChapter.toString() ?? '0'
    );
    _currentVolumeController = TextEditingController(
      text: widget.manga?.currentVolume.toString() ?? '0'
    );
    _totalChaptersController = TextEditingController(
      text: widget.manga?.totalChapters?.toString() ?? ''
    );
    _totalVolumesController = TextEditingController(
      text: widget.manga?.totalVolumes?.toString() ?? ''
    );
    _notesController = TextEditingController(text: widget.manga?.notes ?? '');
    _status = widget.manga?.status ?? 'plan_to_read';
    _rating = widget.manga?.rating ?? 0;
    _imageUrl = widget.manga?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _currentChapterController.dispose();
    _currentVolumeController.dispose();
    _totalChaptersController.dispose();
    _totalVolumesController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchMAL() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final results = await _apiService.searchMangaMAL(_searchController.text);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching: $e')),
        );
      }
    }
  }

  void _selectMangaFromSearch(Map<String, dynamic> manga) {
    setState(() {
      _titleController.text = manga['title'] ?? '';
      _imageUrl = manga['image_url'];
      _totalChaptersController.text = manga['chapters']?.toString() ?? '';
      _totalVolumesController.text = manga['volumes']?.toString() ?? '';
      _searchResults.clear();
      _searchController.clear();
      _hasSearched = false;
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final manga = Manga(
        id: widget.manga?.id ?? 0,
        title: _titleController.text,
        currentChapter: int.tryParse(_currentChapterController.text) ?? 0,
        currentVolume: int.tryParse(_currentVolumeController.text) ?? 0,
        totalChapters: int.tryParse(_totalChaptersController.text),
        totalVolumes: int.tryParse(_totalVolumesController.text),
        status: _status,
        rating: _rating,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        imageUrl: _imageUrl,
      );
      widget.onSave(manga);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.accentColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with image
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.accentColor.withOpacity(0.3),
                        Color(0xFF1a1a1a),
                      ],
                    ),
                  ),
                  child: _imageUrl != null && _imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                          child: Image.network(
                            _imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.menu_book,
                                  size: 80,
                                  color: Colors.white30,
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.menu_book,
                            size: 80,
                            color: Colors.white30,
                          ),
                        ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search from MAL
                      if (widget.manga == null) ...[
                        Text(
                          'Search MyAnimeList',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Search manga...',
                                  hintStyle: TextStyle(color: Colors.white38),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.05),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: theme.accentColor),
                                  ),
                                ),
                                onSubmitted: (_) => _searchMAL(),
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              onPressed: _searchMAL,
                              icon: Icon(Icons.search),
                              color: theme.accentColor,
                              style: IconButton.styleFrom(
                                backgroundColor: theme.accentColor.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Search results
                        if (_isSearching)
                          Center(
                            child: CircularProgressIndicator(color: theme.accentColor),
                          )
                        else if (_searchResults.isNotEmpty)
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.accentColor.withOpacity(0.3)),
                            ),
                            child: ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final manga = _searchResults[index];
                                return ListTile(
                                  leading: manga['image_url'] != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: Image.network(
                                            manga['image_url'],
                                            width: 40,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.menu_book,
                                              color: Colors.white30,
                                            ),
                                          ),
                                        )
                                      : Icon(Icons.menu_book, color: Colors.white30),
                                  title: Text(
                                    manga['title'] ?? 'Unknown',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    'Ch: ${manga['chapters'] ?? '?'} • Vol: ${manga['volumes'] ?? '?'}',
                                    style: TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                  onTap: () => _selectMangaFromSearch(manga),
                                );
                              },
                            ),
                          )
                        else if (_hasSearched && _searchResults.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No results found',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          ),

                        SizedBox(height: 24),
                      ],

                      // Title
                      Text(
                        'Title',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter manga title',
                          hintStyle: TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.accentColor),
                          ),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Title is required' : null,
                      ),
                      SizedBox(height: 16),

                      // Progress
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Current Chapter', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _currentChapterController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.accentColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Chapters', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _totalChaptersController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: '?',
                                    hintStyle: TextStyle(color: Colors.white38),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.accentColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Volumes
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Current Volume', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _currentVolumeController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.accentColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Volumes', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _totalVolumesController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: '?',
                                    hintStyle: TextStyle(color: Colors.white38),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.accentColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Status
                      Text('Status', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _status,
                        dropdownColor: Color(0xFF2a2a2a),
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.accentColor),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(value: 'reading', child: Text('Reading')),
                          DropdownMenuItem(value: 'completed', child: Text('Completed')),
                          DropdownMenuItem(value: 'plan_to_read', child: Text('Plan to Read')),
                          DropdownMenuItem(value: 'dropped', child: Text('Dropped')),
                        ],
                        onChanged: (value) => setState(() => _status = value!),
                      ),
                      SizedBox(height: 16),

                      // Rating
                      Text('Rating', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () => setState(() => _rating = index + 1.0),
                          );
                        }),
                      ),
                      SizedBox(height: 16),

                      // Notes
                      Text('Notes', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        style: TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add notes...',
                          hintStyle: TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.accentColor),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          if (widget.manga != null && widget.onDelete != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  widget.onDelete!();
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.delete, size: 18),
                                label: Text('Delete'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          if (widget.manga != null && widget.onDelete != null)
                            SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.accentColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                widget.manga == null ? 'Add Manga' : 'Save Changes',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
