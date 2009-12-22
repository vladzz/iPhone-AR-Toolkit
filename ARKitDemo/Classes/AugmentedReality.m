//
//  AugmentedReality.m
//  ARKit
//
//  Created by Niels W Hansen on 12/20/09.
//  Copyright 2009 Agilite Software. All rights reserved.
//

#import "AugmentedReality.h"
#import "ARCoordinate.h"
#import "ARGeoCoordinate.h"
#import "CoordinateView.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#define kFilteringFactor 0.05
#define degreesToRadian(x) (M_PI * (x) / 180.0)

@interface AugmentedReality (Private)
- (void) UpdateCenterCoordinate;
- (void) startListening;

- (double) HeightInRadiansForView:(UIView *)viewToDraw;
- (double) findDeltaOfRadianCenter:(double*)centerAzimuth coordinateAzimuth:(double)pointAzimuth;
@end

@implementation AugmentedReality

@synthesize locationManager;
@synthesize accelerometerManager;
@synthesize displayView;
@synthesize centerCoordinate;
@synthesize scaleViewsBasedOnDistance;
@synthesize rotateViewsBasedOnPerspective;
@synthesize maximumScaleDistance;
@synthesize minimumScaleFactor;
@synthesize maximumRotationAngle;
@synthesize centerLocation;
@synthesize coordinates = ar_coordinates;
@synthesize debugMode;

- (id)initWithViewController:(UIViewController *)vc {
	
	ar_coordinates		= [[NSMutableArray alloc] init];
	ar_coordinateViews	= [[NSMutableArray alloc] init];
	
	_latestHeading		 = -1.0f;
	_latestXAcceleration = -1.0f;
	_latestYAcceleration = -1.0f;
	_latestZAcceleration = -1.0f;
	
	viewPortHeightRadians = 0.7392f;
	
	[self setDebugMode:NO];
	
	ar_debugView	= nil;
	
	[self setMaximumScaleDistance: 0.0];
	[self setMinimumScaleFactor: 1.0];
	[self setScaleViewsBasedOnDistance: NO];
	[self setRotateViewsBasedOnPerspective: NO];
	[self setMaximumRotationAngle: M_PI / 6.0];
	
	[self setDisplayView: [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 480) ]];
	
	[vc setView:displayView];
	
	return self;
}

- (void)startListening {
	
	//start our heading readings and our accelerometer readings.
	
	if (![self locationManager]) {
		[self setLocationManager: [[CLLocationManager alloc] init]];
		
		[[self locationManager] setHeadingFilter: kCLHeadingFilterNone];
		[[self locationManager] setDesiredAccuracy: kCLLocationAccuracyBest];
		[[self locationManager] startUpdatingHeading];
		[[self locationManager] startUpdatingLocation];
		[[self locationManager] setDelegate: self];
	}
			
	if (![self accelerometerManager]) {
		[self setAccelerometerManager: [UIAccelerometer sharedAccelerometer]];
		[[self accelerometerManager] setUpdateInterval: 0.15];
		[[self accelerometerManager] setDelegate: self];
	}
	
	if (![self centerCoordinate]) 
		[self setCenterCoordinate:[ARCoordinate coordinateWithRadialDistance:1.0 inclination:0 azimuth:0]];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	
	_latestHeading = fmod(newHeading.magneticHeading, 360.0) * (2 * (M_PI / 360.0));
	[self UpdateCenterCoordinate];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if (oldLocation == nil)
		[self setCenterLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
}

-(void) setupDebugPostion {
	
	if ([self debugMode]) {
		[ar_debugView sizeToFit];
		CGRect displayRect = [[self displayView] frame];
		
		[ar_debugView setFrame:CGRectMake(0, displayRect.size.height - [ar_debugView frame].size.height,  displayRect.size.width, [ar_debugView frame].size.height)];
	}
}

- (void)UpdateCenterCoordinate {
	
	UIAccelerationValue downAcceleration = _latestXAcceleration + _latestYAcceleration;
	[[self centerCoordinate] setAzimuth: (1.0 - ABS(_latestYAcceleration)) * M_PI_2 + _latestHeading ];
	
	if (_latestZAcceleration > 0.0) 
		[[self centerCoordinate] setInclination: atan(downAcceleration / _latestZAcceleration) + M_PI_2 ];
	else if (_latestZAcceleration < 0.0) 
		[[self centerCoordinate] setInclination: atan(downAcceleration / _latestZAcceleration) - M_PI_2 ];// + M_PI;
	else if (downAcceleration < 0) 
		[[self centerCoordinate] setInclination: M_PI_2 ];
	else if (downAcceleration >= 0) 
		[[self centerCoordinate] setInclination: 3 * M_PI_2 ];
	
	_viewportRotation = atan(_latestXAcceleration / _latestYAcceleration);
	
	if (_latestXAcceleration > 0.0) 
		_viewportRotation = ABS(_viewportRotation);
	else 
		_viewportRotation = -ABS(_viewportRotation);
	
	[self updateLocations];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	_latestZAcceleration  = (acceleration.z * kFilteringFactor) + (_latestZAcceleration * (1.0 - kFilteringFactor));
	_latestYAcceleration  = (acceleration.y * kFilteringFactor) + (_latestYAcceleration * (1.0 - kFilteringFactor));
	_latestXAcceleration  = (acceleration.x * kFilteringFactor) + (_latestXAcceleration * (1.0 - kFilteringFactor));
	
	[self UpdateCenterCoordinate];
}

- (void)setCenterLocation:(CLLocation *)newLocation {
	[centerLocation release];
	centerLocation = [newLocation retain];
	
	for (ARGeoCoordinate *geoLocation in [self coordinates]) {
		
		if ([geoLocation isKindOfClass:[ARGeoCoordinate class]]) {
			[geoLocation calibrateUsingOrigin:centerLocation];
			
			if ([geoLocation radialDistance] > [self maximumScaleDistance]) 
				[self setMaximumScaleDistance:[geoLocation radialDistance]];
		}
	}
}

- (void)addCoordinate:(ARCoordinate *)coordinate {
	[self addCoordinate:coordinate animated:YES];
}

- (void)addCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated {
	
	//do some kind of animation?
	[ar_coordinates addObject:coordinate];
	
	if ([coordinate radialDistance] > [self maximumScaleDistance]) 
		[self setMaximumScaleDistance: [coordinate radialDistance]];
	
	CoordinateView *cv = [[CoordinateView alloc] initForCoordinate:coordinate];
	[ar_coordinateViews addObject:cv];
	[cv release];
}

- (void)addCoordinates:(NSArray *)newCoordinates {
	
	//go through and add each coordinate.
	for (ARCoordinate *coordinate in newCoordinates) {
		[self addCoordinate:coordinate animated:NO];
	}
	
	CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:37.41711 longitude:-122.02528];
	
	[self setCenterLocation: newCenter];
	[newCenter release];

	[self startListening];
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

-(double) findDeltaOfRadianCenter:(double*)centerAzimuth coordinateAzimuth:(double)pointAzimuth degree:(double) degreeRange {

	if (*centerAzimuth < 0.0) 
		*centerAzimuth = (M_PI * 2) + *centerAzimuth;
	
	if (*centerAzimuth > (M_PI * 2)) 
		*centerAzimuth = *centerAzimuth - (M_PI * 2);
	
	double deltaAzimith = ABS(pointAzimuth - *centerAzimuth);
	
	
	// If values are on either side of the Azimuth of North we need to adjust it.  Only check the degree range
	if (*centerAzimuth < degreesToRadian(degreeRange) && pointAzimuth > degreesToRadian(360-degreeRange))
		deltaAzimith = (*centerAzimuth + ((M_PI * 2) - pointAzimuth));
	else if (pointAzimuth < degreesToRadian(degreeRange) && *centerAzimuth > degreesToRadian(360-degreeRange))
		deltaAzimith = (pointAzimuth + ((M_PI * 2) - *centerAzimuth));
	
	return deltaAzimith;
}

- (BOOL)viewportContainsView:(UIView *)viewToDraw  forCoordinate:(ARCoordinate *)coordinate {
	
	double degreeRange		= 25.0;
	double currentAzimuth	= [[self centerCoordinate] azimuth];
	double pointAzimuth		= [coordinate azimuth];
	double deltaAzimith		= [self findDeltaOfRadianCenter: &currentAzimuth coordinateAzimuth:pointAzimuth degree:degreeRange];

	BOOL result = NO;
	if (deltaAzimith <= degreesToRadian(degreeRange))
		result = YES;
	
	double viewHeightRadians = viewPortHeightRadians / ([[self displayView] bounds].size.height / [viewToDraw bounds].size.height);
	double centerInclination = [[self centerCoordinate] inclination];
	double bottomInclination = centerInclination - viewPortHeightRadians / 2.0 - viewHeightRadians;
	double topInclination	 = centerInclination + viewPortHeightRadians / 2.0 + viewHeightRadians;
	
	//check the height.
	result = result && ([coordinate inclination] > bottomInclination && [coordinate inclination] < topInclination);
	
	return result;
}

- (void)updateLocations {
	
	//update locations!
	if (!ar_coordinateViews || [ar_coordinateViews count] == 0) 
		return;
	
	[ar_debugView setText: [NSString stringWithFormat:@"%.4f %.4f %.4f", _latestXAcceleration, _latestYAcceleration, _viewportRotation]];
	
	int index			= 0;
	int totalDisplayed	= 0;
	
	for (ARCoordinate *item in ar_coordinates) {
		
		UIView *viewToDraw = [ar_coordinateViews objectAtIndex:index];
		
		if ([self viewportContainsView:viewToDraw forCoordinate:item]) {
			
			CGPoint loc = [self pointInView:[self displayView] withView:viewToDraw forCoordinate:item];
			CGFloat scaleFactor = 1.0;
		// Remove this for now because it was actually causing it to go to zero.  Need to retain the orginal size!
			
		//	if ([self scaleViewsBasedOnDistance]) 
		//		scaleFactor = 1.0 - [self minimumScaleFactor] * ([item radialDistance] / [self maximumScaleDistance]);
			
			float width	 = [viewToDraw bounds].size.width  * scaleFactor;
			float height = [viewToDraw bounds].size.height * scaleFactor;
			
			[viewToDraw setFrame:CGRectMake(loc.x - width / 2.0, loc.y - (height / 2.0), width, height)];
		//	[viewToDraw setFrame:CGRectMake(loc.x - width / 2.0, 160.0, width, height)];

			
			totalDisplayed++;
			
			CATransform3D transform = CATransform3DIdentity;
			
			// Set the scale if it needs it. Scale the perspective transform if we have one.
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
				transform				= CATransform3DRotate(transform, [self maximumRotationAngle] * angleDifference / (viewPortHeightRadians / 2.0) , 0, 1, 0);
			}
			
			[[viewToDraw layer] setTransform:transform];
			
			//if we don't have a superview, set it up.
			if (!([viewToDraw superview])) {
				[[self displayView] addSubview:viewToDraw];
				[[self displayView] sendSubviewToBack:viewToDraw];
			}
		} 
		else 
			[viewToDraw removeFromSuperview];
		
		index++;
	}
}

- (CGPoint)pointInView:(UIView *)realityView withView:(UIView *)viewToDraw forCoordinate:(ARCoordinate *)coordinate {	
	
	CGPoint point;
	CGRect realityBounds	 = [realityView bounds];
	double currentAzimuth	 = [[self centerCoordinate] azimuth];
	double pointAzimuth		 = [coordinate azimuth];
	double degreeRange		 = 25.0;
	double deltaAzimith		 = [self findDeltaOfRadianCenter: &currentAzimuth coordinateAzimuth:pointAzimuth degree:degreeRange];
	double viewHeightRadians = [self HeightInRadiansForView:viewToDraw];
	
	if (pointAzimuth > currentAzimuth || (currentAzimuth > degreesToRadian(360-degreeRange) && pointAzimuth < degreesToRadian(degreeRange)))
		point.x = (realityBounds.size.width / 2) + ((deltaAzimith / degreesToRadian(1)) * 10);
	else
		point.x = (realityBounds.size.width / 2) - ((deltaAzimith / degreesToRadian(1)) * 10);	
	
	// y coordinate.
	double pointInclination = [coordinate inclination];
	double topInclination	= [[self centerCoordinate] inclination] - viewPortHeightRadians / 2.0 - viewHeightRadians;;
	
	point.y = realityBounds.size.height - ((pointInclination - topInclination) / viewPortHeightRadians) * realityBounds.size.height;
	
	return point;
}


-(NSComparisonResult) LocationSortClosestFirst:(ARCoordinate *) s1 secondCoord:(ARCoordinate*)s2 {
    
	if ([s1 radialDistance] < [s2 radialDistance]) 
		return NSOrderedAscending;
	else if ([s1 radialDistance] > [s2 radialDistance]) 
		return NSOrderedDescending;
	else 
		return NSOrderedSame;
}

- (void)setDebugMode:(BOOL)flag {
	
	if ([self debugMode] == flag) 
		return;
	
	debugMode = flag;
	
	if ([self debugMode]) {
		ar_debugView = [[UILabel alloc] initWithFrame:CGRectZero];
		[ar_debugView setTextAlignment: UITextAlignmentCenter];
		[ar_debugView setText: @"Waiting..."];
		[displayView addSubview:ar_debugView];
		[self setupDebugPostion];
	}
	else 
		[ar_debugView removeFromSuperview];
}


- (double)HeightInRadiansForView:(UIView *)viewToDraw {
	CGRect bounds = [viewToDraw bounds];
	return viewPortHeightRadians / ([[self displayView] bounds].size.height / bounds.size.height);
}

- (void)dealloc {
	[locationManager release];
	[ar_coordinateViews release];
	[ar_coordinates release];
	[ar_debugView release];
    [super dealloc];
}

@end
