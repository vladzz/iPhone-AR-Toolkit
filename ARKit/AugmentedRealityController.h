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
#import <CoreMotion/CoreMotion.h>

@class ARCoordinate;

@interface AugmentedRealityController : NSObject <UIAccelerometerDelegate, CLLocationManagerDelegate> {

	BOOL scaleViewsBasedOnDistance;
	BOOL rotateViewsBasedOnPerspective;

	double maximumScaleDistance;
	double minimumScaleFactor;
	double maximumRotationAngle;

	ARCoordinate		*centerCoordinate;
	CLLocationManager	*locationManager;
    CMMotionManager     *motionManager;
	ARViewController	*rootViewController;
	
@private
	double	latestHeading;
	double  degreeRange;
    
    double rotate;
	
	BOOL	debugMode;
   
    float	viewAngle;
    float   verticleDiff;
	float   prevHeading;
    
    int     totalDisplayed;
	int     prevTotalDisplayed;
    int     cameraOrientation;
    
    CGPoint startPoint;
	CGPoint endPoint;
    
	NSMutableArray	*coordinates;
	NSMutableArray	*coordinateViews;
    
    UILabel				*debugView;
    AVCaptureSession    *captureSession;
    AVCaptureVideoPreviewLayer *previewLayer;
    
    UIAccelerometer		*accelerometerManager;
	CLLocation			*centerLocation;
	UIView				*displayView;
    
    
    
}

@property BOOL scaleViewsBasedOnDistance;
@property BOOL rotateViewsBasedOnPerspective;
@property BOOL debugMode;

@property double maximumScaleDistance;
@property double minimumScaleFactor;
@property double maximumRotationAngle;

@property CGPoint startPoint;
@property CGPoint endPoint;

@property (nonatomic, retain) UIAccelerometer           *accelerometerManager;
@property (nonatomic, retain) CLLocationManager         *locationManager;
@property (nonatomic, retain) ARCoordinate              *centerCoordinate;
@property (nonatomic, retain) CLLocation                *centerLocation;
@property (nonatomic, retain) UIView                    *displayView;
@property (nonatomic, retain) UIView                    *ARView;
@property (nonatomic, retain) ARViewController          *rootViewController;
@property (nonatomic, retain) AVCaptureSession          *captureSession;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;


@property (retain) UILabel  *debugView;

@property (nonatomic,retain) NSMutableArray		*coordinates;
@property (nonatomic,retain) NSMutableArray		*coordinateViews;

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
- (void) updateDebugMode:(BOOL) flag;


@end
