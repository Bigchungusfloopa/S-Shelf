import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/theme_provider.dart';
import '../theme/app_theme.dart';

class GameDialog extends StatefulWidget {
  final Game? game;

  const GameDialog({Key? key, this.game}) : super(key: key);

  @override
  State<GameDialog> createState() => _GameDialogState();
}

class _GameDialogState extends State<GameDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  late TextEditingController _titleController;
  late TextEditingController _platformController;
  late TextEditingController _playtimeController;
  late TextEditingController _notesController;
  late TextEditingController _coverUrlController;
  
  String _selectedStatus = 'plan_to_play';
  double _userScore = 5.0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.game?.title ?? '');
    _platformController = TextEditingController(text: widget.game?.platformPlayedOn ?? '');
    _playtimeController = TextEditingController(text: widget.game?.playtimeHours.toString() ?? '0');
    _notesController = TextEditingController(text: widget.game?.notes ?? '');
    _coverUrlController = TextEditingController(text: widget.game?.coverUrl ?? '');
    _selectedStatus = widget.game?.status ?? 'plan_to_play';
    _userScore = widget.game?.userScore ?? 5.0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _platformController.dispose();
    _playtimeController.dispose();
    _notesController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'title': _titleController.text,
      'platform_played_on': _platformController.text.isEmpty ? null : _platformController.text,
      'playtime_hours': double.parse(_playtimeController.text),
      'status': _selectedStatus,
      'user_score': _userScore,
      'notes': _notesController.text.isEmpty ? null : _notesController.text,
      'cover_url': _coverUrlController.text.isEmpty ? null : _coverUrlController.text,
    };

    final success = widget.game == null
        ? await _apiService.createGame(data)
        : await _apiService.updateGame(widget.game!.id, data);

    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save game')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
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
                  Icon(Icons.sports_esports, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    widget.game == null ? 'Add Game' : 'Edit Game',
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

                      // Platform
                      TextFormField(
                        controller: _platformController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Platform',
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

                      // Playtime
                      TextFormField(
                        controller: _playtimeController,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Playtime (hours)',
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
                          DropdownMenuItem(value: 'playing', child: Text('Playing')),
                          DropdownMenuItem(value: 'completed', child: Text('Completed')),
                          DropdownMenuItem(value: 'plan_to_play', child: Text('Plan to Play')),
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

                      // Cover URL
                      TextFormField(
                        controller: _coverUrlController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Cover Image URL',
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
                      onPressed: _isSaving ? null : _saveGame,
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
