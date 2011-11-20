//
//  ARViewController.m
//  ARKitDemo
//
//  Created by Niels W Hansen on 1/23/10.
//  Copyright 2011 Agilite Software. All rights reserved.
//

#import "ARViewController.h"
#import "AugmentedRealityController.h"
#import "GEOLocations.h"
#import "CoordinateView.h"

@implementation ARViewController

@synthesize agController;
@synthesize delegate;

-(id)initWithDelegate:(id<ARLocationDelegate>) aDelegate {
	
	[self setDelegate:aDelegate];
	
	if (!(self = [super init]))
		return nil;
	
	[self setWantsFullScreenLayout: YES];
    
 	return self;
}

- (void)loadView {
    
	AugmentedRealityController*  arc = [[AugmentedRealityController alloc] initWithViewController:self];
	
	[arc setDebugMode:YES];
	[arc setScaleViewsBasedOnDistance:YES];
	[arc setMinimumScaleFactor:0.5];
	[arc setRotateViewsBasedOnPerspective:YES];
    [arc updateDebugMode:![arc debugMode]];
	
	GEOLocations* locations = [[GEOLocations alloc] initWithDelegate:delegate];
	
	if ([[locations returnLocations] count] > 0) {
		for (ARGeoCoordinate *coordinate in [locations returnLocations]) {
			CoordinateView *cv = [[CoordinateView alloc] initForCoordinate:coordinate withDelgate:self] ;
			[arc addCoordinate:coordinate augmentedView:cv animated:NO];
			[cv release];
		}
	}
    
    [self setAgController:arc];
    [arc release];
	[locations release];
    
   
}



- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

-(void) locationClicked:(ARGeoCoordinate *) coordinate {
    NSLog(@"delegate worked click on %@", [coordinate title]);
    [delegate locationClicked:coordinate];
    
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [agController release];
	agController = nil;
}

- (void)dealloc {
    [super dealloc];
}


@end
