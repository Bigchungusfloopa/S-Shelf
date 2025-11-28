from fastapi import APIRouter, HTTPException, Header
import spotipy
from typing import Optional

router = APIRouter(prefix="/spotify", tags=["spotify"])

def get_spotify_client(authorization: str = None):
    """Get Spotify client using provided Bearer token"""
    if not authorization or not authorization.startswith('Bearer '):
        raise HTTPException(
            status_code=401,
            detail="Missing or invalid Authorization header. Expected format: 'Bearer <token>'"
        )
    
    token = authorization.replace('Bearer ', '')
    return spotipy.Spotify(auth=token)

def calculate_artist_rank(followers):
    """Calculate approximate global rank based on followers"""
    if followers >= 80000000:
        return 1
    elif followers >= 50000000:
        return 5
    elif followers >= 30000000:
        return 10
    elif followers >= 20000000:
        return 20
    elif followers >= 10000000:
        return 50
    elif followers >= 5000000:
        return 100
    elif followers >= 2000000:
        return 500
    elif followers >= 1000000:
        return 1000
    elif followers >= 500000:
        return 5000
    elif followers >= 100000:
        return 10000
    else:
        return 50000

@router.get("/check-auth")
def check_auth(authorization: str = Header(None)):
    """Check if user has valid Spotify token"""
    try:
        if not authorization:
            return {
                "authenticated": False,
                "needs_reauth": True,
                "message": "No authorization header provided"
            }
        
        # Try to use the token
        sp = get_spotify_client(authorization)
        user = sp.current_user()
        
        return {
            "authenticated": True,
            "needs_reauth": False,
            "user": {
                "id": user.get("id"),
                "display_name": user.get("display_name"),
            }
        }
    except HTTPException:
        return {
            "authenticated": False,
            "needs_reauth": True,
            "message": "Invalid or expired token"
        }
    except Exception as e:
        return {
            "authenticated": False,
            "needs_reauth": True,
            "message": str(e)
        }

@router.get("/artist/{artist_id}")
def get_artist_details(artist_id: str, authorization: str = Header(None)):
    """Get detailed artist information"""
    try:
        sp = get_spotify_client(authorization)
        artist = sp.artist(artist_id)
        
        rank = calculate_artist_rank(artist["followers"]["total"])
        
        return {
            "id": artist["id"],
            "name": artist["name"],
            "image_url": artist["images"][0]["url"] if artist["images"] else None,
            "genres": artist["genres"],
            "followers": artist["followers"]["total"],
            "popularity": artist["popularity"],
            "rank": rank,
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/playlists")
def get_playlists(
    authorization: str = Header(None),
    limit: int = 50,
    offset: int = 0
):
    """Get user's Spotify playlists"""
    try:
        sp = get_spotify_client(authorization)
        playlists = sp.current_user_playlists(limit=limit, offset=offset)
        
        return {
            "playlists": [
                {
                    "id": playlist["id"],
                    "name": playlist["name"],
                    "tracks_count": playlist["tracks"]["total"],
                    "image_url": playlist["images"][0]["url"] if playlist["images"] else None,
                    "owner": playlist["owner"]["display_name"],
                    "public": playlist["public"],
                    "description": playlist.get("description", ""),
                    "collaborative": playlist.get("collaborative", False),
                }
                for playlist in playlists["items"]
            ],
            "total": playlists["total"]
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/playlists/{playlist_id}/tracks")
def get_playlist_tracks(
    playlist_id: str,
    authorization: str = Header(None),
    limit: int = 50,
    offset: int = 0
):
    """Get tracks from a specific playlist"""
    try:
        sp = get_spotify_client(authorization)
        results = sp.playlist_tracks(playlist_id, limit=limit, offset=offset)
        
        return {
            "tracks": [
                {
                    "id": item["track"]["id"] if item["track"] else None,
                    "name": item["track"]["name"] if item["track"] else "Unknown Track",
                    "artists": [artist["name"] for artist in item["track"]["artists"]] if item["track"] else ["Unknown Artist"],
                    "album": {
                        "name": item["track"]["album"]["name"] if item["track"] and item["track"]["album"] else "Unknown Album",
                        "id": item["track"]["album"]["id"] if item["track"] and item["track"]["album"] else None,
                    },
                    "duration_ms": item["track"]["duration_ms"] if item["track"] else 0,
                    "popularity": item["track"]["popularity"] if item["track"] else 0,
                    "track_number": item["track"]["track_number"] if item["track"] else 0,
                    "added_at": item["added_at"],
                }
                for item in results["items"]
                if item["track"] is not None
            ],
            "total": results["total"]
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/albums/{album_id}/tracks")
def get_album_tracks(
    album_id: str,
    authorization: str = Header(None),
    limit: int = 50,
    offset: int = 0
):
    """Get tracks from a specific album"""
    try:
        sp = get_spotify_client(authorization)
        results = sp.album_tracks(album_id, limit=limit, offset=offset)
        album_info = sp.album(album_id)
        
        return {
            "tracks": [
                {
                    "id": track["id"],
                    "name": track["name"],
                    "artists": [artist["name"] for artist in track["artists"]],
                    "duration_ms": track["duration_ms"],
                    "track_number": track["track_number"],
                    "disc_number": track["disc_number"],
                    "explicit": track["explicit"],
                    "popularity": album_info.get("popularity", 0),
                    "album": {
                        "name": album_info["name"],
                        "id": album_info["id"],
                        "release_date": album_info["release_date"],
                        "total_tracks": album_info["total_tracks"],
                    }
                }
                for track in results["items"]
            ],
            "total": results["total"],
            "album_info": {
                "name": album_info["name"],
                "artists": [artist["name"] for artist in album_info["artists"]],
                "release_date": album_info["release_date"],
                "total_tracks": album_info["total_tracks"],
                "image_url": album_info["images"][0]["url"] if album_info["images"] else None,
            }
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/liked-albums")
def get_liked_albums(
    authorization: str = Header(None),
    limit: int = 50
):
    """Get user's liked albums"""
    try:
        sp = get_spotify_client(authorization)
        results = sp.current_user_saved_albums(limit=limit)
        
        return {
            "albums": [
                {
                    "id": item["album"]["id"],
                    "name": item["album"]["name"],
                    "artist": ", ".join([artist["name"] for artist in item["album"]["artists"]]),
                    "image_url": item["album"]["images"][0]["url"] if item["album"]["images"] else None,
                    "total_tracks": item["album"]["total_tracks"],
                    "release_date": item["album"]["release_date"],
                }
                for item in results["items"]
            ],
            "total": results["total"]
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/followed-artists")
def get_followed_artists(authorization: str = Header(None)):
    """Get user's followed artists"""
    try:
        sp = get_spotify_client(authorization)
        results = sp.current_user_followed_artists(limit=50)
        
        return {
            "artists": [
                {
                    "id": artist["id"],
                    "name": artist["name"],
                    "image_url": artist["images"][0]["url"] if artist["images"] else None,
                    "genres": artist["genres"],
                    "followers": artist["followers"]["total"],
                    "popularity": artist["popularity"],
                    "rank": calculate_artist_rank(artist["followers"]["total"]),
                }
                for artist in results["artists"]["items"]
            ]
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/top-tracks")
def get_top_tracks(
    authorization: str = Header(None),
    time_range: str = "medium_term",
    limit: int = 20
):
    """
    Get user's top tracks for a specific time range
    time_range: short_term (4 weeks), medium_term (6 months), long_term (all time)
    """
    try:
        sp = get_spotify_client(authorization)
        results = sp.current_user_top_tracks(limit=limit, time_range=time_range)
        
        return {
            "tracks": [
                {
                    "id": track["id"],
                    "name": track["name"],
                    "artist": ", ".join([artist["name"] for artist in track["artists"]]),
                    "album": track["album"]["name"],
                    "image_url": track["album"]["images"][0]["url"] if track["album"]["images"] else None,
                    "popularity": track["popularity"],
                }
                for track in results["items"]
            ]
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/top-artists")
def get_top_artists(
    authorization: str = Header(None),
    time_range: str = "medium_term",
    limit: int = 20
):
    """
    Get user's top artists for a specific time range
    time_range: short_term (4 weeks), medium_term (6 months), long_term (all time)
    """
    try:
        sp = get_spotify_client(authorization)
        results = sp.current_user_top_artists(limit=limit, time_range=time_range)
        
        return {
            "artists": [
                {
                    "id": artist["id"],
                    "name": artist["name"],
                    "image_url": artist["images"][0]["url"] if artist["images"] else None,
                    "genres": artist["genres"],
                    "followers": artist["followers"]["total"],
                    "popularity": artist["popularity"],
                    "rank": calculate_artist_rank(artist["followers"]["total"]),
                }
                for artist in results["items"]
            ]
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/user-stats")
def get_user_stats(authorization: str = Header(None)):
    """Get Wrapped-like stats"""
    try:
        sp = get_spotify_client(authorization)
        
        top_tracks_short = sp.current_user_top_tracks(limit=10, time_range="short_term")
        top_tracks_long = sp.current_user_top_tracks(limit=10, time_range="long_term")
        top_artists_short = sp.current_user_top_artists(limit=10, time_range="short_term")
        top_artists_long = sp.current_user_top_artists(limit=10, time_range="long_term")
        saved_tracks = sp.current_user_saved_tracks(limit=1)
        playlists = sp.current_user_playlists(limit=1)
        followed = sp.current_user_followed_artists(limit=1)
        
        all_genres = []
        for artist in top_artists_long["items"]:
            all_genres.extend(artist["genres"])
        
        genre_counts = {}
        for genre in all_genres:
            genre_counts[genre] = genre_counts.get(genre, 0) + 1
        
        top_genres = sorted(genre_counts.items(), key=lambda x: x[1], reverse=True)[:5]
        
        return {
            "total_saved_tracks": saved_tracks["total"],
            "total_playlists": playlists["total"],
            "total_followed_artists": followed["artists"]["total"],
            "top_tracks_month": [
                {
                    "name": t["name"],
                    "artist": ", ".join([a["name"] for a in t["artists"]]),
                    "image_url": t["album"]["images"][0]["url"] if t["album"]["images"] else None,
                }
                for t in top_tracks_short["items"]
            ],
            "top_tracks_all_time": [
                {
                    "name": t["name"],
                    "artist": ", ".join([a["name"] for a in t["artists"]]),
                    "image_url": t["album"]["images"][0]["url"] if t["album"]["images"] else None,
                }
                for t in top_tracks_long["items"]
            ],
            "top_artists_month": [
                {
                    "name": a["name"],
                    "image_url": a["images"][0]["url"] if a["images"] else None,
                }
                for a in top_artists_short["items"]
            ],
            "top_artists_all_time": [
                {
                    "name": a["name"],
                    "image_url": a["images"][0]["url"] if a["images"] else None,
                }
                for a in top_artists_long["items"]
            ],
            "top_genres": [{"genre": g, "count": c} for g, c in top_genres],
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/new-releases")
def get_new_releases(authorization: str = Header(None)):
    """Get new releases from followed artists"""
    try:
        sp = get_spotify_client(authorization)
        
        followed = sp.current_user_followed_artists(limit=50)
        artist_ids = [artist["id"] for artist in followed["artists"]["items"]]
        
        if not artist_ids:
            return {"albums": []}
        
        all_albums = []
        
        for artist_id in artist_ids[:20]:
            try:
                albums = sp.artist_albums(
                    artist_id,
                    album_type='album,single',
                    limit=3
                )
                
                for album in albums["items"]:
                    all_albums.append({
                        "id": album["id"],
                        "name": album["name"],
                        "artist": ", ".join([a["name"] for a in album["artists"]]),
                        "artist_id": artist_id,
                        "image_url": album["images"][0]["url"] if album["images"] else None,
                        "release_date": album["release_date"],
                        "total_tracks": album["total_tracks"],
                        "album_type": album["album_type"],
                    })
            except:
                continue
        
        all_albums.sort(key=lambda x: x["release_date"], reverse=True)
        
        return {"albums": all_albums[:20]}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))