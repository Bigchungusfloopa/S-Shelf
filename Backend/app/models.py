from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, Text
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()

class Anime(Base):
    __tablename__ = "anime"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    title_english = Column(String, nullable=True)
    synopsis = Column(Text, nullable=True)
    image_url = Column(String, nullable=True)
    episodes = Column(Integer, nullable=True)
    current_episode = Column(Integer, default=0)
    status = Column(String, default="plan_to_watch")
    user_score = Column(Float, nullable=True)
    notes = Column(Text, nullable=True)
    mal_id = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Manga(Base):
    __tablename__ = "manga"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    current_chapter = Column(Integer, default=0)
    current_volume = Column(Integer, default=0)
    total_chapters = Column(Integer, nullable=True)
    total_volumes = Column(Integer, nullable=True)
    status = Column(String, default="plan_to_read")
    rating = Column(Float, default=0.0)
    notes = Column(Text, nullable=True)
    image_url = Column(String, nullable=True)
    mal_id = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Game(Base):
    __tablename__ = "games"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    cover_url = Column(String, nullable=True)
    status = Column(String, default="plan_to_play")
    user_score = Column(Float, nullable=True)
    playtime_hours = Column(Float, default=0.0)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Music(Base):
    __tablename__ = "music"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    artist = Column(String)
    album = Column(String)
    status = Column(String, default="listening")
    play_count = Column(Integer, default=0)
    favorite = Column(Boolean, default=False)
    notes = Column(Text)
    image_url = Column(String)
    spotify_id = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
