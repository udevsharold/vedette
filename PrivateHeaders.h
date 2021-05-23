//  Copyright (c) 2021 udevs
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.

#import "Common.h"

@interface NSObject (Private)
-(id)safeValueForKey:(id)arg1 ;
@end

@interface _LSQueryResult : NSObject
@end

@interface LSResourceProxy : _LSQueryResult
@end

@interface LSBundleProxy : LSResourceProxy
@property (nonatomic,readonly) NSString * bundleIdentifier;
@property (nonatomic,readonly) NSString * bundleExecutable;
@property (nonatomic,readonly) NSURL * bundleURL;
@property (nonatomic,readonly) NSURL * bundleContainerURL;
@property (nonatomic,readonly) NSURL * dataContainerURL;
@end

@interface LSApplicationProxy : LSBundleProxy
+(id)applicationProxyForBundleURL:(NSURL *)bundleURL;
@end

@interface LSApplicationWorkspace : NSObject
+(id)defaultWorkspace;
-(NSArray <LSApplicationProxy *>*)allApplications;
@end

@interface SBSRelaunchAction : NSObject
@property (nonatomic, readonly) unsigned long long options;
@property (nonatomic, readonly, copy) NSString *reason;
@property (nonatomic, readonly, retain) NSURL *targetURL;
+ (id)actionWithReason:(id)arg1 options:(unsigned long long)arg2 targetURL:(id)arg3;
- (id)initWithReason:(id)arg1 options:(unsigned long long)arg2 targetURL:(id)arg3;
- (unsigned long long)options;
- (id)reason;
- (id)targetURL;

@end

@interface FBSSystemService : NSObject
+ (id)sharedService;
- (void)sendActions:(id)arg1 withResult:(/*^block*/id)arg2;
@end
