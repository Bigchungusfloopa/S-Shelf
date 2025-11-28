import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class SpotifyAuthService {
  static const String clientId = '56b89f0771d6414db86f6d42395411ce';
  static const String clientSecret = '10be6435ff1d4405b9436bf3f39e5057';
  static const String redirectUri = 'http://127.0.0.1:8888/callback';
  static const List<String> scopes = [
    'user-library-read',
    'user-follow-read',
    'playlist-read-private',
    'user-top-read',
    'user-read-recently-played'
  ];

  HttpServer? _callbackServer;
  
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('spotify_access_token');
    if (token == null) return false;
    
    final expiryStr = prefs.getString('spotify_token_expiry');
    if (expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry)) {
        return await _refreshToken();
      }
    }
    return true;
  }

  Future<bool> authenticate() async {
    try {
      _callbackServer = await HttpServer.bind('127.0.0.1', 8888);
      print('✅ Started local server on http://127.0.0.1:8888');
      
      final completer = Completer<bool>();
      bool completed = false;
      
      _callbackServer!.listen((HttpRequest request) async {
        if (completed) return;
        
        print('📨 Received request: ${request.uri.path}');
        
        if (request.uri.path == '/callback') {
          final code = request.uri.queryParameters['code'];
          final error = request.uri.queryParameters['error'];
          
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.html
            ..write('''
              <!DOCTYPE html>
              <html>
              <head>
                <meta charset="UTF-8">
                <title>S-Shelf - Connected!</title>
                <style>
                  * { margin: 0; padding: 0; box-sizing: border-box; }
                  body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    background: linear-gradient(135deg, #1DB954 0%, #191414 100%);
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    min-height: 100vh;
                    color: white;
                  }
                  .container {
                    text-align: center;
                    background: rgba(0, 0, 0, 0.8);
                    padding: 60px 40px;
                    border-radius: 20px;
                    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
                    max-width: 500px;
                  }
                  h1 { font-size: 36px; margin-bottom: 16px; color: #1DB954; }
                  p { font-size: 18px; line-height: 1.6; color: #b3b3b3; }
                  .success { margin-top: 20px; color: #1DB954; font-weight: 600; }
                </style>
              </head>
              <body>
                <div class="container">
                  <h1>✅ Connected!</h1>
                  <p>Your Spotify account is now linked to S-Shelf.</p>
                  <p class="success">You can close this window and return to the app.</p>
                </div>
                <script>setTimeout(() => window.close(), 3000);</script>
              </body>
              </html>
            ''');
          await request.response.close();
          
          if (error != null) {
            print('❌ OAuth error: $error');
            completed = true;
            completer.complete(false);
            await _callbackServer?.close();
            _callbackServer = null;
          } else if (code != null) {
            print('✅ Got authorization code: ${code.substring(0, 10)}...');
            completed = true;
            final success = await _exchangeCodeForToken(code);
            completer.complete(success);
            await _callbackServer?.close();
            _callbackServer = null;
          }
        }
      }, onError: (err) {
        print('❌ Server error: $err');
        if (!completed) {
          completed = true;
          completer.complete(false);
          _callbackServer?.close();
          _callbackServer = null;
        }
      });
      
      final authUrl = Uri.https('accounts.spotify.com', '/authorize', {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'scope': scopes.join(' '),
        'show_dialog': 'true',
      });

      print('🌐 Opening Spotify auth URL...');
      
      if (await canLaunchUrl(authUrl)) {
        final launched = await launchUrl(authUrl, mode: LaunchMode.externalApplication);
        
        if (!launched) {
          print('❌ Failed to launch browser');
          completer.complete(false);
          _callbackServer?.close();
          _callbackServer = null;
          return false;
        }
      } else {
        print('❌ Cannot launch URL');
        completer.complete(false);
        _callbackServer?.close();
        _callbackServer = null;
        return false;
      }

      final result = await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          print('⏱️ Authentication timeout');
          _callbackServer?.close();
          _callbackServer = null;
          return false;
        },
      );
      
      return result;
    } catch (e) {
      print('❌ Spotify auth error: $e');
      _callbackServer?.close();
      _callbackServer = null;
      return false;
    }
  }

  Future<bool> _exchangeCodeForToken(String code) async {
    try {
      print('🔄 Exchanging code for token...');
      
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

      print('📡 Token response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Store tokens using SharedPreferences instead of SecureStorage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('spotify_access_token', data['access_token']);
        await prefs.setString('spotify_refresh_token', data['refresh_token']);
        
        final expiresIn = data['expires_in'] as int;
        final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
        await prefs.setString('spotify_token_expiry', expiryTime.toIso8601String());
        
        print('✅ Token stored successfully!');
        return true;
      }
      
      print('❌ Token exchange failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('❌ Token exchange error: $e');
      return false;
    }
  }

  Future<bool> _refreshToken() async {
    try {
      print('🔄 Refreshing token...');
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('spotify_refresh_token');
      if (refreshToken == null) {
        print('❌ No refresh token found');
        return false;
      }

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
        
        await prefs.setString('spotify_access_token', data['access_token']);
        
        final expiresIn = data['expires_in'] as int;
        final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
        await prefs.setString('spotify_token_expiry', expiryTime.toIso8601String());
        
        print('✅ Token refreshed successfully!');
        return true;
      }
      
      print('❌ Token refresh failed: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Token refresh error: $e');
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    if (await isAuthenticated()) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('spotify_access_token');
    }
    return null;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('spotify_access_token');
    await prefs.remove('spotify_refresh_token');
    await prefs.remove('spotify_token_expiry');
    _callbackServer?.close();
    _callbackServer = null;
  }

  void dispose() {
    _callbackServer?.close();
    _callbackServer = null;
  }
}