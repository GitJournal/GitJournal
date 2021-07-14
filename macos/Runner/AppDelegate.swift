import Cocoa
import FlutterMacOS
import Foundation

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    private var methodChannel: FlutterMethodChannel?
    private var channelName = "gitjournal.io/git"
//
//    override func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//
//        GeneratedPluginRegistrant.register(with: self)
//        guard let controller = window?.rootViewController as? FlutterViewController else {
//            fatalError("rootViewController is not type FlutterViewController")
//        }
//
//        methodChannel = FlutterMethodChannel(name: channelName,
//                                             binaryMessenger: controller.binaryMessenger)
//        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//    }
//
//    func application(_ application: NSApplicationDelegate,
//                     open url: URL,
//                     options: [UIApplicationOpenURLOptionsKey : Any] = [:] ) -> Bool {
//
//
//        // Determine who sent the URL.
//        let sendingAppID = options[.sourceApplication]
//        print("source application = \(sendingAppID ?? "Unknown")")
//
//
//        // Process the URL.
//        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
//            let albumPath = components.path,
//            let params = components.queryItems else {
//                print("Invalid URL or album path missing")
//                return false
//        }
//
//
//        if let photoIndex = params.first(where: { $0.name == "index" })?.value {
//            print("albumPath = \(albumPath)")
//            print("photoIndex = \(photoIndex)")
//            return true
//        } else {
//            print("Photo index missing")
//            return false
//        }
//    }
//
    /*
     func application(_ application: UIApplication,
     open url: URL,
     options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {

     print("url: \(url)")
     return true
     }
     */

}

/*


 - (BOOL)application:(UIApplication *)app
 openURL:(NSURL *)url
 options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
 NSLog(@"openUrl called with url %@", url);
 for (NSString *key in [options allKeys]) {
 NSLog(@".  %@: %@", key, [options objectForKey:key]);
 }

 NSDictionary *args = @{@"URL": [url absoluteString]};
 [gitChannel invokeMethod:@"onURL" arguments:args];

 return true;
 }

 */
