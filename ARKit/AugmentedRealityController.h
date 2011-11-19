//
//  AugmentedRealityController.h
//  iPhoneAugmentedRealityLib
//
//  Modified by Niels W Hansen on 10/02/11.
//  Copyright 2011 Agilite Software All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ARViewController.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class ARCoordinate;

@interface AugmentedRealityController : NSObject <UIAccelerometerDelegate, CLLocationManagerDelegate> {

	BOOL scaleViewsBasedOnDistance;
	BOOL rotateViewsBasedOnPerspective;
	
	double maximumScaleDistance;
	double minimumScaleFactor;
	double maximumRotationAngle;
    
    CGPoint startPoint;
	CGPoint endPoint;
    float verticleDiff;
	float prevHeading;
    int totalDisplayed;
	int prevTotalDisplayed;

	
	ARCoordinate		*centerCoordinate;
	CLLocationManager	*locationManager;
	UIDeviceOrientation currentOrientation;
	
	ARViewController	*rootViewController;
	UIAccelerometer		*accelerometerManager;
	CLLocation			*centerLocation;
	UIView				*displayView;
	UILabel				*debugView;
    UIButton            *closeButton;
    AVCaptureSession    *captureSession;
    AVCaptureVideoPreviewLayer *previewLayer;

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
@property (nonatomic) BOOL debugMode;

@property double maximumScaleDistance;
@property double minimumScaleFactor;
@property double maximumRotationAngle;
@property double degreeRange;

@property float verticleDiff;
@property float prevHeading;
@property int totalDisplayed;
@property int prevTotalDisplayed;
@property double  latestHeading;
@property float   viewAngle;

@property (nonatomic, retain) UIAccelerometer	*accelerometerManager;
@property (nonatomic, retain) CLLocationManager	*locationManager;
@property (nonatomic, retain) ARCoordinate		*centerCoordinate;
@property (nonatomic, retain) CLLocation		*centerLocation;
@property (nonatomic, retain) UIView			*displayView;
@property (nonatomic, retain) UIView			*ARView;
@property (nonatomic, retain) ARViewController	*rootViewController;
@property UIDeviceOrientation	currentOrientation;
@property (nonatomic, retain) AVCaptureSession    *captureSession;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;

@property (retain) UILabel              *debugView;
@property (retain) UIButton             *closeButton;
@property (nonatomic,retain) NSMutableArray		*coordinates;
@property (nonatomic,retain) NSMutableArray		*coordinateViews;

@property CGPoint startPoint;
@property CGPoint endPoint;

- (id)initWithViewController:(UIViewController *)theView;

- (void) setupDebugPostion;
- (void) updateLocations;
- (void) stopListening;

// Adding coordinates to the underlying data model.
- (void)addCoordinate:(ARCoordinate *)coordinate augmentedView:(UIView *)agView animated:(BOOL)animated ;

// Removing coordinates
- (void)removeCoordinate:(ARCoordinate *)coordinate;
- (void)removeCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated;
- (void)removeCoordinates:(NSArray *)coordinateArray;


@end
