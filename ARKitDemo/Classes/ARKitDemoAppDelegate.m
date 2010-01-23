//
//  ARKitDemoAppDelegate.m
//  ARKitDemo using the iPhoneAugmentedRealityLib
//
//  Created by Niels Hansen on 1/21/2010.
//  Copyright Agilite Software 2010. All rights reserved.
//

#import "ARKitDemoAppDelegate.h"
#import "ARDemoViewController.h"

@implementation ARKitDemoAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	
	ARDemoViewController *viewController = [[ARDemoViewController alloc] init];
	[window addSubview:[viewController view]];
	
    [window makeKeyAndVisible];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
