import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  // MAL Search - Anime
  Future<List<Map<String, dynamic>>> searchAnimeMAL(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mal/anime/search?q=$query&limit=20'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      }
      return [];
    } catch (e) {
      print('Error searching MAL anime: $e');
      return [];
    }
  }

  // MAL Search - Manga
  Future<List<Map<String, dynamic>>> searchMangaMAL(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mal/manga/search?q=$query&limit=20'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      }
      return [];
    } catch (e) {
      print('Error searching MAL manga: $e');
      return [];
    }
  }

  // Trending endpoints
  Future<List<Map<String, dynamic>>> getTrendingAnime() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/trending/anime?limit=10'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      }
      return [];
    } catch (e) {
      print('Error fetching trending anime: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingManga() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/trending/manga?limit=10'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      }
      return [];
    } catch (e) {
      print('Error fetching trending manga: $e');
      return [];
    }
  }

  // Anime endpoints
  Future<List<Anime>> getAnimeList({String? status, String? genre}) async {
    try {
      var url = '$baseUrl/anime';
      final params = <String, String>{};
      if (status != null) params['status'] = status;
      if (genre != null) params['genre'] = genre;
      
      if (params.isNotEmpty) {
        url += '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
      }
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Anime.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching anime: $e');
      return [];
    }
  }

  Future<bool> createAnime(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/anime'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error creating anime: $e');
      return false;
    }
  }

  Future<bool> updateAnime(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/anime/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating anime: $e');
      return false;
    }
  }

  Future<bool> deleteAnime(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/anime/$id'));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error deleting anime: $e');
      return false;
    }
  }

  // Manga endpoints
  Future<List<Manga>> getMangaList({String? status, String? genre}) async {
    try {
      var url = '$baseUrl/manga';
      final params = <String, String>{};
      if (status != null) params['status'] = status;
      if (genre != null) params['genre'] = genre;
      
      if (params.isNotEmpty) {
        url += '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
      }
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Manga.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching manga: $e');
      return [];
    }
  }

  Future<bool> createManga(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/manga'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error creating manga: $e');
      return false;
    }
  }

  Future<bool> updateManga(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/manga/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating manga: $e');
      return false;
    }
  }

  Future<bool> deleteManga(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/manga/$id'));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error deleting manga: $e');
      return false;
    }
  }

  // Games endpoints
  Future<List<Game>> getGamesList({String? status}) async {
    try {
      var url = '$baseUrl/games';
      if (status != null) {
        url += '?status=$status';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Game.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching games: $e');
      return [];
    }
  }

  Future<bool> createGame(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/games'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error creating game: $e');
      return false;
    }
  }

  Future<bool> updateGame(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/games/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating game: $e');
      return false;
    }
  }

  Future<bool> deleteGame(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/games/$id'));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error deleting game: $e');
      return false;
    }
  }

  // Stats endpoint
  Future<Stats> getStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats'));
      if (response.statusCode == 200) {
        return Stats.fromJson(json.decode(response.body));
      }
      return _getEmptyStats();
    } catch (e) {
      print('Error fetching stats: $e');
      return _getEmptyStats();
    }
  }

  Stats _getEmptyStats() {
    return Stats(
      totalAnime: 0,
      totalGames: 0,
      totalManga: 0,
      totalMusic: 0,
      animeWatching: 0,
      animeCompleted: 0,
      animePlanToWatch: 0,
      animeDropped: 0,
      gamesPlaying: 0,
      gamesCompleted: 0,
      mangaReading: 0,
      mangaCompleted: 0,
      mangaPlanToRead: 0,
      mangaDropped: 0,
      musicListening: 0,
      musicCompleted: 0,
      musicFavorites: 0,
      totalEpisodesWatched: 0,
      totalChaptersRead: 0,
      totalVolumesRead: 0,
      totalPlaytimeHours: 0,
      totalPlays: 0,
    );
  }

  Future<List<String>> getAnimeGenres() async {
    try {
      return [];
    } catch (e) {
      print('Error fetching genres: $e');
      return [];
    }
  }

  // Spotify - New Releases
  Future<List<Music>> getMusicList({String? status}) async {
    try {
      var url = '$baseUrl/music';
      if (status != null) {
        url += '?status=$status';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Music.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching music: $e');
      return [];
    }
  }

  Future<bool> createMusic(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error creating music: $e');
      return false;
    }
  }

  Future<bool> updateMusic(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/music/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating music: $e');
      return false;
    }
  }

  Future<bool> deleteMusic(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/music/$id'));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error deleting music: $e');
      return false;
    }
  }

  // Spotify endpoints
  Future<List<Map<String, dynamic>>> getSpotifyNewReleases() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/spotify/new-releases'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['albums']);
      }
      return [];
    } catch (e) {
      print('Error fetching Spotify new releases: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSpotifyPlaylists() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/spotify/playlists'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['playlists']);
      }
      return [];
    } catch (e) {
      print('Error fetching Spotify playlists: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSpotifyAlbums() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/spotify/albums'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['albums']);
      }
      return [];
    } catch (e) {
      print('Error fetching Spotify albums: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPlaylistTracks(String playlistId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/spotify/playlists/$playlistId/tracks'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['tracks']);
      }
      return [];
    } catch (e) {
      print('Error fetching playlist tracks: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAlbumTracks(String albumId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/spotify/albums/$albumId/tracks'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['tracks']);
      }
      return [];
    } catch (e) {
      print('Error fetching album tracks: $e');
      return [];
    }
  }
  
}
