//  Copyright (c) 2021 udevs
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.

#import "Common.h"
#import "VDTShared.h"

NSDictionary* getPrefs(){
    NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
    [prefs addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREFS_PATH]];
    return [prefs copy];
}

NSDictionary* getTempPrefs(){
    NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
    [prefs addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREFS_PATH_TMP]];
    return [prefs copy];
}

id valueForKey(NSString *key){
    NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
    [prefs addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREFS_PATH]];
    return prefs[key] ?: nil;
}

id valueForKeyWithPrefs(NSString *key, NSDictionary *prefs){
    if (!prefs){
        return (valueForKey(key));
    }
    return prefs[key] ?: nil;
}

void setValueForKeyWithPrefs(NSString *key, id value, NSDictionary *prefs){
    NSMutableDictionary *newPrefs;
    
    if (!prefs){
        newPrefs = [NSMutableDictionary dictionary];
        [newPrefs addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREFS_PATH]];
    }else{
        newPrefs = [prefs mutableCopy];
    }
    
    [newPrefs setObject:value forKey:key];
    [newPrefs writeToFile:PREFS_PATH atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)PREFS_CHANGED_NN, NULL, NULL, YES);
}

void setValueForKey(NSString *key, id value){
    setValueForKeyWithPrefs(key, value, nil);
}

id valueForProcessConfigKeyWithPrefs(NSString *identifier, NSString *key, id defaultValue, VDTConfigType type, NSDictionary *prefs){
    id configs;
    if (!prefs){
        configs = valueForKey(type == VDTConfigTypeApp ? @"appConfigs" : @"daemonConfigs");
    }else{
        configs = prefs[type == VDTConfigTypeApp ? @"appConfigs" : @"daemonConfigs"];
    }
    if (configs){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", (type == VDTConfigTypeApp ? @"bundleIdentifier" : @"daemonName"), identifier];
        NSDictionary *config = [configs filteredArrayUsingPredicate:predicate].firstObject;
        return config[key] ?: defaultValue;
    }
    return defaultValue;
}

id valueForProcessConfigKey(NSString *identifier, NSString *key, id defaultValue, VDTConfigType type){
    return valueForProcessConfigKeyWithPrefs(identifier, key, defaultValue, type, nil);
}

void setValueForProcessConfigKeyWithPrefs(NSString *identifier, NSString *key, id value, VDTConfigType type, NSDictionary *prefs){
    NSMutableArray *configs;
    if (!prefs){
        configs = [valueForKey(type == VDTConfigTypeApp ? @"appConfigs" : @"daemonConfigs") mutableCopy];
    }else{
        configs = [prefs[type == VDTConfigTypeApp ? @"appConfigs" : @"daemonConfigs"] mutableCopy];
    }
    
    if (configs){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", (type == VDTConfigTypeApp ? @"bundleIdentifier" : @"daemonName"), identifier];
        NSMutableDictionary *config = [[configs filteredArrayUsingPredicate:predicate].firstObject mutableCopy];
        if (config){
            NSUInteger idx = [configs indexOfObject:config];
            config[key] = value;
            [configs replaceObjectAtIndex:idx withObject:config];
        }else{
            config = [NSMutableDictionary dictionary];
            [configs addObject:@{
                (type == VDTConfigTypeApp ? @"bundleIdentifier" : @"daemonName"):identifier,
                key:value
            }];
        }
    }else{
        configs = [NSMutableArray array];
        [configs addObject:@{
            (type == VDTConfigTypeApp ? @"bundleIdentifier" : @"daemonName"):identifier,
            key:value
        }];
    }
    setValueForKeyWithPrefs((type == VDTConfigTypeApp ? @"appConfigs" : @"daemonConfigs"), configs, prefs);
}

void setValueForProcessConfigKey(NSString *identifier, NSString *key, id value, VDTConfigType type){
    setValueForProcessConfigKeyWithPrefs(identifier, key, value, type, nil);
}
