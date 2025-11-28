from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, or_
from . import models, schemas
from typing import List, Optional

# Anime CRUD
async def get_anime(db: AsyncSession, anime_id: int):
    result = await db.execute(select(models.Anime).filter(models.Anime.id == anime_id))
    return result.scalar_one_or_none()

async def get_all_anime(db: AsyncSession, skip: int = 0, limit: int = 100, status: Optional[str] = None):
    query = select(models.Anime)
    if status:
        query = query.filter(models.Anime.status == status)
    query = query.offset(skip).limit(limit).order_by(models.Anime.updated_at.desc())
    result = await db.execute(query)
    return result.scalars().all()

async def search_anime(db: AsyncSession, search_term: str):
    query = select(models.Anime).filter(
        or_(
            models.Anime.title.ilike(f"%{search_term}%"),
            models.Anime.title_english.ilike(f"%{search_term}%")
        )
    )
    result = await db.execute(query)
    return result.scalars().all()

async def create_anime(db: AsyncSession, anime: schemas.AnimeCreate):
    db_anime = models.Anime(**anime.model_dump())
    db.add(db_anime)
    await db.commit()
    await db.refresh(db_anime)
    return db_anime

async def update_anime(db: AsyncSession, anime_id: int, anime: schemas.AnimeUpdate):
    db_anime = await get_anime(db, anime_id)
    if not db_anime:
        return None
    
    update_data = anime.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_anime, key, value)
    
    await db.commit()
    await db.refresh(db_anime)
    return db_anime

async def delete_anime(db: AsyncSession, anime_id: int):
    db_anime = await get_anime(db, anime_id)
    if not db_anime:
        return None
    await db.delete(db_anime)
    await db.commit()
    return db_anime


# Game CRUD
async def get_game(db: AsyncSession, game_id: int):
    result = await db.execute(select(models.Game).filter(models.Game.id == game_id))
    return result.scalar_one_or_none()

async def get_all_games(db: AsyncSession, skip: int = 0, limit: int = 100, status: Optional[str] = None):
    query = select(models.Game)
    if status:
        query = query.filter(models.Game.status == status)
    query = query.offset(skip).limit(limit).order_by(models.Game.updated_at.desc())
    result = await db.execute(query)
    return result.scalars().all()

async def search_games(db: AsyncSession, search_term: str):
    query = select(models.Game).filter(models.Game.title.ilike(f"%{search_term}%"))
    result = await db.execute(query)
    return result.scalars().all()

async def create_game(db: AsyncSession, game: schemas.GameCreate):
    db_game = models.Game(**game.model_dump())
    db.add(db_game)
    await db.commit()
    await db.refresh(db_game)
    return db_game

async def update_game(db: AsyncSession, game_id: int, game: schemas.GameUpdate):
    db_game = await get_game(db, game_id)
    if not db_game:
        return None
    
    update_data = game.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_game, key, value)
    
    await db.commit()
    await db.refresh(db_game)
    return db_game

async def delete_game(db: AsyncSession, game_id: int):
    db_game = await get_game(db, game_id)
    if not db_game:
        return None
    await db.delete(db_game)
    await db.commit()
    return db_game


# Stats
async def get_stats(db: AsyncSession):
    anime_count = await db.execute(select(func.count(models.Anime.id)))
    game_count = await db.execute(select(func.count(models.Game.id)))
    
    anime_watching = await db.execute(
        select(func.count(models.Anime.id)).filter(models.Anime.status == "watching")
    )
    anime_completed = await db.execute(
        select(func.count(models.Anime.id)).filter(models.Anime.status == "completed")
    )
    
    games_playing = await db.execute(
        select(func.count(models.Game.id)).filter(models.Game.status == "playing")
    )
    games_completed = await db.execute(
        select(func.count(models.Game.id)).filter(models.Game.status == "completed")
    )
    
    total_episodes = await db.execute(select(func.sum(models.Anime.current_episode)))
    total_playtime = await db.execute(select(func.sum(models.Game.playtime_hours)))
    
    return {
        "total_anime": anime_count.scalar() or 0,
        "total_games": game_count.scalar() or 0,
        "anime_watching": anime_watching.scalar() or 0,
        "anime_completed": anime_completed.scalar() or 0,
        "games_playing": games_playing.scalar() or 0,
        "games_completed": games_completed.scalar() or 0,
        "total_episodes_watched": total_episodes.scalar() or 0,
        "total_playtime_hours": total_playtime.scalar() or 0.0
    }