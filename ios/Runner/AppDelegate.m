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
        NSString *method = [call method];
        NSDictionary *arguments = [call arguments];

        NSString* filesDir = [self getApplicationDocumentsDirectory];
        if ([@"getBaseDirectory" isEqualToString:method]) {
            result(filesDir);
        }
        else if ([@"gitInit" isEqualToString:method]) {
            NSString *folderName = arguments[@"folderName"];
            NSArray *components = [NSArray arrayWithObjects:filesDir, folderName, nil];
            NSString* dirPath = [NSString pathWithComponents:components];

            NSError *error;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:dirPath
                                      withIntermediateDirectories:NO
                                      attributes:nil
                                      error:&error])
            {
                NSLog(@"Create directory error: %@", error);
                result([FlutterError errorWithCode:@"FAILED"
                        message:@"Failed to perform fake gitInit" details:nil]);
            }
            else {
                result(@YES);
            }
        }
        else {
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
