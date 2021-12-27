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

static FlutterMethodChannel* gitChannel = 0;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    gj_init();

    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;

    gitChannel = [FlutterMethodChannel methodChannelWithName:@"gitjournal.io/git"
                                             binaryMessenger:controller];

    [gitChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        NSString *method = [call method];
        NSDictionary *arguments = [call arguments];

        NSLog(@"Called %@", method);
        if (arguments != nil) {
            for (NSString *key in [arguments allKeys]) {
                if ([key isEqualToString:@"privateKey"]) {
                    NSLog(@".  privateKey: <hidden>");
                    continue;
                }
                NSLog(@".  %@: %@", key, [arguments objectForKey:key]);
            }
        }

        if ([@"gitFetch" isEqualToString:method]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self handleMethodCallAsync:call result:result];
            });
        }
        else if ([@"gitMerge" isEqualToString:method]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self handleMethodCallAsync:call result:result];
            });
        }
        else if ([@"gitPush" isEqualToString:method]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self handleMethodCallAsync:call result:result];
            });
        }
        else if ([@"gitDefaultBranch" isEqualToString:method]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self handleMethodCallAsync:call result:result];
            });
        }
        else if ([@"gitAdd" isEqualToString:method]) {
            NSString *folderPath = arguments[@"folderPath"];
            NSString *filePattern = arguments[@"filePattern"];

            if (folderPath == nil || [folderPath length] == 0) {
                result([FlutterError errorWithCode:@"InvalidParams"
                                           message:@"Invalid folderPath" details:nil]);
                return;
            }
            if (filePattern == nil || [filePattern length] == 0) {
                result([FlutterError errorWithCode:@"InvalidParams"
                                           message:@"Invalid filePattern" details:nil]);
                return;
            }

            int err = gj_git_add([folderPath UTF8String], [filePattern UTF8String]);
            if (!handleError(result, err)) {
                result(@YES);
                return;
            }
        }
        else if ([@"gitRm" isEqualToString:method]) {
            NSString *folderPath = arguments[@"folderPath"];
            NSString *filePattern = arguments[@"filePattern"];

            if (folderPath == nil || [folderPath length] == 0) {
                result([FlutterError errorWithCode:@"InvalidParams"
                                           message:@"Invalid folderPath" details:nil]);
                return;
            }
            if (filePattern == nil || [filePattern length] == 0) {
                result([FlutterError errorWithCode:@"InvalidParams"
                                           message:@"Invalid filePattern" details:nil]);
                return;
            }

            int err = gj_git_rm([folderPath UTF8String], [filePattern UTF8String]);
            if (!handleError(result, err)) {
                result(@YES);
                return;
            }
        }
        else if ([@"gitCommit" isEqualToString:method]) {
            NSString *folderPath = arguments[@"folderPath"];
            NSString *authorName = arguments[@"authorName"];
            NSString *authorEmail = arguments[@"authorEmail"];
            NSString *message = arguments[@"message"];
            //NSString *when = arguments[@"when"];

            if (folderPath == nil || [folderPath length] == 0) {
                result([FlutterError errorWithCode:@"InvalidParams"
                                           message:@"Invalid folderPath" details:nil]);
                return;
            }
            if (authorName == nil || [authorName length] == 0) {
                result([FlutterError errorWithCode:@"InvalidParams"
                                           message:@"Invalid authorName" details:nil]);
                return;
            }
            if (authorEmail == nil || [authorEmail length] == 0) {
                result([FlutterError errorWithCode:@"InvalidParams"
                                           message:@"Invalid authorEmail" details:nil]);
                return;
            }
            if (message == nil || [message length] == 0) {
                result([FlutterError errorWithCode:@"InvalidParams"
                                           message:@"Invalid message" details:nil]);
                return;
            }

            int err = gj_git_commit([folderPath UTF8String], [authorName UTF8String],
                                    [authorEmail UTF8String], [message UTF8String], 0, 0);
            if (!handleError(result, err)) {
                result(@YES);
                return;
            }
        }
        else if ([@"gitResetLast" isEqualToString:method]) {
            NSString *folderPath = arguments[@"folderPath"];

            if (folderPath == nil || [folderPath length] == 0) {
                result([FlutterError errorWithCode:@"InvalidParams"
                                           message:@"Invalid folderPath" details:nil]);
                return;
            }

            int err = gj_git_reset_hard([folderPath UTF8String], "HEAD^");
            if (!handleError(result, err)) {
                result(@YES);
                return;
            }
        }
        else if ([@"generateSSHKeys" isEqualToString:method]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self handleMethodCallAsync:call result:result];
            });
        }
        else {
            NSLog(@"Not Implemented");
            result(FlutterMethodNotImplemented);
        }
    }];

    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


bool handleError(FlutterResult result, int err) {
    if (err >= 0) {
        NSLog(@"Success");
        return false;
    }

    gj_error* error = gj_error_info(err);
    if (error) {
        NSString* errorMessage = [NSString stringWithUTF8String:error->message];
        NSLog(@"GitJournalLib-ios: %@", errorMessage);
        result([FlutterError errorWithCode:@"FAILED"
                                   message:errorMessage details:nil]);

        gj_error_free(error);
    } else {
        NSLog(@"GitJournalLib-ios: Unknown error with code %d", err);
        result([FlutterError errorWithCode:@"FAILED"
                                   message:@"Failed" details:nil]);
    }

    return false;
}

- (void)handleMethodCallAsync:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *method = [call method];
    NSDictionary *arguments = [call arguments];

    NSLog(@"AsyncCalled %@", method);
    if (arguments != nil) {
        for (NSString *key in [arguments allKeys]) {
            if ([key isEqualToString:@"privateKey"]) {
                NSLog(@".  privateKey: <hidden>");
                continue;
            }
            if ([key isEqualToString:@"password"]) {
                NSLog(@".  password: <hidden>");
                continue;
            }
            NSLog(@".  %@: %@", key, [arguments objectForKey:key]);
        }
    }

    if ([@"gitFetch" isEqualToString:method]) {
        NSString *folderPath = arguments[@"folderPath"];
        NSString *remote = arguments[@"remote"];
        NSString *publicKey = arguments[@"publicKey"];
        NSString *privateKey = arguments[@"privateKey"];
        NSString *password = arguments[@"password"];
        NSString *statusFile = arguments[@"statusFile"];

        if (publicKey == nil || [publicKey length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid publicKey" details:nil]);
            return;
        }
        if (privateKey == nil || [privateKey length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid privateKey" details:nil]);
            return;
        }
        if (password == nil || [privateKey length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid password" details:nil]);
            return;
        }

        if (folderPath == nil || [folderPath length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid folderPath" details:nil]);
            return;
        }
        if (remote == nil || [remote length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid remote" details:nil]);
            return;
        }
        if (statusFile == nil) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid statusFile" details:nil]);
            return;
        }

        int err = gj_git_fetch([folderPath UTF8String], [remote UTF8String], [publicKey UTF8String], [privateKey UTF8String], [password UTF8String], true, [statusFile UTF8String]);
        if (!handleError(result, err)) {
            result(@YES);
            return;
        }
    }
    else if ([@"gitMerge" isEqualToString:method]) {
        NSString *folderPath = arguments[@"folderPath"];
        NSString *authorName = arguments[@"authorName"];
        NSString *authorEmail = arguments[@"authorEmail"];
        NSString *branch = arguments[@"branch"];

        if (folderPath == nil || [folderPath length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid folderPath" details:nil]);
            return;
        }
        if (authorName == nil || [authorName length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid authorName" details:nil]);
            return;
        }
        if (authorEmail == nil || [authorEmail length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid authorEmail" details:nil]);
            return;
        }
        if (branch == nil || [branch length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid branch" details:nil]);
            return;
        }

        int err = gj_git_merge([folderPath UTF8String], [branch UTF8String], [authorName UTF8String], [authorEmail UTF8String]);
        if (!handleError(result, err)) {
            result(@YES);
            return;
        }
    }
    else if ([@"gitPush" isEqualToString:method]) {
        NSString *folderPath = arguments[@"folderPath"];
        NSString *remote = arguments[@"remote"];
        NSString *publicKey = arguments[@"publicKey"];
        NSString *privateKey = arguments[@"privateKey"];
        NSString *password = arguments[@"password"];
        NSString *statusFile = arguments[@"statusFile"];

        if (publicKey == nil || [publicKey length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid publicKey" details:nil]);
            return;
        }
        if (privateKey == nil || [privateKey length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid privateKey" details:nil]);
            return;
        }
        if (password == nil || [privateKey length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid password" details:nil]);
            return;
        }

        if (folderPath == nil || [folderPath length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid folderPath" details:nil]);
            return;
        }
        if (remote == nil || [remote length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid remote" details:nil]);
            return;
        }
        if (statusFile == nil) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid statusFile" details:nil]);
            return;
        }

        int err = gj_git_push([folderPath UTF8String], [remote UTF8String], [publicKey UTF8String], [privateKey UTF8String], [password UTF8String], true, [statusFile UTF8String]);
        if (!handleError(result, err)) {
            result(@YES);
            return;
        }
    }
    else if ([@"gitDefaultBranch" isEqualToString:method]) {
        NSString *folderPath = arguments[@"folderPath"];
        NSString *remote = arguments[@"remote"];
        NSString *publicKey = arguments[@"publicKey"];
        NSString *privateKey = arguments[@"privateKey"];
        NSString *password = arguments[@"password"];

        if (publicKey == nil || [publicKey length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid publicKey" details:nil]);
            return;
        }
        if (privateKey == nil || [privateKey length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid privateKey" details:nil]);
            return;
        }
        if (password == nil || [privateKey length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid password" details:nil]);
            return;
        }

        if (folderPath == nil || [folderPath length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid folderPath" details:nil]);
            return;
        }
        if (remote == nil || [remote length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid remote" details:nil]);
            return;
        }

        char branch_name[1024];
        int err = gj_git_default_branch([folderPath UTF8String], [remote UTF8String], [publicKey UTF8String], [privateKey UTF8String], [password UTF8String], true, branch_name);
        if (err == 0)
        {
            result(@(branch_name));
            return;
        }
        if (!handleError(result, err)) {
            result(@YES);
            return;
        }
    }
    else if ([@"generateSSHKeys" isEqualToString:method]) {
        NSString *comment = arguments[@"comment"];
        NSString *privateKeyPath = arguments[@"privateKeyPath"];
        NSString *publicKeyPath = arguments[@"publicKeyPath"];

        if (comment == nil || [comment length] == 0) {
            NSLog(@"generateSSHKeys: Using default comment");
            comment = @"Generated on iOS";
        }
        if (privateKeyPath == nil || [privateKeyPath length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid privateKeyPath" details:nil]);
            return;
        }
        if (publicKeyPath == nil || [publicKeyPath length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid publicKeyPath" details:nil]);
            return;
        }

        int err = gj_generate_ssh_keys([privateKeyPath UTF8String], [publicKeyPath UTF8String], [comment UTF8String]);
        if (!handleError(result, err)) {
            result(@YES);
            return;
        }
    }
}

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

// For quick_actions - https://github.com/flutter/flutter/issues/13634
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL succeeded))completionHandler {
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;

    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/quick_actions" binaryMessenger:controller];
    [channel invokeMethod:@"launch" arguments:shortcutItem.type];
}
@end
