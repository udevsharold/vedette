// Copyright (c) 2019-2021 Lars Fröder

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "CHPDaemonListController.h"

#import "CHPDaemonInfo.h"
#import "CHPDaemonList.h"
#import "../VDTProcessConfiguration.h"
#import "../../VDTShared.h"

@interface PSListController()
- (id)controllerForSpecifier:(PSSpecifier*)specifier;
@end

@implementation CHPDaemonListController

- (void)viewDidLoad
{
	[self applySearchControllerHideWhileScrolling:NO];
	[[CHPDaemonList sharedInstance] addObserver:self];

	if(![CHPDaemonList sharedInstance].loaded)
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
		{
			[[CHPDaemonList sharedInstance] updateDaemonListIfNeeded];
		});
	}
	else
	{
		[self updateSuggestedDaemons];
	}

	[super viewDidLoad];
}

- (NSString*)topTitle
{
	return @"Daemons";
}

- (NSString*)plistName
{
	return nil;
}

- (NSMutableArray*)specifiers
{
	NSMutableArray* specifiers = [self valueForKey:@"_specifiers"];

	if(!specifiers)
	{
		specifiers = [NSMutableArray new];

        if (@available(iOS 11.0, *)){
        }else{
			[specifiers addObject:[PSSpecifier emptyGroupSpecifier]];
			[specifiers addObject:[PSSpecifier emptyGroupSpecifier]];
		}

		if(![CHPDaemonList sharedInstance].loaded)
		{
			PSSpecifier* loadingIndicator = [PSSpecifier preferenceSpecifierNamed:@""
							target:self
							set:nil
							get:nil
							detail:nil
							cell:[PSTableCell cellTypeFromString:@"PSSpinnerCell"]
							edit:nil];

			[specifiers addObject:loadingIndicator];
		}
		else
		{
            _showsAllDaemons = YES;

			NSArray<CHPDaemonInfo*>* daemonList = [CHPDaemonList sharedInstance].daemonList;

			for(CHPDaemonInfo* info in daemonList)
			{
				if(_showsAllDaemons || [_suggestedDaemons containsObject:[info displayName]])
				{
					if(_searchKey && ![_searchKey isEqualToString:@""])
					{
						if(![[info displayName] localizedStandardContainsString:_searchKey])
						{
							continue;
						}
					}
					
					PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:[info displayName]
								target:self
								set:nil
								get:@selector(previewStringForSpecifier:)
								detail:[VDTProcessConfiguration class]
								cell:PSLinkListCell
								edit:nil];
                    [specifier setProperty:@(VDTConfigTypeDaemon) forKey:@"configurationType"];

					[specifier setProperty:@YES forKey:@"enabled"];
					[specifier setProperty:[info displayName] forKey:@"daemonName"];
					[specifier setProperty:info forKey:@"daemonInfo"];

					[specifiers addObject:specifier];
				}
			}
		}

		[self setValue:specifiers forKey:@"_specifiers"];
	}

	return specifiers;
}

extern NSString* previewStringForSettings(NSDictionary* settings);

- (id)previewStringForSpecifier:(PSSpecifier*)specifier
{
    return [valueForProcessConfigKey([specifier propertyForKey:@"daemonName"], @"enabled", nil, VDTConfigTypeDaemon) boolValue] ? @"Enabled" : @"";
}

- (void)reloadValueOfSelectedSpecifier
{
	UITableView* tableView = [self valueForKey:@"_table"];
	for(NSIndexPath* selectedIndexPath in tableView.indexPathsForSelectedRows)
	{
		PSSpecifier* specifier = [self specifierAtIndex:[self indexForIndexPath:selectedIndexPath]];
		[self reloadSpecifier:specifier];
	}
}

- (void)updateSuggestedDaemons
{
	NSMutableSet* suggestedDaemons = [NSMutableSet new];

	for(CHPDaemonInfo* info in [CHPDaemonList sharedInstance].daemonList)
	{
		if([info.linkedFrameworkIdentifiers containsObject:@"com.apple.UIKit"])
		{
			[suggestedDaemons addObject:[info displayName]];
		}
	}

	_suggestedDaemons = [suggestedDaemons copy];
}

- (void)daemonListDidUpdate:(CHPDaemonList*)list
{
	[self updateSuggestedDaemons];
	[self reloadSpecifiers];
}

- (id)controllerForSpecifier:(PSSpecifier*)specifier
{
    if (@available(iOS 11.0, *)){
    }else{
		[UIView performWithoutAnimation:^
		{
			_searchController.active = NO;
		}];
	}

	return [super controllerForSpecifier:specifier];
}

@end
