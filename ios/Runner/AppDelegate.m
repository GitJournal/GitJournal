#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

NSString* GetDirectoryOfType(NSSearchPathDirectory dir) {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(dir, NSUserDomainMask, YES);
    return paths.firstObject;
}

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;

    FlutterMethodChannel* gitChannel = [FlutterMethodChannel
        methodChannelWithName:@"gitjournal.io/git" binaryMessenger:controller];

    [gitChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        NSString* filesDir = [self getApplicationDocumentsDirectory];
        if ([@"getBaseDirectory" isEqualToString:call.method]) {
            /*
             int batteryLevel = [weakSelf getBatteryLevel];

             if (batteryLevel == -1) {
             result([FlutterError errorWithCode:@"UNAVAILABLE"
             message:@"Battery info unavailable"
             details:nil]);
             } else {
             result(@(batteryLevel));
             }
             */
            result(filesDir);
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];

    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSString*)getApplicationDocumentsDirectory {
    return GetDirectoryOfType(NSDocumentDirectory);
}

@end
