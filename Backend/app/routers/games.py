from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/games", tags=["games"])

@router.get("", response_model=List[schemas.GameResponse])
def get_games_list(
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    query = db.query(models.Game)
    
    if status:
        query = query.filter(models.Game.status == status)
    
    games = query.order_by(models.Game.updated_at.desc()).offset(skip).limit(limit).all()
    return games

@router.get("/{game_id}", response_model=schemas.GameResponse)
def get_game(game_id: int, db: Session = Depends(get_db)):
    game = db.query(models.Game).filter(models.Game.id == game_id).first()
    if not game:
        raise HTTPException(status_code=404, detail="Game not found")
    return game

@router.post("", response_model=schemas.GameResponse)
def create_game(game: schemas.GameCreate, db: Session = Depends(get_db)):
    db_game = models.Game(**game.dict())
    db.add(db_game)
    db.commit()
    db.refresh(db_game)
    return db_game

@router.put("/{game_id}", response_model=schemas.GameResponse)
def update_game(game_id: int, game: schemas.GameUpdate, db: Session = Depends(get_db)):
    db_game = db.query(models.Game).filter(models.Game.id == game_id).first()
    if not db_game:
        raise HTTPException(status_code=404, detail="Game not found")
    
    for key, value in game.dict(exclude_unset=True).items():
        setattr(db_game, key, value)
    
    db.commit()
    db.refresh(db_game)
    return db_game

@router.patch("/{game_id}", response_model=schemas.GameResponse)
def partial_update_game(game_id: int, game: schemas.GameUpdate, db: Session = Depends(get_db)):
    return update_game(game_id, game, db)

@router.delete("/{game_id}")
def delete_game(game_id: int, db: Session = Depends(get_db)):
    db_game = db.query(models.Game).filter(models.Game.id == game_id).first()
    if not db_game:
        raise HTTPException(status_code=404, detail="Game not found")
    
    db.delete(db_game)
    db.commit()
    return {"message": "Game deleted successfully"}
