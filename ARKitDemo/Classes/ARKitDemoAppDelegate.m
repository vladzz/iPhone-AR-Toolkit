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

#import <MapKit/MapKit.h>

@implementation ARKitDemoAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	
	ARGeoViewController *viewController = [[ARGeoViewController alloc] init];
	[viewController setDebugMode:YES];
	[viewController setScaleViewsBasedOnDistance:YES];
	[viewController setMinimumScaleFactor:0.5];
	[viewController setRotateViewsBasedOnPerspective:YES];
	
	GEOLocations* locations = [[GEOLocations alloc] init];
	
	[viewController addCoordinates:[locations getLocations]];
	
	[locations release];
		
	CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:37.41711 longitude:-122.02528];
	
	viewController.centerLocation = newCenter;
	[newCenter release];
	[viewController startListening];
	[window addSubview:viewController.view];
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
}

- (void)dealloc {
	
	//NEW COMMENT!
    [window release];
    [super dealloc];
}


@end
