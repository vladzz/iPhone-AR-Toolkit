//
//  ARKitDemoAppDelegate.m
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
//  Copyright Zac White 2009. All rights reserved.
//

#import "ARKitDemoAppDelegate.h"
#import "ARGeoCoordinate.h"
#import "GEOLocations.h"

@implementation ARKitDemoAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	
	ARViewController *viewController = [[ARViewController alloc] init];
	[window addSubview:[viewController view]];
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
}

- (void)dealloc {
	
	//NEW COMMENT!
    [window release];
    [super dealloc];
}


@end
