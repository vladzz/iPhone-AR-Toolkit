//
//  AugmentedRealityController.h
//  AR Kit
//
//  Modified by Niels W Hansen on 12/31/11.
//  Copyright 2011 Agilite Software All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import "ARControllerDelegate.h"
#import "ARGeoCoordinate.h"

#define IS_IOS_6    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)

@class ARCoordinate;

@interface ARController : NSObject <UIAccelerometerDelegate, CLLocationManagerDelegate>
{
@private
	double	latestHeading;
	double  degreeRange;
	
    float	viewAngle;
	float   prevHeading;
    int     cameraOrientation;
        
    UILabel				*debugView;
    AVCaptureSession    *captureSession;
    AVCaptureVideoPreviewLayer *previewLayer;
    
    dispatch_queue_t markersQueue;
}

@property (nonatomic, assign) BOOL scaleViewsBasedOnDistance;
@property (nonatomic, assign) BOOL rotateViewsBasedOnPerspective;
@property (nonatomic, assign) BOOL debugMode;

@property (nonatomic, assign) double maximumScaleDistance;
@property (nonatomic, assign) double minimumScaleFactor;
@property (nonatomic, assign) double maximumRotationAngle;
@property (nonatomic, assign) double rotationFactor;
@property (nonatomic, assign) double yOffsetFactor;

@property (nonatomic, strong) UIAccelerometer *accelerometerManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) ARCoordinate *centerCoordinate;
@property (nonatomic, strong) CLLocation *centerLocation;
@property (nonatomic, strong) UIView *displayView;
@property (nonatomic, strong) UIView *cameraView;

@property (nonatomic, strong) NSMutableArray *geoCoordinatesArr;
@property (nonatomic, strong) NSMutableDictionary *geoCoordinatesDict;
@property (nonatomic, weak) id <ARControllerDelegate> delegate;

- (id)initWithViewController:(UIViewController *)viewController;

- (void)setupDebugPostion;
- (void)startListening;
- (void)updateLocations;
- (void)stopListening;

- (void)addCoordinate:(ARGeoCoordinate *)coordinate;
- (void)removeCoordinate:(ARGeoCoordinate *)coordinate;
- (void)clearGeoCoordinates;
- (void)updateDebugMode:(BOOL)flag;


@end
