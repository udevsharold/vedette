//  Copyright (c) 2021 udevs
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.

#import "VDTProcessConfiguration.h"
#import "VDTApplicationListSubcontrollerController.h"
#import "../VDTShared.h"
#import "ChoicyPreferences/CHPDaemonListController.h"

@implementation VDTProcessConfiguration

- (NSString*)validIdentifier{
    return  [self configurationType] == VDTConfigTypeApp ? [[self specifier] propertyForKey:@"applicationIdentifier"] : [[self specifier] propertyForKey:@"daemonName"];
}

-(VDTConfigType)configurationType{
    return [[[self specifier] propertyForKey:@"configurationType"] unsignedLongValue];
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *rootSpecifiers = [[NSMutableArray alloc] init];
        
        NSString *validIdentifier = [self validIdentifier];
        BOOL isPreferencesApp = [validIdentifier isEqualToString:@"com.apple.Preferences"];
        
        //Enabled
        PSSpecifier *monitorEnabledGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"Monitor" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [monitorEnabledGroupSpec setProperty:@"Terminate process when it violates the maximum allowed CPU usage based on the interval." forKey:@"footerText"];
        [rootSpecifiers addObject:monitorEnabledGroupSpec];
    
        PSSpecifier *monitorEnabledSpec = [PSSpecifier preferenceSpecifierNamed:@"Enabled" target:self set:@selector(setProcessConfigValue:specifier:) get:@selector(readProcessConfigValue:) detail:nil cell:PSSwitchCell edit:nil];
        [monitorEnabledSpec setProperty:@"Enabled" forKey:@"label"];
        [monitorEnabledSpec setProperty:@"enabled" forKey:@"key"];
        [monitorEnabledSpec setProperty:@NO forKey:@"default"];
        [monitorEnabledSpec setProperty:(isPreferencesApp?@NO:@YES) forKey:@"enabled"];
        [monitorEnabledSpec setProperty:VEDETTE_IDENTIFIER forKey:@"defaults"];
        [monitorEnabledSpec setProperty:PREFS_CHANGED_NN forKey:@"PostNotification"];
        [rootSpecifiers addObject:monitorEnabledSpec];
        
        
        //Violation Policy
        PSSpecifier *violationPolicyGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [violationPolicyGroupSpec setProperty:@"Action for CPU limits violation." forKey:@"footerText"];
        [rootSpecifiers addObject:violationPolicyGroupSpec];
        
        PSSpecifier *violationPolicySelectionSpec = [PSSpecifier preferenceSpecifierNamed:@"Violation Policy Selection" target:self set:@selector(setProcessConfigValue:specifier:) get:@selector(readProcessConfigValue:) detail:nil cell:PSSegmentCell edit:nil];
        [violationPolicySelectionSpec setValues:@[@(VDTViolationPolicyMonitorAndTerminate), @(VDTViolationPolicyThrottle)] titles:@[@"Terminate", @"Throttle"]];
        [violationPolicySelectionSpec setProperty:@(VDTViolationPolicyMonitorAndTerminate) forKey:@"default"];
        [violationPolicySelectionSpec setProperty:@"violationPolicy" forKey:@"key"];
        [violationPolicySelectionSpec setProperty:VEDETTE_IDENTIFIER forKey:@"defaults"];
        [violationPolicySelectionSpec setProperty:PREFS_CHANGED_NN forKey:@"PostNotification"];
        [rootSpecifiers addObject:violationPolicySelectionSpec];
        
        //CPU Usage Percentage
        PSSpecifier *maxCPUUsageGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"Parameters" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [maxCPUUsageGroupSpec setProperty:@"Set maximum allowed CPU usage and/or interval (s).\n\nWARNING: If throttle percentage is set to too low, iOS will terminate it regardless due to timeout and not being able to finish tasks on time." forKey:@"footerText"];
        [rootSpecifiers addObject:maxCPUUsageGroupSpec];
        
        PSTextFieldSpecifier* maxCPUUsageSpec = [PSTextFieldSpecifier preferenceSpecifierNamed:@"Percentage" target:self set:@selector(setProcessConfigValue:specifier:) get:@selector(readProcessConfigValue:) detail:nil cell:PSEditTextCell edit:nil];
        [maxCPUUsageSpec setKeyboardType:UIKeyboardTypeNumberPad autoCaps:UITextAutocapitalizationTypeNone autoCorrection:UITextAutocorrectionTypeNo];
        [maxCPUUsageSpec setProperty:(isPreferencesApp?@NO:@YES) forKey:@"enabled"];
        [maxCPUUsageSpec setPlaceholder:@"80"];
        [maxCPUUsageSpec setProperty:@"percentage" forKey:@"key"];
        [maxCPUUsageSpec setProperty:@"Percentage" forKey:@"label"];
        [maxCPUUsageSpec setProperty:PREFS_CHANGED_NN forKey:@"PostNotification"];
        [maxCPUUsageSpec setProperty:VEDETTE_IDENTIFIER forKey:@"defaults"];
        [rootSpecifiers addObject:maxCPUUsageSpec];
        
        //Interval
        PSTextFieldSpecifier* intervalSpec = [PSTextFieldSpecifier preferenceSpecifierNamed:@"Interval" target:self set:@selector(setProcessConfigValue:specifier:) get:@selector(readProcessConfigValue:) detail:nil cell:PSEditTextCell edit:nil];
        [intervalSpec setKeyboardType:UIKeyboardTypeNumberPad autoCaps:UITextAutocapitalizationTypeNone autoCorrection:UITextAutocorrectionTypeNo];
        [intervalSpec setProperty:(isPreferencesApp?@NO:@YES) forKey:@"enabled"];
        [intervalSpec setPlaceholder:@"120"];
        [intervalSpec setProperty:@"interval" forKey:@"key"];
        [intervalSpec setProperty:@"Interval" forKey:@"label"];
        [intervalSpec setProperty:PREFS_CHANGED_NN forKey:@"PostNotification"];
        [intervalSpec setProperty:VEDETTE_IDENTIFIER forKey:@"defaults"];
        _intervalSpecifier = intervalSpec;
        [rootSpecifiers addObject:intervalSpec];
        
        _specifiers = rootSpecifiers;
    }
    
    return _specifiers;
}

- (void)setProcessConfigValue:(id)value specifier:(PSSpecifier*)specifier{
    NSString *key = [specifier propertyForKey:@"key"];
    setValueForProcessConfigKey([self validIdentifier], key, value, [self configurationType]);
    
    if ([key isEqualToString:@"enabled"]){
        UIViewController *parentController = (UIViewController *)[self valueForKey:@"_parentController"];

        switch ([self configurationType]) {
            case VDTConfigTypeApp:{
                [(VDTApplicationListSubcontrollerController *)parentController reloadSpecifier:[(VDTApplicationListSubcontrollerController *)parentController specifierForApplicationWithIdentifier:[self validIdentifier]] animated:NO];
                break;
            }
            case VDTConfigTypeDaemon:{
                [(CHPDaemonListController *)parentController reloadValueOfSelectedSpecifier];
                break;
            }
            default:
                break;
        }
    }else if ([key isEqualToString:@"violationPolicy"]){
        switch ([value unsignedLongValue]) {
            case VDTViolationPolicyMonitorAndTerminate:
                [_intervalSpecifier setProperty:@YES forKey:@"enabled"];
                break;
            case VDTViolationPolicyThrottle:
                [_intervalSpecifier setProperty:@NO forKey:@"enabled"];
                break;
            default:
                break;
        }
        [self reloadSpecifier:_intervalSpecifier animated:YES];
    }
    
}

- (id)readProcessConfigValue:(PSSpecifier*)specifier{
    NSString *key = [specifier propertyForKey:@"key"];
    id value = valueForProcessConfigKey([self validIdentifier], key, [specifier propertyForKey:@"default"], [self configurationType]);
    if ([key isEqualToString:@"violationPolicy"]){
        switch ([value unsignedLongValue]) {
            case VDTViolationPolicyMonitorAndTerminate:
                [_intervalSpecifier setProperty:@YES forKey:@"enabled"];
                break;
            case VDTViolationPolicyThrottle:
                [_intervalSpecifier setProperty:@NO forKey:@"enabled"];
                break;
            default:
                break;
        }
        [self reloadSpecifier:_intervalSpecifier animated:YES];
    }
    return value;
}


@end
