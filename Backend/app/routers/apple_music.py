from fastapi import APIRouter, HTTPException
import os

router = APIRouter(prefix="/apple-music", tags=["apple-music"])

# Apple Music uses client-side MusicKit JS authentication
# The backend will mainly proxy requests

@router.get("/check-auth")
def check_auth():
    """Check if Apple Music is available"""
    return {
        "authenticated": False,
        "needs_setup": True,
        "message": "Apple Music requires MusicKit JS setup in browser"
    }

@router.get("/library/songs")
def get_library_songs():
    """Get user's library songs"""
    raise HTTPException(
        status_code=501,
        detail="Apple Music integration requires MusicKit JS in browser"
    )

@router.get("/library/playlists")
def get_library_playlists():
    """Get user's playlists"""
    raise HTTPException(
        status_code=501,
        detail="Apple Music integration requires MusicKit JS in browser"
    )

@router.get("/library/albums")
def get_library_albums():
    """Get user's albums"""
    raise HTTPException(
        status_code=501,
        detail="Apple Music integration requires MusicKit JS in browser"
    )

@router.get("/library/artists")
def get_library_artists():
    """Get user's artists"""
    raise HTTPException(
        status_code=501,
        detail="Apple Music integration requires MusicKit JS in browser"
    )
