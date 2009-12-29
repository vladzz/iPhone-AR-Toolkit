//
//  AugmentedReality.h
//  ARKit
//
//  Created by Niels W Hansen on 12/20/09.
//  Copyright 2009 Agilite Software All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@class ARCoordinate;

@interface AugmentedReality : NSObject <UIAccelerometerDelegate, CLLocationManagerDelegate> {

	BOOL scaleViewsBasedOnDistance;
	BOOL rotateViewsBasedOnPerspective;
	
	double maximumScaleDistance;
	double minimumScaleFactor;
	double maximumRotationAngle;
	
	
	ARCoordinate		*centerCoordinate;
	CLLocationManager	*locationManager;
	UIDeviceOrientation currentOrientation;
	
	UIAccelerometer		*accelerometerManager;
	CLLocation			*centerLocation;
	UIView				*displayView;
	UILabel				*ar_debugView;

@private
	double				latestHeading;
	double				degreeRange;
	double				viewPortHeightRadians;
	float				viewAngle;

	NSMutableArray		*ar_coordinates;
	NSMutableArray		*ar_coordinateViews;
	
	BOOL   debugMode;

}

@property BOOL scaleViewsBasedOnDistance;
@property BOOL rotateViewsBasedOnPerspective;
@property BOOL debugMode;

@property double maximumScaleDistance;
@property double minimumScaleFactor;
@property double maximumRotationAngle;
@property double degreeRange;

@property (nonatomic, retain) UIAccelerometer		*accelerometerManager;
@property (nonatomic, retain) CLLocationManager		*locationManager;
@property (nonatomic, retain) ARCoordinate			*centerCoordinate;
@property (nonatomic, retain) CLLocation			*centerLocation;
@property (nonatomic, retain) UIView				*displayView;
@property UIDeviceOrientation	currentOrientation;

@property (readonly) NSArray *coordinates;

- (id)initWithViewController:(UIViewController *)theView;

- (CGPoint) pointInView:(UIView *)realityView withView:(UIView *)viewToDraw forCoordinate:(ARCoordinate *)coordinate;
- (BOOL) viewportContainsView:(UIView *)viewToDraw forCoordinate:(ARCoordinate *)coordinate;
- (void) setupDebugPostion;
- (void) updateLocations;

// Adding coordinates to the underlying data model.
- (void)addCoordinate:(ARCoordinate *)coordinate;
- (void)addCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated;
- (void)addCoordinates:(NSArray *)newCoordinates;

// Removing coordinates
- (void)removeCoordinate:(ARCoordinate *)coordinate;
- (void)removeCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated;
- (void)removeCoordinates:(NSArray *)coordinates;

@end
