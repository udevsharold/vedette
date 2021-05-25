//  Copyright (c) 2021 udevs
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.

#import "Common.h"

typedef NS_ENUM(NSUInteger, VDTConfigType) {
    VDTConfigTypeApp,
    VDTConfigTypeDaemon
};

typedef NS_ENUM(NSUInteger, VDTViolationPolicy) {
    VDTViolationPolicyNone,
    VDTViolationPolicyMonitor,
    VDTViolationPolicyMonitorAndTerminate,
    VDTViolationPolicyThrottle
};

#ifdef __cplusplus
extern "C" {
#endif

NSDictionary* getPrefs();
NSDictionary* getTempPrefs();
id valueForKey(NSString *key);
id valueForKeyWithPrefs(NSString *key, NSDictionary *prefs);
void setValueForKey(NSString *key, id value);
void setValueForKeyWithPrefs(NSString *key, id value, NSDictionary *prefs);
id valueForProcessConfigKey(NSString *identifier, NSString *key, id defaultValue, VDTConfigType type);
id valueForProcessConfigKeyWithPrefs(NSString *identifier, NSString *key, id defaultValue, VDTConfigType type, NSDictionary *prefs);
void setValueForProcessConfigKey(NSString *identifier, NSString *key, id value, VDTConfigType type);
void setValueForProcessConfigKeyWithPrefs(NSString *identifier, NSString *key, id value, VDTConfigType type, NSDictionary *prefs);

#ifdef __cplusplus
}
#endif

