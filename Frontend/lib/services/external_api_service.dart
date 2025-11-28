import 'dart:convert';
import 'package:http/http.dart' as http;

class ExternalApiService {
  // MyAnimeList API (using Jikan - unofficial MAL API, no key needed!)
  static const String jikanBaseUrl = 'https://api.jikan.moe/v4';
  
  // RAWG API for games
  static const String rawgBaseUrl = 'https://api.rawg.io/api';
  static const String rawgApiKey = 'YOUR_RAWG_API_KEY'; // Get free key from https://rawg.io/apidocs
  
  // Search anime from MyAnimeList
  Future<List<Map<String, dynamic>>> searchAnime(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$jikanBaseUrl/anime?q=${Uri.encodeComponent(query)}&limit=10'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error searching anime: $e');
      return [];
    }
  }
  
  // Get anime details by MAL ID
  Future<Map<String, dynamic>?> getAnimeDetails(int malId) async {
    try {
      final response = await http.get(
        Uri.parse('$jikanBaseUrl/anime/$malId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error getting anime details: $e');
      return null;
    }
  }
  
  // Search games from RAWG
  Future<List<Map<String, dynamic>>> searchGames(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$rawgBaseUrl/games?key=$rawgApiKey&search=${Uri.encodeComponent(query)}&page_size=10'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error searching games: $e');
      return [];
    }
  }
  
  // Get game details by RAWG ID
  Future<Map<String, dynamic>?> getGameDetails(int gameId) async {
    try {
      final response = await http.get(
        Uri.parse('$rawgBaseUrl/games/$gameId?key=$rawgApiKey'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting game details: $e');
      return null;
    }
  }
  
  // Convert MAL anime data to our format
  Map<String, dynamic> convertMalAnimeToLocal(Map<String, dynamic> malData) {
    return {
      'mal_id': malData['mal_id'],
      'title': malData['title'] ?? '',
      'title_english': malData['title_english'],
      'title_japanese': malData['title_japanese'],
      'synopsis': malData['synopsis'],
      'image_url': malData['images']?['jpg']?['large_image_url'] ?? 
                   malData['images']?['jpg']?['image_url'],
      'episodes': malData['episodes'],
      'status': 'plan_to_watch',
      'current_episode': 0,
    };
  }
  
  // Convert RAWG game data to our format
  Map<String, dynamic> convertRawgGameToLocal(Map<String, dynamic> rawgData) {
    final platforms = (rawgData['platforms'] as List?)
        ?.map((p) => p['platform']['name'])
        .join(', ') ?? '';
    
    final genres = (rawgData['genres'] as List?)
        ?.map((g) => g['name'])
        .join(', ') ?? '';
    
    return {
      'game_id': rawgData['id'],
      'title': rawgData['name'] ?? '',
      'cover_url': rawgData['background_image'],
      'description': rawgData['description_raw'] ?? rawgData['description'],
      'platforms': platforms,
      'genres': genres,
      'release_date': rawgData['released'],
      'status': 'plan_to_play',
      'playtime_hours': 0.0,
    };
  }
}
