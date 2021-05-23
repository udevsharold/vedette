//  Copyright (c) 2021 udevs
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.

#include <Foundation/Foundation.h>
#include <HBLog.h>
#include <objc/runtime.h>

#define VEDETTE_IDENTIFIER @"com.udevs.vedette"
#define PREFS_PATH @"/var/mobile/Library/Preferences/com.udevs.vedette.plist"
#define PREFS_PATH_TMP @"/var/tmp/com.udevs.vedette.plist"

#define NOTIFY_PID_NN "com.udevs.vedette.notify-pid"
#define PREFS_CHANGED_NN @"com.udevs.vedette.prefschanged"
#define RESTORE_ALL_MONITORS_NN @"com.udevs.vedette.restore-all-monitors"
