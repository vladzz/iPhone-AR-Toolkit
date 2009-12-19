//
//  ARKViewController.h
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ARCoordinate.h"

@protocol ARViewDelegate

- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate;

@end

@interface ARViewController : UIViewController <UIAccelerometerDelegate, CLLocationManagerDelegate> {

	CLLocationManager	*locationManager;
	UIAccelerometer		*accelerometerManager;
	ARCoordinate		*centerCoordinate;
	
	UIImagePickerController *cameraController;
	
	NSObject<ARViewDelegate>			*delegate;
	NSObject<CLLocationManagerDelegate> *locationDelegate;
	NSObject<UIAccelerometerDelegate>	*accelerometerDelegate;
	
	BOOL scaleViewsBasedOnDistance;
	BOOL rotateViewsBasedOnPerspective;

	double maximumScaleDistance;
	double minimumScaleFactor;
	double updateFrequency; 	//defaults to 20hz;
	double maximumRotationAngle;
	
@private
	BOOL			ar_debugMode;
	
	NSTimer			*_updateTimer;
	UIView			*ar_overlayView;
	UILabel			*ar_debugView;
	NSMutableArray	*ar_coordinates;
	NSMutableArray	*ar_coordinateViews;
}

@property (readonly) NSArray *coordinates;

@property BOOL debugMode;
@property BOOL scaleViewsBasedOnDistance;
@property BOOL rotateViewsBasedOnPerspective;

@property double maximumScaleDistance;
@property double minimumScaleFactor;
@property double maximumRotationAngle;
@property double updateFrequency;

@property (nonatomic, retain) UIImagePickerController *cameraController;
@property (nonatomic, assign) NSObject<ARViewDelegate> *delegate;
@property (nonatomic, assign) NSObject<CLLocationManagerDelegate> *locationDelegate;
@property (nonatomic, assign) NSObject<UIAccelerometerDelegate> *accelerometerDelegate;
@property (nonatomic, retain) UIAccelerometer *accelerometerManager;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (retain) ARCoordinate *centerCoordinate;

//adding coordinates to the underlying data model.
- (void)addCoordinate:(ARCoordinate *)coordinate;
- (void)addCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated;
- (void)addCoordinates:(NSArray *)newCoordinates;

//removing coordinates
- (void)removeCoordinate:(ARCoordinate *)coordinate;
- (void)removeCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated;
- (void)removeCoordinates:(NSArray *)coordinates;

- (id)initWithLocationManager:(CLLocationManager *)manager;

- (void)startListening;
- (void)updateLocations:(NSTimer *)timer;
- (CGPoint)pointInView:(UIView *)realityView forCoordinate:(ARCoordinate *)coordinate;
- (BOOL)viewportContainsCoordinate:(ARCoordinate *)coordinate;

@end
