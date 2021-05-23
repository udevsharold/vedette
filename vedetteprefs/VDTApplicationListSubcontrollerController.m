//  Copyright (c) 2021 udevs
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.

#import "VDTApplicationListSubcontrollerController.h"
#import "../VDTShared.h"

@implementation VDTApplicationListSubcontrollerController
- (NSString*)previewStringForApplicationWithIdentifier:(NSString *)applicationID{
    return [valueForProcessConfigKey(applicationID, @"enabled", nil, VDTConfigTypeApp) boolValue] ? @"Enabled" : @"";
}
@end
