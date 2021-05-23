//  Copyright (c) 2021 udevs
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.

#import "Common.h"
#import "VDTProcessManager.h"
#import "VDTShared.h"

#include <notify.h>

#pragma mark processes
static void notify_new_pid(const char *notificationName, uint64_t pid){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        int token = 0;
        notify_register_check(notificationName, &token);
        notify_set_state(token, pid);
        notify_cancel(token);
        notify_post(notificationName);
    });
}

#pragma mark runningboardd
static int notify_pid_token;

static void reloadPrefs(){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        prefs = getPrefs();
        
        id enabledVal = valueForKeyWithPrefs(@"enabled", prefs);
        BOOL enabled = enabledVal ? [enabledVal boolValue] : YES;
        
        NSMutableArray *percentages = [NSMutableArray array];
        NSMutableArray *intervals = [NSMutableArray array];
        NSMutableArray *identifiers = [NSMutableArray array];
        NSMutableArray *types = [NSMutableArray array];
        
        NSArray *appConfigs = prefs[@"appConfigs"];
        HBLogDebug(@"appConfigs: %@", appConfigs);
        
        for (NSUInteger idx = 0; idx < appConfigs.count; idx++){
            NSString *bundleIdentifier = appConfigs[idx][@"bundleIdentifier"];
            if ([bundleIdentifier isEqualToString:@"com.apple.Preferences"]){
                continue;
            }
            [identifiers addObject:bundleIdentifier];
            [types addObject:@(VDTConfigTypeApp)];
            int percentage = [valueForProcessConfigKeyWithPrefs(bundleIdentifier, @"percentage", @80, VDTConfigTypeApp, prefs) intValue];
            int interval = [valueForProcessConfigKeyWithPrefs(bundleIdentifier, @"interval", @120, VDTConfigTypeApp, prefs) intValue];
            BOOL processEnabled = [valueForProcessConfigKeyWithPrefs(bundleIdentifier, @"enabled", @NO, VDTConfigTypeApp, prefs) boolValue];
            [percentages addObject:@(enabled && processEnabled ? percentage : 0)];
            [intervals addObject:@(enabled && processEnabled ? interval : 0)];
            
        }
        
        NSArray *daemonConfigs = prefs[@"daemonConfigs"];
        HBLogDebug(@"daemonConfigs: %@", daemonConfigs);
        
        for (NSUInteger idx = 0; idx < daemonConfigs.count; idx++){
            NSString *daemonName = daemonConfigs[idx][@"daemonName"];
            [identifiers addObject:daemonName];
            [types addObject:@(VDTConfigTypeDaemon)];
            int percentage = [valueForProcessConfigKeyWithPrefs(daemonName, @"percentage", @80, VDTConfigTypeDaemon, prefs) intValue];
            int interval = [valueForProcessConfigKeyWithPrefs(daemonName, @"interval", @120, VDTConfigTypeDaemon, prefs) intValue];
            BOOL processEnabled = [valueForProcessConfigKeyWithPrefs(daemonName, @"enabled", @NO, VDTConfigTypeDaemon, prefs) boolValue];
            [percentages addObject:@(enabled && processEnabled ? percentage : 0)];
            [intervals addObject:@(enabled && processEnabled ? interval : 0)];
        }
        
        HBLogDebug(@"identifiers: %@", identifiers);
        NSArray *pids = pids_with_identifier_and_type(identifiers, types);
        HBLogDebug(@"pids: %@ ** %@ ** %@", pids, percentages, intervals);
        
        monitor_pids(pids, percentages, intervals);
        
    });
}

static void restoreAllMonitors(){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //restore_all_monitors();
        NSDictionary *tmpPrefs = getTempPrefs();
        NSMutableArray *identifiers = [NSMutableArray array];
        NSMutableArray *types = [NSMutableArray array];
        NSArray *appConfigs = tmpPrefs[@"appConfigs"];
        if (appConfigs.count > 0){
            [identifiers addObjectsFromArray:[appConfigs valueForKey:@"bundleIdentifier"]];
        }
        NSArray *daemonConfigs = tmpPrefs[@"daemonConfigs"];
        if (daemonConfigs.count > 0){
            [identifiers addObjectsFromArray:[daemonConfigs valueForKey:@"daemonName"]];
        }
        NSMutableArray *zeroesArray = [NSMutableArray array];
        for (NSUInteger idx = 0; idx < identifiers.count; idx++){
            [zeroesArray addObject:@0];
            if (idx < appConfigs.count){
                [types addObject:@(VDTConfigTypeApp)];
            }else{
                [types addObject:@(VDTConfigTypeDaemon)];
            }
        }
        
        //Restore all monitors
        NSArray *pids = pids_with_identifier_and_type(identifiers, types);
        monitor_pids(pids, zeroesArray, zeroesArray);
        
        [[NSFileManager defaultManager] removeItemAtPath:PREFS_PATH_TMP error:nil];
    });
}

%ctor{
    @autoreleasepool {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSProcessInfo *procInfo = [objc_getClass("NSProcessInfo") processInfo];
            NSArray *args = [procInfo arguments];
            
            if (args.count != 0) {
                
                NSString *executablePath = args[0];
                if (executablePath){
                    
                    BOOL isApplication = ([executablePath rangeOfString:@"/Application"].location != NSNotFound) || ([executablePath rangeOfString:@"/CoreServices"].location != NSNotFound);
                    
                    NSString *processName = [executablePath lastPathComponent];
                    
                    if ([processName isEqualToString:@"runningboardd"]){
                        reloadPrefs();
                        notify_register_dispatch(NOTIFY_PID_NN, &notify_pid_token, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(int token) {
                            uint64_t pid = 0;
                            notify_get_state(token, &pid);
                            if (pid > 0){
                                monitor_new_proc((pid_t)pid);
                            }
                        });
                        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, (CFStringRef)PREFS_CHANGED_NN, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)restoreAllMonitors, (CFStringRef)RESTORE_ALL_MONITORS_NN, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                    }else{
                        NSString *bundleIdentifier = isApplication ? [[NSBundle mainBundle] bundleIdentifier] : nil;
                        if(isApplication && [bundleIdentifier isEqualToString:@"com.apple.Preferences"]){
                            HBLogDebug(@"Yeah, just no.");
                            return;
                        }
                        NSDictionary *weakPrefs = getPrefs();
                        id enabledVal = valueForKeyWithPrefs(@"enabled", prefs);
                        BOOL enabled = enabledVal ? [enabledVal boolValue] : YES;
                        BOOL processEnabled = [valueForProcessConfigKeyWithPrefs((isApplication ? bundleIdentifier : processName), @"enabled", @NO, (isApplication ? VDTConfigTypeApp : VDTConfigTypeDaemon), weakPrefs) boolValue];
                        if (enabled && processEnabled){
                            HBLogDebug(@"Notify new pid: %d", [procInfo processIdentifier]);
                            notify_new_pid(NOTIFY_PID_NN, [procInfo processIdentifier]);
                        }
                    }
                    
                }
            }
        });
    }
    
}
