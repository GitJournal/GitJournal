#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

#include "gitjournal.h"

void gj_log(const char *message) {
    NSLog(@"GitJournalLib: %s", message);
}

NSString* GetDirectoryOfType(NSSearchPathDirectory dir) {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(dir, NSUserDomainMask, YES);
    return paths.firstObject;
}

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    gj_init();

    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;

    FlutterMethodChannel* gitChannel = [FlutterMethodChannel
        methodChannelWithName:@"gitjournal.io/git" binaryMessenger:controller];

    [gitChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        NSString *method = [call method];
        NSDictionary *arguments = [call arguments];

        NSLog(@"Called %@ with args - ", method);
        for (NSString *key in [arguments allKeys]) {
            NSLog(@"  %@: %@", key, [arguments objectForKey:key]);
        }

        NSString* filesDir = [self getApplicationDocumentsDirectory];
        if ([@"getBaseDirectory" isEqualToString:method]) {
            result(filesDir);
        }
        else if ([@"gitInit" isEqualToString:method]) {
            NSString *folderName = arguments[@"folderName"];
            NSArray *components = [NSArray arrayWithObjects:filesDir, folderName, nil];
            NSString* dirPath = [NSString pathWithComponents:components];

            int err = gj_git_init([dirPath UTF8String]);
            if (err < 0) {
                gj_error* error = gj_error_info(err);
                if (error) {
                    NSString* errorMessage = [NSString stringWithUTF8String:error->message];

                    result([FlutterError errorWithCode:@"FAILED"
                            message:errorMessage details:nil]);

                    gj_error_free(error);
                } else {
                    result([FlutterError errorWithCode:@"FAILED"
                            message:@"GitInit Failed" details:nil]);
                }
                return;
            }

            NSLog(@"Success");
            result(@YES);
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
