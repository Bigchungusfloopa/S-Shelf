from fastapi import APIRouter, HTTPException
import httpx
from typing import List, Optional

router = APIRouter(prefix="/mal", tags=["myanimelist"])

MAL_API_BASE = "https://api.myanimelist.net/v2"
# Note: For production, you should use environment variables for the client ID
MAL_CLIENT_ID = "your_mal_client_id_here"  # You'll need to get this from MAL

# For now, we'll use Jikan API which doesn't require authentication
JIKAN_API_BASE = "https://api.jikan.moe/v4"

@router.get("/anime/search")
async def search_anime(q: str, limit: int = 10):
    """Search for anime on MyAnimeList"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{JIKAN_API_BASE}/anime",
                params={"q": q, "limit": limit}
            )
            if response.status_code == 200:
                data = response.json()
                return {
                    "results": [
                        {
                            "mal_id": anime["mal_id"],
                            "title": anime["title"],
                            "title_english": anime.get("title_english"),
                            "title_japanese": anime.get("title_japanese"),
                            "synopsis": anime.get("synopsis"),
                            "image_url": anime["images"]["jpg"]["large_image_url"],
                            "episodes": anime.get("episodes"),
                            "score": anime.get("score"),
                            "genres": [g["name"] for g in anime.get("genres", [])],
                        }
                        for anime in data.get("data", [])
                    ]
                }
            return {"results": []}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error searching anime: {str(e)}")

@router.get("/anime/{mal_id}")
async def get_anime_details(mal_id: int):
    """Get detailed anime information from MyAnimeList"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{JIKAN_API_BASE}/anime/{mal_id}")
            if response.status_code == 200:
                data = response.json()
                anime = data["data"]
                return {
                    "mal_id": anime["mal_id"],
                    "title": anime["title"],
                    "title_english": anime.get("title_english"),
                    "title_japanese": anime.get("title_japanese"),
                    "synopsis": anime.get("synopsis"),
                    "image_url": anime["images"]["jpg"]["large_image_url"],
                    "episodes": anime.get("episodes"),
                    "score": anime.get("score"),
                    "genres": [g["name"] for g in anime.get("genres", [])],
                    "status": anime.get("status"),
                    "aired": anime.get("aired", {}).get("string"),
                }
            raise HTTPException(status_code=404, detail="Anime not found")
    except httpx.HTTPStatusError:
        raise HTTPException(status_code=404, detail="Anime not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching anime: {str(e)}")

@router.get("/manga/search")
async def search_manga(q: str, limit: int = 10):
    """Search for manga on MyAnimeList"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{JIKAN_API_BASE}/manga",
                params={"q": q, "limit": limit}
            )
            if response.status_code == 200:
                data = response.json()
                return {
                    "results": [
                        {
                            "mal_id": manga["mal_id"],
                            "title": manga["title"],
                            "title_english": manga.get("title_english"),
                            "title_japanese": manga.get("title_japanese"),
                            "synopsis": manga.get("synopsis"),
                            "image_url": manga["images"]["jpg"]["large_image_url"],
                            "chapters": manga.get("chapters"),
                            "volumes": manga.get("volumes"),
                            "score": manga.get("score"),
                            "genres": [g["name"] for g in manga.get("genres", [])],
                        }
                        for manga in data.get("data", [])
                    ]
                }
            return {"results": []}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error searching manga: {str(e)}")

@router.get("/manga/{mal_id}")
async def get_manga_details(mal_id: int):
    """Get detailed manga information from MyAnimeList"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{JIKAN_API_BASE}/manga/{mal_id}")
            if response.status_code == 200:
                data = response.json()
                manga = data["data"]
                return {
                    "mal_id": manga["mal_id"],
                    "title": manga["title"],
                    "title_english": manga.get("title_english"),
                    "title_japanese": manga.get("title_japanese"),
                    "synopsis": manga.get("synopsis"),
                    "image_url": manga["images"]["jpg"]["large_image_url"],
                    "chapters": manga.get("chapters"),
                    "volumes": manga.get("volumes"),
                    "score": manga.get("score"),
                    "genres": [g["name"] for g in manga.get("genres", [])],
                    "status": manga.get("status"),
                    "published": manga.get("published", {}).get("string"),
                }
            raise HTTPException(status_code=404, detail="Manga not found")
    except httpx.HTTPStatusError:
        raise HTTPException(status_code=404, detail="Manga not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching manga: {str(e)}")
