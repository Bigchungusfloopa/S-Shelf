from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .database import engine, Base
from . import models

# Import routers individually
from .routers import anime
from .routers import manga
from .routers import music
from .routers import mal
from .routers import trending
from .routers import stats
from .routers import spotify

# Create tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Media Tracker API")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(anime.router)
app.include_router(manga.router)
app.include_router(music.router)
app.include_router(spotify.router)
app.include_router(mal.router)
app.include_router(trending.router)
app.include_router(stats.router)

@app.get("/")
def read_root():
    return {"message": "Media Tracker API"}
