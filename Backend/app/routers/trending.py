from fastapi import APIRouter, HTTPException
import httpx
from typing import List

router = APIRouter(prefix="/trending", tags=["trending"])

JIKAN_API_BASE = "https://api.jikan.moe/v4"

@router.get("/anime")
async def get_trending_anime(limit: int = 10):
    """Get currently airing/popular anime"""
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            # Get current season anime
            response = await client.get(
                f"{JIKAN_API_BASE}/seasons/now",
                params={"limit": limit}
            )
            if response.status_code == 200:
                data = response.json()
                return {
                    "results": [
                        {
                            "mal_id": anime["mal_id"],
                            "title": anime["title"],
                            "image_url": anime["images"]["jpg"]["large_image_url"],
                            "score": anime.get("score"),
                            "episodes": anime.get("episodes"),
                            "status": anime.get("status"),
                        }
                        for anime in data.get("data", [])[:limit]
                    ]
                }
            return {"results": []}
    except Exception as e:
        print(f"Error fetching trending anime: {e}")
        return {"results": []}

@router.get("/manga")
async def get_trending_manga(limit: int = 10):
    """Get popular manga"""
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            # Get top manga
            response = await client.get(
                f"{JIKAN_API_BASE}/top/manga",
                params={"limit": limit}
            )
            if response.status_code == 200:
                data = response.json()
                return {
                    "results": [
                        {
                            "mal_id": manga["mal_id"],
                            "title": manga["title"],
                            "image_url": manga["images"]["jpg"]["large_image_url"],
                            "score": manga.get("score"),
                            "chapters": manga.get("chapters"),
                            "volumes": manga.get("volumes"),
                        }
                        for manga in data.get("data", [])[:limit]
                    ]
                }
            return {"results": []}
    except Exception as e:
        print(f"Error fetching trending manga: {e}")
        return {"results": []}
