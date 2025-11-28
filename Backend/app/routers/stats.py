from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from .. import models
from ..database import get_db

router = APIRouter(prefix="/stats", tags=["stats"])

@router.get("")
def get_stats(db: Session = Depends(get_db)):
    """Get comprehensive statistics"""
    
    # Anime stats
    total_anime = db.query(models.Anime).count()
    anime_watching = db.query(models.Anime).filter(models.Anime.status == "watching").count()
    anime_completed = db.query(models.Anime).filter(models.Anime.status == "completed").count()
    anime_plan_to_watch = db.query(models.Anime).filter(models.Anime.status == "plan_to_watch").count()
    anime_dropped = db.query(models.Anime).filter(models.Anime.status == "dropped").count()
    total_episodes = db.query(func.sum(models.Anime.current_episode)).scalar() or 0
    
    # Manga stats
    total_manga = db.query(models.Manga).count()
    manga_reading = db.query(models.Manga).filter(models.Manga.status == "reading").count()
    manga_completed = db.query(models.Manga).filter(models.Manga.status == "completed").count()
    manga_plan_to_read = db.query(models.Manga).filter(models.Manga.status == "plan_to_read").count()
    manga_dropped = db.query(models.Manga).filter(models.Manga.status == "dropped").count()
    total_chapters = db.query(func.sum(models.Manga.current_chapter)).scalar() or 0
    total_volumes = db.query(func.sum(models.Manga.current_volume)).scalar() or 0
    
    # Games stats (keeping for compatibility)
    total_games = 0
    games_playing = 0
    games_completed = 0
    total_playtime = 0
    
    # Music stats - using 0 since Music table doesn't exist yet
    total_music = 0
    music_listening = 0
    music_completed = 0
    music_favorites = 0
    total_plays = 0
    
    # Try to get music stats if the table exists
    try:
        if hasattr(models, 'Music'):
            total_music = db.query(models.Music).count()
            music_listening = db.query(models.Music).filter(models.Music.status == "listening").count()
            music_completed = db.query(models.Music).filter(models.Music.status == "completed").count()
            music_favorites = db.query(models.Music).filter(models.Music.favorite == True).count()
            total_plays = db.query(func.sum(models.Music.play_count)).scalar() or 0
    except:
        pass  # Music table doesn't exist, use 0s
    
    print(f"[STATS] Returning - Anime: {total_anime}, Manga: {total_manga}, Music: {total_music}")
    
    return {
        "total_anime": total_anime,
        "total_manga": total_manga,
        "total_games": total_games,
        "total_music": total_music,
        "anime_watching": anime_watching,
        "anime_completed": anime_completed,
        "anime_plan_to_watch": anime_plan_to_watch,
        "anime_dropped": anime_dropped,
        "manga_reading": manga_reading,
        "manga_completed": manga_completed,
        "manga_plan_to_read": manga_plan_to_read,
        "manga_dropped": manga_dropped,
        "games_playing": games_playing,
        "games_completed": games_completed,
        "music_listening": music_listening,
        "music_completed": music_completed,
        "music_favorites": music_favorites,
        "total_episodes_watched": int(total_episodes),
        "total_chapters_read": int(total_chapters),
        "total_volumes_read": int(total_volumes),
        "total_playtime_hours": int(total_playtime),
        "total_plays": int(total_plays),
    }
