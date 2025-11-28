import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
  
  // Handle deep links for Spotify OAuth
  override func application(_ application: NSApplication, open urls: [URL]) {
    guard let url = urls.first else {
      return
    }
    
    print("Received deep link: \(url.absoluteString)")
    
    // Forward URL to Flutter via uni_links
    // The uni_links package will automatically handle this
  }
}