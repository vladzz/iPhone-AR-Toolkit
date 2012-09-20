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
}

@property (nonatomic, assign) BOOL scaleViewsBasedOnDistance;
@property (nonatomic, assign) BOOL rotateViewsBasedOnPerspective;
@property (nonatomic, assign) BOOL debugMode;

@property (nonatomic, assign) double maximumScaleDistance;
@property (nonatomic, assign) double minimumScaleFactor;
@property (nonatomic, assign) double maximumRotationAngle;

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

// Adding coordinates to the underlying data model.
- (void)addCoordinate:(ARGeoCoordinate *)coordinate;

// Removing coordinates
- (void)removeCoordinate:(ARGeoCoordinate *)coordinate;
- (void)removeGeoCoordinatesArr:(NSArray *)coordinateArray;
- (void)updateDebugMode:(BOOL)flag;


@end
