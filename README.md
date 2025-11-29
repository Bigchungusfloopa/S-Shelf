# S-Shelf

![License MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B.svg)
![Python](https://img.shields.io/badge/Python-3.8+-3776AB.svg)

A personal media tracking application for anime, manga, games, and music with integrated Spotify features.

## Overview

S-Shelf is a comprehensive media tracker that helps you organize and monitor your entertainment consumption. The application combines a Flutter frontend with a FastAPI backend to provide a seamless experience for tracking your favorite media across multiple categories.

## 🔑 Key Features

### Core Features

- **Multi-category tracking** - Anime, Manga, Games, and Music in one unified interface
- **MyAnimeList integration** - Search and import anime/manga directly from MAL
- **Spotify integration** - Connect your Spotify account to view playlists, albums, artists, and wrapped stats
- **Status management** - Track watching/reading/playing status with custom progress tracking
- **Statistics dashboard** - Visual overview of your media consumption habits
- **Dark theme interface** - Modern, sleek design optimized for extended use

### Spotify Features

- View your playlists and saved albums
- Browse followed artists with follower counts and rankings
- Access Spotify Wrapped-style stats (top tracks, top artists, genres)
- Filter by time range (last month, 6 months, all time)
- Detailed playlist and album track listings

### Anime & Manga

- Search MyAnimeList database with 20 results per query
- Track episodes watched and chapters read
- Add custom ratings and notes
- Filter by status (Watching, Completed, Plan to Watch, Dropped)
- Trending anime and manga recommendations

### Games & Music

- Track gaming progress with playtime hours
- Manage music library with play counts
- Custom ratings and personal notes
- Status filtering and organization

## 🛠️ Tech Stack

**Frontend:**
- Flutter for cross-platform UI
- Provider for state management
- HTTP client for API communication
- Shared Preferences for local data storage

**Backend:**
- FastAPI (Python) for REST API
- SQLite database for data persistence
- Jikan API integration for MyAnimeList data
- Spotify Web API integration
- OAuth 2.0 authentication flow

## 📦 Installation

### Prerequisites

- Flutter SDK 3.0+
- Python 3.8+
- macOS 10.15+ (current build)

### Setup

1. Clone the repository
```bash
git clone https://github.com/Bigchungusfloopa/s-shelf.git
cd s-shelf
```

2. Backend setup
```bash
cd Backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

3. Configure Spotify credentials
```bash
# Create .env file in Backend directory
echo "SPOTIFY_CLIENT_ID=your_client_id" > .env
echo "SPOTIFY_CLIENT_SECRET=your_client_secret" >> .env
echo "SPOTIFY_REDIRECT_URI=http://127.0.0.1:8888/callback" >> .env
```

4. Frontend setup
```bash
cd Frontend
flutter pub get
flutter build macos --release
```

5. Launch the application
```bash
# The app automatically starts the backend when launched
open build/macos/Build/Products/Release/S-Shelf.app
```

## 🎮 Usage

### First Launch

1. Launch S-Shelf from Applications
2. The backend starts automatically in the background
3. Navigate to Music tab to connect Spotify (optional)
4. Start adding your anime, manga, games, or music!

### Adding Media

- **Anime/Manga**: Use the search feature to find titles from MyAnimeList
- **Games**: Manually add games with title, platform, and playtime
- **Music**: Track manually or sync with Spotify
- **All categories**: Set status, rating, progress, and personal notes

### Spotify Integration

1. Go to Music tab
2. Click "Connect Spotify"
3. Authorize in browser
4. View your complete music library and stats

## 🗺️ Roadmap

- [ ] iOS and Android builds
- [ ] AniList integration as alternative to MAL
- [ ] Steam library import for games
- [ ] Export data to CSV/JSON
- [ ] Cloud sync across devices
- [ ] Custom themes and color schemes

## 🐛 Known Issues

- Backend requires manual stop if app crashes (process cleanup coming soon)
- Spotify token refresh requires re-authentication after 60 minutes 

## 💡 Acknowledgments

- MyAnimeList for anime/manga data
- Spotify Web API for music integration
- Flutter team for the amazing framework

---

**Built with ❤️ using Flutter and FastAPI**
