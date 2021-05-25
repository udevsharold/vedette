//  Copyright (c) 2021 udevs
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.

#import "Common.h"

#include <libproc/libproc.h>
#include <libproc/libproc_internal.h>

extern NSDictionary *prefs;

#ifdef __cplusplus
extern "C" {
#endif

NSArray* pids_with_identifier_and_type(NSArray <NSString *>*identifiers, NSArray <NSNumber *> *types);
void monitor_pids(NSArray <NSNumber *> *pids, NSArray <NSNumber *> *percentages, NSArray <NSNumber *> *intervals);
void throttle_pids(NSArray <NSNumber *> *pids, NSArray <NSNumber *> *percentages);
void received_new_proc(pid_t pid);
//void restore_all_monitors();

#ifdef __cplusplus
}
#endif

