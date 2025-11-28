import spotipy
from spotipy.oauth2 import SpotifyOAuth
import os
from dotenv import load_dotenv

load_dotenv()

SPOTIPY_CLIENT_ID = os.getenv("SPOTIPY_CLIENT_ID")
SPOTIPY_CLIENT_SECRET = os.getenv("SPOTIPY_CLIENT_SECRET")
SPOTIPY_REDIRECT_URI = "http://127.0.0.1:8080/callback"
SCOPE = "user-library-read user-follow-read playlist-read-private user-top-read user-read-recently-played"

print("Testing Spotify authentication...")
print(f"Client ID: {SPOTIPY_CLIENT_ID[:10]}...")
print(f"Redirect URI: {SPOTIPY_REDIRECT_URI}")

sp_oauth = SpotifyOAuth(
    client_id=SPOTIPY_CLIENT_ID,
    client_secret=SPOTIPY_CLIENT_SECRET,
    redirect_uri=SPOTIPY_REDIRECT_URI,
    scope=SCOPE,
    cache_path=".spotify_cache"
)

token_info = sp_oauth.get_cached_token()

if token_info:
    print("✅ Token found in cache")
    print(f"Access token: {token_info['access_token'][:20]}...")
    print(f"Token expired: {sp_oauth.is_token_expired(token_info)}")
    
    # Try to use it
    sp = spotipy.Spotify(auth=token_info['access_token'])
    try:
        user = sp.current_user()
        print(f"✅ Successfully authenticated as: {user['display_name']}")
        print(f"User ID: {user['id']}")
        
        # Try to get playlists
        playlists = sp.current_user_playlists(limit=5)
        print(f"✅ Found {playlists['total']} playlists")
        for playlist in playlists['items'][:3]:
            print(f"  - {playlist['name']}")
            
    except Exception as e:
        print(f"❌ Error using token: {e}")
else:
    print("❌ No token found in cache")
