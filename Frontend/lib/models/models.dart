class Anime {
  final int id;
  final String title;
  final String? titleEnglish;
  final String? synopsis;
  final String? imageUrl;
  final int? episodes;
  final int currentEpisode;
  final String status;
  final double? userScore;
  final String? notes;

  Anime({
    required this.id,
    required this.title,
    this.titleEnglish,
    this.synopsis,
    this.imageUrl,
    this.episodes,
    required this.currentEpisode,
    required this.status,
    this.userScore,
    this.notes,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'],
      title: json['title'],
      titleEnglish: json['title_english'],
      synopsis: json['synopsis'],
      imageUrl: json['image_url'],
      episodes: json['episodes'],
      currentEpisode: json['current_episode'] ?? 0,
      status: json['status'] ?? 'plan_to_watch',
      userScore: json['user_score']?.toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_english': titleEnglish,
      'synopsis': synopsis,
      'image_url': imageUrl,
      'episodes': episodes,
      'current_episode': currentEpisode,
      'status': status,
      'user_score': userScore,
      'notes': notes,
    };
  }
}

class Manga {
  final int id;
  final String title;
  final int currentChapter;
  final int currentVolume;
  final int? totalChapters;
  final int? totalVolumes;
  final String status;
  final double rating;
  final String? notes;
  final String? imageUrl;

  Manga({
    required this.id,
    required this.title,
    required this.currentChapter,
    required this.currentVolume,
    this.totalChapters,
    this.totalVolumes,
    required this.status,
    required this.rating,
    this.notes,
    this.imageUrl,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      id: json['id'],
      title: json['title'],
      currentChapter: json['current_chapter'] ?? 0,
      currentVolume: json['current_volume'] ?? 0,
      totalChapters: json['total_chapters'],
      totalVolumes: json['total_volumes'],
      status: json['status'] ?? 'plan_to_read',
      rating: (json['rating'] ?? 0).toDouble(),
      notes: json['notes'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'current_chapter': currentChapter,
      'current_volume': currentVolume,
      'total_chapters': totalChapters,
      'total_volumes': totalVolumes,
      'status': status,
      'rating': rating,
      'notes': notes,
      'image_url': imageUrl,
    };
  }
}

class Game {
  final int id;
  final String title;
  final String? coverUrl;
  final String status;
  final double? userScore;
  final double playtimeHours;
  final String? notes;

  Game({
    required this.id,
    required this.title,
    this.coverUrl,
    required this.status,
    this.userScore,
    required this.playtimeHours,
    this.notes,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      title: json['title'],
      coverUrl: json['cover_url'],
      status: json['status'] ?? 'plan_to_play',
      userScore: json['user_score']?.toDouble(),
      playtimeHours: (json['playtime_hours'] ?? 0).toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cover_url': coverUrl,
      'status': status,
      'user_score': userScore,
      'playtime_hours': playtimeHours,
      'notes': notes,
    };
  }
}

class Music {
  final int id;
  final String title;
  final String artist;
  final String? album;
  final String? coverUrl;
  final String status;
  final double? rating;
  final int playCount;
  final bool favorite;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Music({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.coverUrl,
    required this.status,
    this.rating,
    required this.playCount,
    required this.favorite,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      coverUrl: json['cover_url'],
      status: json['status'] ?? 'listening',
      rating: json['rating']?.toDouble(),
      playCount: json['play_count'] ?? 0,
      favorite: json['favorite'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'cover_url': coverUrl,
      'status': status,
      'rating': rating,
      'play_count': playCount,
      'favorite': favorite,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Stats {
  final int totalAnime;
  final int totalManga;
  final int totalGames;
  final int totalMusic;
  final int animeWatching;
  final int animeCompleted;
  final int animePlanToWatch;
  final int animeDropped;
  final int mangaReading;
  final int mangaCompleted;
  final int mangaPlanToRead;
  final int mangaDropped;
  final int gamesPlaying;
  final int gamesCompleted;
  final int musicListening;
  final int musicCompleted;
  final int musicFavorites;
  final int totalEpisodesWatched;
  final int totalChaptersRead;
  final int totalVolumesRead;
  final int totalPlaytimeHours;
  final int totalPlays;

  Stats({
    required this.totalAnime,
    required this.totalManga,
    required this.totalGames,
    required this.totalMusic,
    required this.animeWatching,
    required this.animeCompleted,
    required this.animePlanToWatch,
    required this.animeDropped,
    required this.mangaReading,
    required this.mangaCompleted,
    required this.mangaPlanToRead,
    required this.mangaDropped,
    required this.gamesPlaying,
    required this.gamesCompleted,
    required this.musicListening,
    required this.musicCompleted,
    required this.musicFavorites,
    required this.totalEpisodesWatched,
    required this.totalChaptersRead,
    required this.totalVolumesRead,
    required this.totalPlaytimeHours,
    required this.totalPlays,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalAnime: json['total_anime'] ?? 0,
      totalManga: json['total_manga'] ?? 0,
      totalGames: json['total_games'] ?? 0,
      totalMusic: json['total_music'] ?? 0,
      animeWatching: json['anime_watching'] ?? 0,
      animeCompleted: json['anime_completed'] ?? 0,
      animePlanToWatch: json['anime_plan_to_watch'] ?? 0,
      animeDropped: json['anime_dropped'] ?? 0,
      mangaReading: json['manga_reading'] ?? 0,
      mangaCompleted: json['manga_completed'] ?? 0,
      mangaPlanToRead: json['manga_plan_to_read'] ?? 0,
      mangaDropped: json['manga_dropped'] ?? 0,
      gamesPlaying: json['games_playing'] ?? 0,
      gamesCompleted: json['games_completed'] ?? 0,
      musicListening: json['music_listening'] ?? 0,
      musicCompleted: json['music_completed'] ?? 0,
      musicFavorites: json['music_favorites'] ?? 0,
      totalEpisodesWatched: json['total_episodes_watched'] ?? 0,
      totalChaptersRead: json['total_chapters_read'] ?? 0,
      totalVolumesRead: json['total_volumes_read'] ?? 0,
      totalPlaytimeHours: json['total_playtime_hours'] ?? 0,
      totalPlays: json['total_plays'] ?? 0,
    );
  }
}
