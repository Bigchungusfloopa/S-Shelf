from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from ..database import get_db
from .. import models, schemas

router = APIRouter(prefix="/manga", tags=["manga"])

@router.get("", response_model=List[schemas.MangaResponse])
def get_manga_list(
    skip: int = 0,
    limit: int = 100,
    status: Optional[str] = None,
    genre: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(models.Manga)
    
    if status and status != "all":
        query = query.filter(models.Manga.status == status)
    
    # Note: Genre filtering would require a many-to-many relationship
    # For now, we'll skip genre filtering or implement it differently
    
    manga = query.order_by(models.Manga.updated_at.desc()).offset(skip).limit(limit).all()
    return manga

@router.post("", response_model=schemas.MangaResponse)
def create_manga(manga: schemas.MangaCreate, db: Session = Depends(get_db)):
    db_manga = models.Manga(**manga.dict())
    db.add(db_manga)
    db.commit()
    db.refresh(db_manga)
    return db_manga

@router.get("/{manga_id}", response_model=schemas.MangaResponse)
def get_manga(manga_id: int, db: Session = Depends(get_db)):
    manga = db.query(models.Manga).filter(models.Manga.id == manga_id).first()
    if not manga:
        raise HTTPException(status_code=404, detail="Manga not found")
    return manga

@router.put("/{manga_id}", response_model=schemas.MangaResponse)
def update_manga(manga_id: int, manga: schemas.MangaUpdate, db: Session = Depends(get_db)):
    db_manga = db.query(models.Manga).filter(models.Manga.id == manga_id).first()
    if not db_manga:
        raise HTTPException(status_code=404, detail="Manga not found")
    
    for key, value in manga.dict().items():
        setattr(db_manga, key, value)
    
    db.commit()
    db.refresh(db_manga)
    return db_manga

@router.delete("/{manga_id}")
def delete_manga(manga_id: int, db: Session = Depends(get_db)):
    manga = db.query(models.Manga).filter(models.Manga.id == manga_id).first()
    if not manga:
        raise HTTPException(status_code=404, detail="Manga not found")
    
    db.delete(manga)
    db.commit()
    return {"message": "Manga deleted successfully"}