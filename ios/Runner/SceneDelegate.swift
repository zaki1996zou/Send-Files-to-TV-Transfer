import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard let appDelegate = UIApplication.shared.delegate as? FlutterAppDelegate,
          let windowScene = scene as? UIWindowScene else {
      return
    }

    let activeWindow = window ?? windowScene.windows.first { $0.isKeyWindow } ?? windowScene.windows.first
    if let activeWindow {
      self.window = activeWindow
      appDelegate.window = activeWindow
      activeWindow.makeKeyAndVisible()
    }
  }
}
