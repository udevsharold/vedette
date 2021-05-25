//  Copyright (c) 2021 udevs
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.

#import "VDTRootListController.h"
#import "../VDTShared.h"

@implementation VDTRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *rootSpecifiers = [[NSMutableArray alloc] init];
        
        //Tweak
        PSSpecifier *tweakEnabledGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"Tweak" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        //[tweakEnabledGroupSpec setProperty:@"Changing this requires a respring using the dedicated \"Apply\" button." forKey:@"footerText"];
        [rootSpecifiers addObject:tweakEnabledGroupSpec];
        
        PSSpecifier *tweakEnabledSpec = [PSSpecifier preferenceSpecifierNamed:@"Enabled" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [tweakEnabledSpec setProperty:@"Enabled" forKey:@"label"];
        [tweakEnabledSpec setProperty:@"enabled" forKey:@"key"];
        [tweakEnabledSpec setProperty:@YES forKey:@"default"];
        [tweakEnabledSpec setProperty:VEDETTE_IDENTIFIER forKey:@"defaults"];
        [tweakEnabledSpec setProperty:PREFS_CHANGED_NN forKey:@"PostNotification"];
        [rootSpecifiers addObject:tweakEnabledSpec];
        
        
        //Manage
        PSSpecifier *manageGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"Manage" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [rootSpecifiers addObject:manageGroupSpec];
        
        //Apps
        PSSpecifier *altListSpec = [PSSpecifier preferenceSpecifierNamed:@"Applications" target:nil set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"VDTApplicationListSubcontrollerController") cell:PSLinkListCell edit:nil];
        [altListSpec setProperty:@"VDTProcessConfiguration" forKey:@"subcontrollerClass"];
        [altListSpec setProperty:@"Applications" forKey:@"label"];
        [altListSpec setProperty:@[
            @{@"sectionType":@"All"},
        ] forKey:@"sections"];
        [altListSpec setProperty:@YES forKey:@"useSearchBar"];
        [altListSpec setProperty:@YES forKey:@"hideSearchBarWhileScrolling"];
        [altListSpec setProperty:@YES forKey:@"alphabeticIndexingEnabled"];
        [altListSpec setProperty:@NO forKey:@"showIdentifiersAsSubtitle"];
        [altListSpec setProperty:@(VDTConfigTypeApp) forKey:@"configurationType"];
        [rootSpecifiers addObject:altListSpec];

        //Daemons
        PSSpecifier *daemonListSpec = [PSSpecifier preferenceSpecifierNamed:@"Daemons" target:nil set:nil get:nil detail:NSClassFromString(@"CHPDaemonListController") cell:PSLinkCell edit:nil];
        [rootSpecifiers addObject:daemonListSpec];
        
        //reset
        PSSpecifier *resetGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [resetGroupSpec setProperty:@"Reset everything to default." forKey:@"footerText"];
        [rootSpecifiers addObject:resetGroupSpec];
        
        PSSpecifier *resetSpec = [PSSpecifier preferenceSpecifierNamed:@"Reset" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [resetSpec setProperty:@"Reset" forKey:@"label"];
        [resetSpec setButtonAction:@selector(reset)];
        [rootSpecifiers addObject:resetSpec];
        
        //blsnk group
        PSSpecifier *blankSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [rootSpecifiers addObject:blankSpecGroup];
        
        //Support Dev
        PSSpecifier *supportDevGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"Development" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [rootSpecifiers addObject:supportDevGroupSpec];
        
        PSSpecifier *supportDevSpec = [PSSpecifier preferenceSpecifierNamed:@"Support Development" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [supportDevSpec setProperty:@"Support Development" forKey:@"label"];
        [supportDevSpec setButtonAction:@selector(donation)];
        [supportDevSpec setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/VedettePrefs.bundle/PayPal.png"] forKey:@"iconImage"];
        [rootSpecifiers addObject:supportDevSpec];
        
        
        //Contact
        PSSpecifier *contactGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"Contact" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [rootSpecifiers addObject:contactGroupSpec];
        
        //Twitter
        PSSpecifier *twitterSpec = [PSSpecifier preferenceSpecifierNamed:@"Twitter" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [twitterSpec setProperty:@"Twitter" forKey:@"label"];
        [twitterSpec setButtonAction:@selector(twitter)];
        [twitterSpec setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/VedettePrefs.bundle/Twitter.png"] forKey:@"iconImage"];
        [rootSpecifiers addObject:twitterSpec];
        
        //Reddit
        PSSpecifier *redditSpec = [PSSpecifier preferenceSpecifierNamed:@"Reddit" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [redditSpec setProperty:@"Twitter" forKey:@"label"];
        [redditSpec setButtonAction:@selector(reddit)];
        [redditSpec setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/VedettePrefs.bundle/Reddit.png"] forKey:@"iconImage"];
        [rootSpecifiers addObject:redditSpec];
        
        //udevs
        PSSpecifier *createdByGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [createdByGroupSpec setProperty:@"Created by udevs" forKey:@"footerText"];
        [createdByGroupSpec setProperty:@1 forKey:@"footerAlignment"];
        [rootSpecifiers addObject:createdByGroupSpec];
        
        _specifiers = rootSpecifiers;
    }
    
    return _specifiers;
}

-(void)viewDidLoad  {
    [super viewDidLoad];
    
    
    CGRect frame = CGRectMake(0,0,self.table.bounds.size.width,170);
    CGRect Imageframe = CGRectMake(0,10,self.table.bounds.size.width,80);
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor colorWithRed: 0.20 green: 0.60 blue: 0.60 alpha: 1.00];
    
    
    UIImage *headerImage = [[UIImage alloc]
                            initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/VedettePrefs.bundle"] pathForResource:@"Vedette512" ofType:@"png"]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:Imageframe];
    [imageView setImage:headerImage];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerView addSubview:imageView];
    
    CGRect labelFrame = CGRectMake(0,imageView.frame.origin.y + 90 ,self.table.bounds.size.width,80);
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [headerLabel setText:@"Vedette"];
    [headerLabel setFont:font];
    [headerLabel setTextColor:[UIColor blackColor]];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerLabel setContentMode:UIViewContentModeScaleAspectFit];
    [headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerView addSubview:headerLabel];
    
    self.table.tableHeaderView = headerView;
    
    self.respringBtn = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(_reallyRespring)];
    self.navigationItem.rightBarButtonItem = self.respringBtn;
}

-(void)_reallyRespring{
    NSURL *relaunchURL = [NSURL URLWithString:@"prefs:root=Vedette"];
    SBSRelaunchAction *restartAction = [NSClassFromString(@"SBSRelaunchAction") actionWithReason:@"RestartRenderServer" options:4 targetURL:relaunchURL];
    [[NSClassFromString(@"FBSSystemService") sharedService] sendActions:[NSSet setWithObject:restartAction] withResult:nil];
}

- (void)donation {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/udevs"] options:@{} completionHandler:nil];
}

- (void)twitter {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/udevs9"] options:@{} completionHandler:nil];
}

- (void)reddit {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.reddit.com/user/h4roldj"] options:@{} completionHandler:nil];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    return valueForKey(specifier.properties[@"key"]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    setValueForKey(specifier.properties[@"key"], value);
}

-(void)reset{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Vedette" message:@"Reset everything back to default?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:PREFS_PATH_TMP error:nil];

        [[NSFileManager defaultManager] copyItemAtPath:PREFS_PATH toPath:PREFS_PATH_TMP error:&error];
        
        void (^errorAlert)(NSError *) = ^(NSError *err){
            UIAlertController *alertFailed = [UIAlertController alertControllerWithTitle:@"Vedette" message:[NSString stringWithFormat:@"Failed to reset. %@", err.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }];
            [alertFailed addAction:okAction];
            
            [self presentViewController:alertFailed animated:YES completion:nil];
        };
        
        if (error){
            errorAlert(error);
            return;
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:PREFS_PATH error:&error];
        
        if (error){
            errorAlert(error);
            return;
        }else{
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)PREFS_CHANGED_NN, NULL, NULL, YES);
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)RESTORE_ALL_MONITORS_NN, NULL, NULL, YES);
            [self reloadSpecifiers];
        }
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
}
@end
