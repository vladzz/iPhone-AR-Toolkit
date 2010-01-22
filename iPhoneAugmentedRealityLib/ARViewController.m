//
//  ARKViewController.m
//  iPhoneAugmentedRealityLib
//
//  Created by Zac White on 8/1/09.
//  Updated by Niels Hansen on 12/19/09
//  Copyright 2009 Agilite Software. All rights reserved.
// 

#import "ARViewController.h"
#import "AugmentedRealityController.h"
#import "GEOLocations.h"
#import "CoordinateView.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#define degreesToRadian(x) (M_PI * (x) / 180.0)

@implementation ARViewController

@synthesize cameraController;
@synthesize agController;

- (id)init {
		
	if (!(self = [super init]))
		return nil;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];	
	
#if !TARGET_IPHONE_SIMULATOR
	[self setCameraController: [[[UIImagePickerController alloc] init] autorelease]];
	[[self cameraController] setSourceType: UIImagePickerControllerSourceTypeCamera];
	[[self cameraController] setCameraViewTransform: CGAffineTransformScale([[self cameraController] cameraViewTransform], 1.13f,  1.13f)];
	[[self cameraController] setShowsCameraControls:NO];
	[[self cameraController] setNavigationBarHidden:YES];
#endif

	[self setWantsFullScreenLayout: YES];

	return self;
}

- (void)loadView {

	[self setAgController:[[AugmentedRealityController alloc] initWithViewController:self]];
	
	[agController setDebugMode:YES];
	[agController setScaleViewsBasedOnDistance:YES];
	[agController setMinimumScaleFactor:0.5];
	[agController setRotateViewsBasedOnPerspective:YES];
	
	GEOLocations* locations = [[GEOLocations alloc] init];
	
	if ([[locations getLocations] count] > 0) {
		for (ARCoordinate *coordinate in [locations getLocations]) {
			CoordinateView *cv = [[CoordinateView alloc] initForCoordinate:coordinate];
			[agController addCoordinate:coordinate augmentedView:cv animated:NO];
			[cv release];
		}
	}
	
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

	// Later we may handle the Orientation of Faceup to show a Map.  For now let's ignore it.
	if (orientation != UIDeviceOrientationUnknown && orientation != UIDeviceOrientationFaceUp && orientation != UIDeviceOrientationFaceDown) {
		
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
		
		[[self agController] setDebugMode:YES];
		
	}
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
