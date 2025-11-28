from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/music", tags=["music"])

@router.get("", response_model=List[schemas.MusicResponse])
def get_music_list(
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    query = db.query(models.Music)
    
    if status:
        query = query.filter(models.Music.status == status)
    
    music = query.order_by(models.Music.updated_at.desc()).offset(skip).limit(limit).all()
    return music

@router.get("/{music_id}", response_model=schemas.MusicResponse)
def get_music(music_id: int, db: Session = Depends(get_db)):
    music = db.query(models.Music).filter(models.Music.id == music_id).first()
    if not music:
        raise HTTPException(status_code=404, detail="Music not found")
    return music

@router.post("", response_model=schemas.MusicResponse)
def create_music(music: schemas.MusicCreate, db: Session = Depends(get_db)):
    db_music = models.Music(**music.dict())
    db.add(db_music)
    db.commit()
    db.refresh(db_music)
    return db_music

@router.put("/{music_id}", response_model=schemas.MusicResponse)
def update_music(music_id: int, music: schemas.MusicUpdate, db: Session = Depends(get_db)):
    db_music = db.query(models.Music).filter(models.Music.id == music_id).first()
    if not db_music:
        raise HTTPException(status_code=404, detail="Music not found")
    
    for key, value in music.dict(exclude_unset=True).items():
        setattr(db_music, key, value)
    
    db.commit()
    db.refresh(db_music)
    return db_music

@router.delete("/{music_id}")
def delete_music(music_id: int, db: Session = Depends(get_db)):
    db_music = db.query(models.Music).filter(models.Music.id == music_id).first()
    if not db_music:
        raise HTTPException(status_code=404, detail="Music not found")
    
    db.delete(db_music)
    db.commit()
    return {"message": "Music deleted successfully"}
