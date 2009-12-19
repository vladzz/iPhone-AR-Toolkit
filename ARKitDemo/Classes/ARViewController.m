//
//  ARKViewController.m
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#import "ARViewController.h"
#import <QuartzCore/QuartzCore.h>

#define VIEWPORT_WIDTH_RADIANS 0.5
#define VIEWPORT_HEIGHT_RADIANS 0.7392

@implementation ARViewController

@synthesize locationManager;
@synthesize accelerometerManager;
@synthesize centerCoordinate;
@synthesize scaleViewsBasedOnDistance;
@synthesize rotateViewsBasedOnPerspective;
@synthesize maximumScaleDistance;
@synthesize minimumScaleFactor;
@synthesize maximumRotationAngle;
@synthesize updateFrequency;
@synthesize debugMode	= ar_debugMode;
@synthesize coordinates = ar_coordinates;
@synthesize delegate;
@synthesize locationDelegate;
@synthesize accelerometerDelegate;
@synthesize cameraController;

- (id)init {
	
	if (!(self = [super init]))
		return nil;
	
	ar_debugView	= nil;
	ar_overlayView	= nil;
	ar_debugMode	= NO;
	
	ar_coordinates		= [[NSMutableArray alloc] init];
	ar_coordinateViews	= [[NSMutableArray alloc] init];
	
	_updateTimer			= nil;
	self.updateFrequency	= 1 / 20.0;
	
#if !TARGET_IPHONE_SIMULATOR
	
	[self setCameraController: [[[UIImagePickerController alloc] init] autorelease]];
	[[self cameraController] setSourceType: UIImagePickerControllerSourceTypeCamera];
	[[self cameraController] setCameraViewTransform: CGAffineTransformScale([[self cameraController] cameraViewTransform], 1.13f,  1.13f)];
	
	[[self cameraController] setShowsCameraControls:NO];
	[[self cameraController] setNavigationBarHidden:YES];
#endif

	[self setScaleViewsBasedOnDistance: NO];
	[self setMaximumScaleDistance: 0.0];
	[self setMinimumScaleFactor: 1.0];
	[self setRotateViewsBasedOnPerspective: NO];
	[self setMaximumRotationAngle: M_PI / 6.0];
	[self setWantsFullScreenLayout: YES];
	
	return self;
}

- (id)initWithLocationManager:(CLLocationManager *)manager {
	
	if (!(self = [super init])) 
		return nil;
	
	[self setLocationManager:manager];
	[[self locationManager] setDelegate:self];
	[self setLocationDelegate:nil];
	
	return self;
}

- (void)loadView {

	[ar_overlayView release];
	ar_overlayView = [[UIView alloc] initWithFrame:CGRectZero];
	[ar_debugView release];
	
	if ([self debugMode]) {
		ar_debugView = [[UILabel alloc] initWithFrame:CGRectZero];
		[ar_debugView setTextAlignment: UITextAlignmentCenter];
		[ar_debugView setText: @"Waiting..."];
		[ar_overlayView addSubview:ar_debugView];
	}
		
	[self setView:ar_overlayView];
}

- (void)viewDidAppear:(BOOL)animated {

#if !TARGET_IPHONE_SIMULATOR
	[[self cameraController] setCameraOverlayView:ar_overlayView];
	[self presentModalViewController:[self cameraController] animated:NO];
	[ar_overlayView setFrame:[[[self cameraController] view] bounds]];
#endif
	
	if (!_updateTimer) 
		_updateTimer = [[NSTimer scheduledTimerWithTimeInterval:[self updateFrequency] target:self selector:@selector(updateLocations:) userInfo:nil repeats:YES] retain];
	
	[super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([self debugMode]) {
		[ar_debugView sizeToFit];
		[ar_debugView setFrame:CGRectMake(0, [ar_overlayView frame].size.height - [ar_debugView frame].size.height,  [ar_overlayView frame].size.width, [ar_debugView frame].size.height)];
	}
}

- (void)setUpdateFrequency:(double)newUpdateFrequency {
	
	updateFrequency = newUpdateFrequency;
	
	if (!_updateTimer) 
		return;
	
	[_updateTimer invalidate];
	[_updateTimer release];
	
	_updateTimer = [[NSTimer scheduledTimerWithTimeInterval:self.updateFrequency  target:self selector:@selector(updateLocations:)  userInfo:nil repeats:YES] retain];
}

- (void)setDebugMode:(BOOL)flag {
	
	if ([self debugMode] == flag) 
		return;
	
	ar_debugMode = flag;
	
	//we don't need to update the view.
	if (![self isViewLoaded]) 
		return;
	
	if ([self debugMode]) 
		[ar_overlayView addSubview:ar_debugView];
	else 
		[ar_debugView removeFromSuperview];
}

- (BOOL)viewportContainsCoordinate:(ARCoordinate *)coordinate {
	
	double centerAzimuth	= [[self centerCoordinate] azimuth];
	double leftAzimuth		= centerAzimuth - VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (leftAzimuth < 0.0) 
		leftAzimuth = 2 * M_PI + leftAzimuth;
	
	double rightAzimuth = centerAzimuth + VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (rightAzimuth > 2 * M_PI)
		rightAzimuth = rightAzimuth - 2 * M_PI;
	
	BOOL result = ([coordinate azimuth] > leftAzimuth && [coordinate azimuth] < rightAzimuth);
	
	if(leftAzimuth > rightAzimuth) 
		result = ([coordinate azimuth] < rightAzimuth || [coordinate azimuth] > leftAzimuth);
	
	double centerInclination	= [[self centerCoordinate] inclination];
	double bottomInclination	= centerInclination - VIEWPORT_HEIGHT_RADIANS / 2.0;
	double topInclination		= centerInclination + VIEWPORT_HEIGHT_RADIANS / 2.0;
	
	//check the height.
	result = result && ([coordinate inclination] > bottomInclination && [coordinate inclination] < topInclination);
	
	//NSLog(@"coordinate: %@ result: %@", coordinate, result?@"YES":@"NO");
	
	return result;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)startListening {
	
	//start our heading readings and our accelerometer readings.
	
	if (![self locationManager]) {
		[self setLocationManager: [[[CLLocationManager alloc] init] autorelease]];
		
		//we want every move.
		[[self locationManager] setHeadingFilter: kCLHeadingFilterNone];
		[[self locationManager] setDesiredAccuracy: kCLLocationAccuracyBest];
		[[self locationManager] startUpdatingHeading];
	}
	
	[[self locationManager] setDelegate: self];
	
	if (![self accelerometerManager]) {
		[self setAccelerometerManager: [UIAccelerometer sharedAccelerometer]];
		[[self accelerometerManager] setUpdateInterval: 0.01];
		[[self accelerometerManager] setDelegate: self];
	}
	
	if (![self centerCoordinate]) 
		[self setCenterCoordinate:[ARCoordinate coordinateWithRadialDistance:0 inclination:0 azimuth:0]];
}

- (CGPoint)pointInView:(UIView *)realityView forCoordinate:(ARCoordinate *)coordinate {
	
	CGPoint point;
	
	//x coordinate.
	double pointAzimuth = [coordinate azimuth];
	
	//our x numbers are left based.
	double leftAzimuth = [[self centerCoordinate] azimuth] - VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (leftAzimuth < 0.0) 
		leftAzimuth = 2 * M_PI + leftAzimuth;
	
	//it's past the 0 point.
	if (pointAzimuth < leftAzimuth) 
		point.x = ((2 * M_PI - leftAzimuth + pointAzimuth) / VIEWPORT_WIDTH_RADIANS) * [realityView frame].size.width;
	else 
		point.x = ((pointAzimuth - leftAzimuth) / VIEWPORT_WIDTH_RADIANS) * [realityView frame].size.width;
	
	//y coordinate.
	double pointInclination = [coordinate inclination];
	double topInclination	= [[self centerCoordinate] inclination] - VIEWPORT_HEIGHT_RADIANS / 2.0;
	
	point.y = [realityView frame].size.height - ((pointInclination - topInclination) / VIEWPORT_HEIGHT_RADIANS) * [realityView frame].size.height;
	
	return point;
}

#define kFilteringFactor 0.05
UIAccelerationValue rollingX, rollingZ;

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	// -1 face down. // 1 face up.
	//update the center coordinate.
	//NSLog(@"x: %f y: %f z: %f", acceleration.x, acceleration.y, acceleration.z);
	//this should be different based on orientation.
	
	rollingZ	= (acceleration.z * kFilteringFactor) + (rollingZ * (1.0 - kFilteringFactor));
    rollingX	= (acceleration.y * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
	
	if (rollingZ > 0.0) 
		[[self centerCoordinate] setInclination: atan(rollingX / rollingZ) + M_PI / 2.0];
	else if (rollingZ < 0.0) 
		[[self centerCoordinate] setInclination: atan(rollingX / rollingZ) - M_PI / 2.0];// + M_PI];
	else if (rollingX < 0) 
		 [[self centerCoordinate] setInclination: M_PI/2.0];
	else if (rollingX >= 0) 
		 [[self centerCoordinate] setInclination: 3 * M_PI/2.0];

	//forward the acceleromter.
	if ([self accelerometerDelegate] && [[self accelerometerDelegate] respondsToSelector:@selector(accelerometer:didAccelerate:)]) 
		[[self accelerometerDelegate] accelerometer:accelerometer didAccelerate:acceleration];
}

NSComparisonResult LocationSortClosestFirst(ARCoordinate *s1, ARCoordinate *s2, void *ignore) {
    
	if ([s1 radialDistance] < [s2 radialDistance]) 
		return NSOrderedAscending;
	else if ([s1 radialDistance] > [s2 radialDistance]) 
		return NSOrderedDescending;
	else 
		return NSOrderedSame;
}

- (void)addCoordinate:(ARCoordinate *)coordinate {
	[self addCoordinate:coordinate animated:YES];
}

- (void)addCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated {
	
	//do some kind of animation?
	[ar_coordinates addObject:coordinate];
		
	if ([coordinate radialDistance] > [self maximumScaleDistance]) 
		[self setMaximumScaleDistance: [coordinate radialDistance]];
	
	//message the delegate.
	[ar_coordinateViews addObject:[[self delegate] viewForCoordinate:coordinate]];
}

- (void)addCoordinates:(NSArray *)newCoordinates {
	
	//go through and add each coordinate.
	for (ARCoordinate *coordinate in newCoordinates) {
		[self addCoordinate:coordinate animated:NO];
	}
}

- (void)removeCoordinate:(ARCoordinate *)coordinate {
	[self removeCoordinate:coordinate animated:YES];
}

- (void)removeCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated {
	//do some kind of animation?
	[ar_coordinates removeObject:coordinate];
}

- (void)removeCoordinates:(NSArray *)coordinates {	
	
	for (ARCoordinate *coordinateToRemove in coordinates) {
		NSUInteger indexToRemove = [ar_coordinates indexOfObject:coordinateToRemove];
		
		//TODO: Error checking in here.
		[ar_coordinates		removeObjectAtIndex:indexToRemove];
		[ar_coordinateViews removeObjectAtIndex:indexToRemove];
	}
}

- (void)updateLocations:(NSTimer *)timer {

	//update locations!
	if (!ar_coordinateViews || ar_coordinateViews.count == 0) 
		return;
	
	[ar_debugView setText: [[self centerCoordinate] description]];
	
	int index = 0;
	for (ARCoordinate *item in ar_coordinates) {
		
		UIView *viewToDraw = [ar_coordinateViews objectAtIndex:index];
		
		if ([self viewportContainsCoordinate:item]) {
			
			CGPoint loc			= [self pointInView:ar_overlayView forCoordinate:item];
			CGFloat scaleFactor = 1.0;
			
			if (self.scaleViewsBasedOnDistance) 
				scaleFactor = 1.0 - self.minimumScaleFactor * (item.radialDistance / self.maximumScaleDistance);
			
			float width		= [viewToDraw bounds].size.width  * scaleFactor;
			float height	= [viewToDraw bounds].size.height * scaleFactor;
			
			[viewToDraw setFrame:CGRectMake(loc.x - width / 2.0, loc.y - height / 2.0, width, height)];
						
			CATransform3D transform = CATransform3DIdentity;
			
			//set the scale if it needs it.
			//scale the perspective transform if we have one.
			if ([self scaleViewsBasedOnDistance]) 
				transform = CATransform3DScale(transform, scaleFactor, scaleFactor, scaleFactor);
			
			if ([self rotateViewsBasedOnPerspective]) {
				transform.m34 = 1.0 / 300.0;
				
				double itemAzimuth		= [item azimuth];
				double centerAzimuth	= [[self centerCoordinate] azimuth];
				
				if (itemAzimuth - centerAzimuth > M_PI) 
					centerAzimuth += 2 * M_PI;
				
				if (itemAzimuth - centerAzimuth < -M_PI) 
					itemAzimuth  += 2 * M_PI;
				
				double angleDifference	= itemAzimuth - centerAzimuth;
				transform				= CATransform3DRotate(transform, [self maximumRotationAngle] * angleDifference / (VIEWPORT_HEIGHT_RADIANS / 2.0) , 0, 1, 0);
			}
			
			[[viewToDraw layer] setTransform:transform];
			
			//if we don't have a superview, set it up.
			if (!([viewToDraw superview])) {
				[ar_overlayView addSubview:viewToDraw];
				[ar_overlayView sendSubviewToBack:viewToDraw];
			}
		} 
		else {
			[viewToDraw removeFromSuperview];
			[viewToDraw setTransform: CGAffineTransformIdentity];
		}
		
		index++;
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
		
	[[self centerCoordinate] setAzimuth: fmod(newHeading.magneticHeading, 360.0) * (2 * (M_PI / 360.0))];
	
	//forward the call.
	if ([self locationDelegate] && [[self locationDelegate] respondsToSelector:@selector(locationManager:didUpdateHeading:)]) 
		[[self locationDelegate] locationManager:manager didUpdateHeading:newHeading];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	
	//forward the call.
	if ([self locationDelegate] && [[self locationDelegate] respondsToSelector:@selector(locationManagerShouldDisplayHeadingCalibration:)]) 
		return [[self locationDelegate] locationManagerShouldDisplayHeadingCalibration:manager];
	
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	//forward the call.
	if ([self locationDelegate] && [[self locationDelegate] respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) 
		[[self locationDelegate] locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
	//forward the call.
	if ([self locationDelegate] && [[self locationDelegate] respondsToSelector:@selector(locationManager:didFailWithError:)]) 
		return [[self locationDelegate] locationManager:manager didFailWithError:error];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[ar_overlayView release];
	ar_overlayView = nil;
}

- (void)dealloc {
	[ar_debugView release];
	[ar_coordinateViews release];
	[ar_coordinates release];
    [super dealloc];
}

@end
