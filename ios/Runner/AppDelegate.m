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

        NSString* filesDir = [self getApplicationDocumentsDirectory];

        NSArray *sshPublicComponents = [NSArray arrayWithObjects:filesDir, @"ssh", @"id_rsa.pub", nil];
        NSString *sshPublicKeyString = [NSString pathWithComponents:sshPublicComponents];

        NSArray *sshPrivateComponents = [NSArray arrayWithObjects:filesDir, @"ssh", @"id_rsa", nil];
        NSString *sshPrivateKeyString = [NSString pathWithComponents:sshPrivateComponents];

        if ([@"gitClone" isEqualToString:method]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self handleMethodCallAsync:call result:result];
            });
        }
        else if ([@"gitPull" isEqualToString:method]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self handleMethodCallAsync:call result:result];
            });
        }
        else if ([@"gitPush" isEqualToString:method]) {
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
        else if ([@"gitInit" isEqualToString:method]) {
            NSString *folderPath = arguments[@"folderPath"];

            if (folderPath == nil || [folderPath length] == 0) {
                result([FlutterError errorWithCode:@"InvalidParams"
                        message:@"Invalid folderPath" details:nil]);
                return;
            }

            int err = gj_git_init([folderPath UTF8String]);
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
        else if ([@"getSSHPublicKey" isEqualToString:method]) {
            NSError *error = nil;
            NSString *content = [NSString stringWithContentsOfFile:sshPublicKeyString
                                                          encoding:NSUTF8StringEncoding error:&error];

            if (error != nil) {
                result([FlutterError errorWithCode:@"FAILED"
                                           message:[error localizedDescription] details:nil]);
                return;
            }
            if (content == nil || [content length] == 0) {
                result([FlutterError errorWithCode:@"FAILED"
                                           message:@"PublicKey File not found" details:nil]);
                return;
            }

            result(content);
        }
        else if ([@"setSshKeys" isEqualToString:method]) {
            NSString *publicKey = arguments[@"publicKey"];
            NSString *privateKey = arguments[@"privateKey"];

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

            NSArray *sshComponents = [NSArray arrayWithObjects:filesDir, @"ssh", nil];
            NSString* sshDirPath = [NSString pathWithComponents:sshComponents];

            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:sshDirPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];

            if (error != nil) {
                NSLog(@"Create directory error: %@", error);
                result([FlutterError errorWithCode:@"FAILED"
                                           message:[error localizedDescription] details:nil]);
                return;
            }

            [publicKey writeToFile:sshPublicKeyString atomically:YES encoding:NSUTF8StringEncoding error:&error];

            if (error != nil) {
                result([FlutterError errorWithCode:@"FAILED"
                                           message:[error localizedDescription] details:nil]);
                return;
            }

            [privateKey writeToFile:sshPrivateKeyString atomically:YES encoding:NSUTF8StringEncoding error:&error];

            if (error != nil) {
                result([FlutterError errorWithCode:@"FAILED"
                                           message:[error localizedDescription] details:nil]);
                return;
            }

            result(@YES);
        }
        else if ([@"dumpAppLogs" isEqualToString:method]) {
            // FIXME: Todo implement this!
            result(@"");
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

- (NSString*)getApplicationDocumentsDirectory {
    return GetDirectoryOfType(NSDocumentDirectory);
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
            NSLog(@".  %@: %@", key, [arguments objectForKey:key]);
        }
    }

    NSString* filesDir = [self getApplicationDocumentsDirectory];

    NSArray *sshPublicComponents = [NSArray arrayWithObjects:filesDir, @"ssh", @"id_rsa.pub", nil];
    NSString *sshPublicKeyString = [NSString pathWithComponents:sshPublicComponents];
    const char *sshPublicKeyPath = [sshPublicKeyString UTF8String];

    NSArray *sshPrivateComponents = [NSArray arrayWithObjects:filesDir, @"ssh", @"id_rsa", nil];
    NSString *sshPrivateKeyString = [NSString pathWithComponents:sshPrivateComponents];
    const char *sshPrivateKeyPath = [sshPrivateKeyString UTF8String];

    if ([@"gitClone" isEqualToString:method]) {
        NSString *cloneUrl = arguments[@"cloneUrl"];
        NSString *folderPath = arguments[@"folderPath"];

        if (cloneUrl == nil || [cloneUrl length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid cloneUrl" details:nil]);
            return;
        }
        if (folderPath == nil || [folderPath length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid folderPath" details:nil]);
            return;
        }

        gj_set_ssh_keys_paths((char*) sshPublicKeyPath, (char*) sshPrivateKeyPath, "");

        int err = gj_git_clone([cloneUrl UTF8String], [folderPath UTF8String]);
        if (!handleError(result, err)) {
            result(@YES);
            return;
        }
    }
    else if ([@"gitPull" isEqualToString:method]) {
        NSString *folderPath = arguments[@"folderPath"];
        NSString *authorName = arguments[@"authorName"];
        NSString *authorEmail = arguments[@"authorEmail"];

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

        gj_set_ssh_keys_paths((char*) sshPublicKeyPath, (char*) sshPrivateKeyPath, "");

        int err = gj_git_pull([folderPath UTF8String], [authorName UTF8String], [authorEmail UTF8String]);
        if (!handleError(result, err)) {
            result(@YES);
            return;
        }
    }
    else if ([@"gitPush" isEqualToString:method]) {
        NSString *folderPath = arguments[@"folderPath"];

        if (folderPath == nil || [folderPath length] == 0) {
            result([FlutterError errorWithCode:@"InvalidParams"
                                       message:@"Invalid folderPath" details:nil]);
            return;
        }

        gj_set_ssh_keys_paths((char*) sshPublicKeyPath, (char*) sshPrivateKeyPath, "");

        int err = gj_git_push([folderPath UTF8String]);
        if (!handleError(result, err)) {
            result(@YES);
            return;
        }
    }
    else if ([@"generateSSHKeys" isEqualToString:method]) {
        NSString *comment = arguments[@"comment"];

        if (comment == nil || [comment length] == 0) {
            NSLog(@"generateSSHKeys: Using default comment");
            comment = @"Generated on iOS";
        }

        NSArray *sshComponents = [NSArray arrayWithObjects:filesDir, @"ssh", nil];
        NSString* sshDirPath = [NSString pathWithComponents:sshComponents];

        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:sshDirPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];

        if (error != nil) {
            NSLog(@"Create directory error: %@", error);
            result([FlutterError errorWithCode:@"FAILED"
                                       message:[error localizedDescription] details:nil]);
            return;
        }

        int err = gj_generate_ssh_keys(sshPrivateKeyPath, sshPublicKeyPath, [comment UTF8String]);
        if (handleError(result, err)) {
            return;
        }

        NSString *content = [NSString stringWithContentsOfFile:sshPublicKeyString
                                                      encoding:NSUTF8StringEncoding error:&error];

        if (error != nil) {
            result([FlutterError errorWithCode:@"FAILED"
                                       message:[error localizedDescription] details:nil]);
            return;
        }
        if (content == nil || [content length] == 0) {
            result([FlutterError errorWithCode:@"FAILED"
                                       message:@"PublicKey File not found" details:nil]);
            return;
        }

        result(content);
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
@end
