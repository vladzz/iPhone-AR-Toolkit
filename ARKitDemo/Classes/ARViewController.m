//
//  ARKViewController.m
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
//  Updated by Niels Hansen on 12/19/09
//  Copyright 2009 Agilite Software. All rights reserved.
//

#import "ARViewController.h"
#import "AugmentedReality.h"
#import "GEOLocations.h"
#import <QuartzCore/QuartzCore.h>

#define degreesToRadian(x) (M_PI * (x) / 180.0)

@implementation ARViewController

@synthesize cameraController;
@synthesize agController;

- (id)init {
		
	if (!(self = [super init]))
		return nil;

#if !TARGET_IPHONE_SIMULATOR
	[self setCameraController: [[[UIImagePickerController alloc] init] autorelease]];
	[[self cameraController] setSourceType: UIImagePickerControllerSourceTypeCamera];
	[[self cameraController] setCameraViewTransform: CGAffineTransformScale([[self cameraController] cameraViewTransform], 1.13f,  1.13f)];
	[[self cameraController] setShowsCameraControls:NO];
	[[self cameraController] setNavigationBarHidden:YES];
#endif

	[self setWantsFullScreenLayout: YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

	return self;
}

- (void)loadView {

	[self setAgController:[[AugmentedReality alloc] initWithViewController:self]];
	
	[agController setDebugMode:YES];
	[agController setScaleViewsBasedOnDistance:YES];
	[agController setMinimumScaleFactor:0.5];
	[agController setRotateViewsBasedOnPerspective:YES];
	
	GEOLocations* locations = [[GEOLocations alloc] init];
	
	[agController addCoordinates:[locations getLocations]];
	[locations release];
}

- (void)viewDidAppear:(BOOL)animated {
		
#if !TARGET_IPHONE_SIMULATOR
	[[self cameraController] setCameraOverlayView:[self view]];
	[self presentModalViewController:[self cameraController] animated:NO];
	[[self view] setFrame:[[[self cameraController] view] bounds]];
#endif

	[super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

	CGAffineTransform transform = CGAffineTransformMakeRotation(degreesToRadian(0));
	CGRect bounds = CGRectMake(0, 0, 320, 480);
	
	if (orientation == UIDeviceOrientationLandscapeLeft) {
		transform	= CGAffineTransformMakeRotation(degreesToRadian(90));
		bounds		= CGRectMake(0, 0, 480, 320);
	}
	else if (orientation == UIDeviceOrientationLandscapeRight) {
		transform	= CGAffineTransformMakeRotation(degreesToRadian(-90));
		bounds		= CGRectMake(0, 0, 480, 320);
	}
	else if (orientation == UIDeviceOrientationPortraitUpsideDown)
		transform = CGAffineTransformMakeRotation(degreesToRadian(180));
	
	[[self view] setTransform:CGAffineTransformIdentity];
	[[self view] setTransform: transform];
	[[self view] setBounds:bounds];
	[[self view] setFrame:bounds];
	
//	[[self agController] updateLocations];

}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [super dealloc];
}


@end
