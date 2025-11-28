from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import webbrowser
import os
from dotenv import load_dotenv
import spotipy
from spotipy.oauth2 import SpotifyOAuth

load_dotenv()

SPOTIPY_CLIENT_ID = os.getenv("SPOTIPY_CLIENT_ID")
SPOTIPY_CLIENT_SECRET = os.getenv("SPOTIPY_CLIENT_SECRET")
SPOTIPY_REDIRECT_URI = "http://127.0.0.1:8080/callback"
SCOPE = "user-library-read user-follow-read playlist-read-private user-top-read user-read-recently-played"

class OAuthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith('/callback'):
            parsed = urlparse(self.path)
            params = parse_qs(parsed.query)
            
            if 'code' in params:
                code = params['code'][0]
                
                sp_oauth = SpotifyOAuth(
                    client_id=SPOTIPY_CLIENT_ID,
                    client_secret=SPOTIPY_CLIENT_SECRET,
                    redirect_uri=SPOTIPY_REDIRECT_URI,
                    scope=SCOPE,
                    cache_path=".spotify_cache"
                )
                
                try:
                    token_info = sp_oauth.get_access_token(code)
                    
                    self.send_response(200)
                    self.send_header('Content-type', 'text/html')
                    self.end_headers()
                    html = """
                    <html>
                        <head>
                            <style>
                                body {
                                    background: linear-gradient(135deg, #1DB954, #191414);
                                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                                    display: flex;
                                    justify-content: center;
                                    align-items: center;
                                    height: 100vh;
                                    margin: 0;
                                }
                                .container {
                                    background: rgba(0, 0, 0, 0.8);
                                    padding: 40px;
                                    border-radius: 20px;
                                    text-align: center;
                                    box-shadow: 0 10px 50px rgba(0,0,0,0.5);
                                }
                                h1 { 
                                    color: #1DB954; 
                                    margin: 20px 0 10px 0; 
                                    font-size: 36px; 
                                }
                                p { 
                                    color: #fff; 
                                    margin: 10px 0; 
                                    font-size: 18px; 
                                }
                                .checkmark {
                                    width: 80px;
                                    height: 80px;
                                    border-radius: 50%;
                                    display: block;
                                    stroke-width: 3;
                                    stroke: #1DB954;
                                    stroke-miterlimit: 10;
                                    margin: 0 auto 20px auto;
                                    box-shadow: inset 0px 0px 0px #1DB954;
                                    animation: fill .4s ease-in-out .4s forwards, scale .3s ease-in-out .9s both;
                                }
                                .checkmark__circle {
                                    stroke-dasharray: 166;
                                    stroke-dashoffset: 166;
                                    stroke-width: 3;
                                    stroke-miterlimit: 10;
                                    stroke: #1DB954;
                                    fill: none;
                                    animation: stroke 0.6s cubic-bezier(0.65, 0, 0.45, 1) forwards;
                                }
                                .checkmark__check {
                                    transform-origin: 50% 50%;
                                    stroke-dasharray: 48;
                                    stroke-dashoffset: 48;
                                    animation: stroke 0.3s cubic-bezier(0.65, 0, 0.45, 1) 0.8s forwards;
                                }
                                @keyframes stroke {
                                    100% { stroke-dashoffset: 0; }
                                }
                            </style>
                        </head>
                        <body>
                            <div class="container">
                                <svg class="checkmark" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
                                    <circle class="checkmark__circle" cx="26" cy="26" r="25" fill="none"/>
                                    <path class="checkmark__check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
                                </svg>
                                <h1>✅ Connected!</h1>
                                <p>Your Spotify account is now linked to Omnishelf.</p>
                                <p style="color: #888; font-size: 14px; margin-top: 20px;">
                                    Close this window and restart your app to see your music!
                                </p>
                            </div>
                            <script>
                                setTimeout(() => window.close(), 5000);
                            </script>
                        </body>
                    </html>
                    """
                    self.wfile.write(html.encode())
                    print("✅ Authorization successful! Token cached.")
                    print("You can now close the OAuth server and restart your main app.")
                    
                except Exception as e:
                    print(f"❌ Error: {e}")
                    self.send_response(400)
                    self.send_header('Content-type', 'text/html')
                    self.end_headers()
                    html = f"""
                    <html>
                        <body style="background: #000; color: #fff; text-align: center; padding: 50px; font-family: Arial;">
                            <h1>❌ Error</h1>
                            <p>{str(e)}</p>
                            <button onclick="window.close()" style="padding: 10px 20px; background: #1DB954; color: white; border: none; border-radius: 5px; cursor: pointer;">Close</button>
                        </body>
                    </html>
                    """
                    self.wfile.write(html.encode())
            else:
                self.send_response(400)
                self.send_header('Content-type', 'text/html')
                self.end_headers()
                html = """
                <html>
                    <body style="background: #000; color: #fff; text-align: center; padding: 50px;">
                        <h1>❌ Authorization Failed</h1>
                        <p>No authorization code received.</p>
                        <button onclick="window.close()" style="padding: 10px 20px; background: #1DB954; color: white; border: none; border-radius: 5px; cursor: pointer;">Close</button>
                    </body>
                </html>
                """
                self.wfile.write(html.encode())
        
        elif self.path == '/login':
            sp_oauth = SpotifyOAuth(
                client_id=SPOTIPY_CLIENT_ID,
                client_secret=SPOTIPY_CLIENT_SECRET,
                redirect_uri=SPOTIPY_REDIRECT_URI,
                scope=SCOPE
            )
            auth_url = sp_oauth.get_authorize_url()
            
            # Redirect to Spotify
            self.send_response(302)
            self.send_header('Location', auth_url)
            self.end_headers()
    
    def log_message(self, format, *args):
        pass

def main():
    print("🎵 Spotify OAuth Server")
    print("=" * 50)
    print(f"Redirect URI: {SPOTIPY_REDIRECT_URI}")
    print("=" * 50)
    
    # Start server
    server = HTTPServer(('127.0.0.1', 8080), OAuthHandler)
    
    # Open browser to start auth
    sp_oauth = SpotifyOAuth(
        client_id=SPOTIPY_CLIENT_ID,
        client_secret=SPOTIPY_CLIENT_SECRET,
        redirect_uri=SPOTIPY_REDIRECT_URI,
        scope=SCOPE
    )
    auth_url = sp_oauth.get_authorize_url()
    
    print("\n🌐 Opening browser for Spotify authorization...")
    print("If browser doesn't open, visit this URL:")
    print(f"\n{auth_url}\n")
    
    webbrowser.open(auth_url)
    
    print("⏳ Waiting for authorization callback...")
    print("(Server will automatically stop after receiving callback)\n")
    
    # Handle one request then stop
    server.handle_request()
    
    print("\n✅ Done! You can now start your main backend and app.")
    server.server_close()

if __name__ == "__main__":
    main()
