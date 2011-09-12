//
//  ARKitDemoAppDelegate.m
//  ARKitDemo using the iPhoneAugmentedRealityLib
//
//  Created by Niels Hansen on 1/21/2010.
//  Copyright Agilite Software 2011. All rights reserved.
//

#import "ARKitDemoAppDelegate.h"
#import "MainViewController.h"

@implementation ARKitDemoAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	
    MainViewController *vc = [[MainViewController alloc] init];
	[self setViewController:vc];
	
	[window addSubview:[viewController view]];
	[window makeKeyAndVisible];
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}





@end
