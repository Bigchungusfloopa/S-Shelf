import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class SpotifyAuthService {
  static const String clientId = 'YOUR_SPOTIFY_CLIENT_ID';
  static const String clientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET';
  static const String redirectUri = 'http://localhost:8080/callback';
  static const List<String> scopes = [
    'user-library-read',
    'user-follow-read',
    'playlist-read-private',
    'user-top-read',
    'user-read-recently-played'
  ];

  final _storage = FlutterSecureStorage();
  HttpServer? _callbackServer;
  
  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: 'spotify_access_token');
    if (token == null) return false;
    
    // Check if token is expired
    final expiryStr = await _storage.read(key: 'spotify_token_expiry');
    if (expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry)) {
        // Token expired, try to refresh
        return await _refreshToken();
      }
    }
    return true;
  }

  // Start OAuth flow
  Future<bool> authenticate() async {
    try {
      // Start local server to receive callback
      _callbackServer = await HttpServer.bind('localhost', 8080);
      
      // Generate auth URL
      final authUrl = Uri.https('accounts.spotify.com', '/authorize', {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'scope': scopes.join(' '),
        'show_dialog': 'true',
      });

      // Open Spotify login in browser
      if (await canLaunchUrl(authUrl)) {
        await launchUrl(authUrl, mode: LaunchMode.externalApplication);
      }

      // Wait for callback
      final completer = Completer<bool>();
      
      _callbackServer!.listen((HttpRequest request) async {
        if (request.uri.path == '/callback') {
          final code = request.uri.queryParameters['code'];
          
          if (code != null) {
            // Exchange code for token
            final success = await _exchangeCodeForToken(code);
            
            // Send response to browser
            request.response
              ..statusCode = 200
              ..headers.contentType = ContentType.html
              ..write('''
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
                        color: white;
                      }
                      .container {
                        background: rgba(0, 0, 0, 0.8);
                        padding: 40px;
                        border-radius: 20px;
                        text-align: center;
                      }
                      h1 { color: #1DB954; }
                    </style>
                  </head>
                  <body>
                    <div class="container">
                      <h1>✅ Connected!</h1>
                      <p>Your Spotify account is now linked to S-Shelf.</p>
                      <p>You can close this window and return to the app.</p>
                    </div>
                    <script>
                      setTimeout(() => window.close(), 3000);
                    </script>
                  </body>
                </html>
              ''');
            await request.response.close();
            
            completer.complete(success);
            await _callbackServer?.close();
            _callbackServer = null;
          }
        }
      });

      return await completer.future.timeout(
        Duration(minutes: 5),
        onTimeout: () {
          _callbackServer?.close();
          _callbackServer = null;
          return false;
        },
      );
    } catch (e) {
      print('Spotify auth error: $e');
      _callbackServer?.close();
      _callbackServer = null;
      return false;
    }
  }

  // Exchange authorization code for access token
  Future<bool> _exchangeCodeForToken(String code) async {
    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Store tokens securely
        await _storage.write(key: 'spotify_access_token', value: data['access_token']);
        await _storage.write(key: 'spotify_refresh_token', value: data['refresh_token']);
        
        // Calculate and store expiry time
        final expiresIn = data['expires_in'] as int;
        final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
        await _storage.write(key: 'spotify_token_expiry', value: expiryTime.toIso8601String());
        
        return true;
      }
      return false;
    } catch (e) {
      print('Token exchange error: $e');
      return false;
    }
  }

  // Refresh expired token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'spotify_refresh_token');
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        await _storage.write(key: 'spotify_access_token', value: data['access_token']);
        
        final expiresIn = data['expires_in'] as int;
        final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
        await _storage.write(key: 'spotify_token_expiry', value: expiryTime.toIso8601String());
        
        return true;
      }
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  // Get current access token
  Future<String?> getAccessToken() async {
    if (await isAuthenticated()) {
      return await _storage.read(key: 'spotify_access_token');
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _storage.delete(key: 'spotify_access_token');
    await _storage.delete(key: 'spotify_refresh_token');
    await _storage.delete(key: 'spotify_token_expiry');
  }
}