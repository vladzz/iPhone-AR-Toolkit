//
//  AugmentedRealityController.h
//  iPhoneAugmentedRealityLib
//
//  Created by Niels W Hansen on 12/20/09.
//  Copyright 2009 Agilite Software All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@class ARCoordinate;

@interface AugmentedRealityController : NSObject <UIAccelerometerDelegate, CLLocationManagerDelegate> {

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
	UILabel				*debugView;

@private
	double				latestHeading;
	double				degreeRange;
	float				viewAngle;
	BOOL				debugMode;
	
	NSMutableArray		*coordinates;
	NSMutableArray		*coordinateViews;
}

@property BOOL scaleViewsBasedOnDistance;
@property BOOL rotateViewsBasedOnPerspective;
@property BOOL debugMode;

@property double maximumScaleDistance;
@property double minimumScaleFactor;
@property double maximumRotationAngle;
@property double degreeRange;

@property (nonatomic, retain) UIAccelerometer	*accelerometerManager;
@property (nonatomic, retain) CLLocationManager	*locationManager;
@property (nonatomic, retain) ARCoordinate		*centerCoordinate;
@property (nonatomic, retain) CLLocation		*centerLocation;
@property (nonatomic, retain) UIView			*displayView;
@property UIDeviceOrientation	currentOrientation;
@property (readonly) NSArray *coordinates;

- (id)initWithViewController:(UIViewController *)theView;


- (void) setupDebugPostion;
- (void) updateLocations;

// Adding coordinates to the underlying data model.
- (void)addCoordinate:(ARCoordinate *)coordinate augmentedView:(UIView *)agView animated:(BOOL)animated ;

// Removing coordinates
- (void)removeCoordinate:(ARCoordinate *)coordinate;
- (void)removeCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated;
- (void)removeCoordinates:(NSArray *)coordinateArray;

@end
