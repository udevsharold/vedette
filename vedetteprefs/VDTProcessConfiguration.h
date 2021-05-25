//  Copyright (c) 2021 udevs
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.

#import "../Common.h"
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "PrivateHeaders.h"

@interface VDTProcessConfiguration : PSListController{
    PSSpecifier *_intervalSpecifier;
}

@end
