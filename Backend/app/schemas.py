from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

# Anime Schemas
class AnimeBase(BaseModel):
    title: str
    title_english: Optional[str] = None
    synopsis: Optional[str] = None
    image_url: Optional[str] = None
    episodes: Optional[int] = None
    current_episode: int = 0
    status: str = "plan_to_watch"
    user_score: Optional[float] = None
    notes: Optional[str] = None

class AnimeCreate(AnimeBase):
    pass

class AnimeUpdate(AnimeBase):
    pass

class AnimeResponse(AnimeBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Manga Schemas
class MangaBase(BaseModel):
    title: str
    current_chapter: int = 0
    current_volume: int = 0
    total_chapters: Optional[int] = None
    total_volumes: Optional[int] = None
    status: str = "plan_to_read"
    rating: float = 0.0
    notes: Optional[str] = None
    image_url: Optional[str] = None

class MangaCreate(MangaBase):
    pass

class MangaUpdate(MangaBase):
    pass

class MangaResponse(MangaBase):
    id: int
    mal_id: Optional[int] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Game Schemas
class GameBase(BaseModel):
    title: str
    cover_url: Optional[str] = None
    status: str = "plan_to_play"
    user_score: Optional[float] = None
    playtime_hours: float = 0.0
    notes: Optional[str] = None

class GameCreate(GameBase):
    pass

class GameUpdate(GameBase):
    pass

class GameResponse(GameBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Music Schemas
class MusicBase(BaseModel):
    title: str
    artist: str
    album: Optional[str] = None
    cover_url: Optional[str] = None
    status: str = "listening"
    rating: Optional[float] = None
    play_count: int = 0
    favorite: bool = False
    notes: Optional[str] = None

class MusicCreate(MusicBase):
    pass

class MusicUpdate(MusicBase):
    pass

class MusicResponse(MusicBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Stats Schema
class StatsResponse(BaseModel):
    total_anime: int
    total_manga: int
    total_games: int
    total_music: int
    anime_watching: int
    anime_completed: int
    anime_plan_to_watch: int
    anime_dropped: int
    manga_reading: int
    manga_completed: int
    manga_plan_to_read: int
    manga_dropped: int
    games_playing: int
    games_completed: int
    music_listening: int
    music_completed: int
    music_favorites: int
    total_episodes_watched: int
    total_chapters_read: int
    total_volumes_read: int
    total_playtime_hours: int
    total_plays: int

    class Config:
        from_attributes = True