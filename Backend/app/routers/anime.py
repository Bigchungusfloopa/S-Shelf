from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/anime", tags=["anime"])

@router.get("", response_model=List[schemas.AnimeResponse])
def get_anime_list(
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    query = db.query(models.Anime)
    
    if status:
        query = query.filter(models.Anime.status == status)
    
    anime = query.order_by(models.Anime.updated_at.desc()).offset(skip).limit(limit).all()
    return anime

@router.get("/{anime_id}", response_model=schemas.AnimeResponse)
def get_anime(anime_id: int, db: Session = Depends(get_db)):
    anime = db.query(models.Anime).filter(models.Anime.id == anime_id).first()
    if not anime:
        raise HTTPException(status_code=404, detail="Anime not found")
    return anime

@router.post("", response_model=schemas.AnimeResponse)
def create_anime(anime: schemas.AnimeCreate, db: Session = Depends(get_db)):
    db_anime = models.Anime(**anime.dict())
    db.add(db_anime)
    db.commit()
    db.refresh(db_anime)
    return db_anime

@router.put("/{anime_id}", response_model=schemas.AnimeResponse)
def update_anime(anime_id: int, anime: schemas.AnimeUpdate, db: Session = Depends(get_db)):
    db_anime = db.query(models.Anime).filter(models.Anime.id == anime_id).first()
    if not db_anime:
        raise HTTPException(status_code=404, detail="Anime not found")
    
    for key, value in anime.dict(exclude_unset=True).items():
        setattr(db_anime, key, value)
    
    db.commit()
    db.refresh(db_anime)
    return db_anime

@router.patch("/{anime_id}", response_model=schemas.AnimeResponse)
def partial_update_anime(anime_id: int, anime: schemas.AnimeUpdate, db: Session = Depends(get_db)):
    return update_anime(anime_id, anime, db)

@router.delete("/{anime_id}")
def delete_anime(anime_id: int, db: Session = Depends(get_db)):
    db_anime = db.query(models.Anime).filter(models.Anime.id == anime_id).first()
    if not db_anime:
        raise HTTPException(status_code=404, detail="Anime not found")
    
    db.delete(db_anime)
    db.commit()
    return {"message": "Anime deleted successfully"}
