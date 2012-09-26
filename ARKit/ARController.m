//
//  AugmentedRealityController.m
//  AR Kit
//
//  Modified by Niels W Hansen on 5/25/12.
//  Copyright 2011 Agilite Software. All rights reserved.
//

#import "ARController.h"
#import "ARCoordinate.h"
#import "ARMarkerView.h"

//#define kFilteringFactor 0.05
#define degreesToRadian(x) (M_PI * (x) / 180.0)
#define radianToDegrees(x) ((x) * 180.0 / M_PI)
#define M_2PI 2.0 * M_PI
#define ADJUST_BY 30
#define DISTANCE_FILTER 20.0
#define HEADING_FILTER 1.0
#define INTERVAL_UPDATE 0.75
#define SCALE_FACTOR 1.0
#define HEADING_NOT_SET -1.0
#define DEGREE_TO_UPDATE 1


@interface ARController (Private)

- (void)updateCenterCoordinate;
- (void)updateCurrentDeviceOrientation;

- (double)findDeltaOfRadianCenter:(double*)centerAzimuth coordinateAzimuth:(double)pointAzimuth betweenNorth:(BOOL*) isBetweenNorth;

- (CGPoint)pointForCoordinate:(ARCoordinate *)coordinate;

- (BOOL)shouldDisplayCoordinate:(ARCoordinate *)coordinate;

@end

@implementation ARController

@synthesize delegate = _delegate;
@synthesize locationManager = _locationManager;
@synthesize accelerometerManager = _accelerometerManager;
@synthesize displayView = _displayView;
@synthesize cameraView = _cameraView;
@synthesize centerCoordinate = _centerCoordinate;
@synthesize scaleViewsBasedOnDistance = _scaleViewsBasedOnDistance;
@synthesize rotateViewsBasedOnPerspective = _rotateViewsBasedOnPerspective;
@synthesize debugMode = _debugMode;
@synthesize maximumScaleDistance = _maximumScaleDistance;
@synthesize minimumScaleFactor = _minimumScaleFactor;
@synthesize maximumRotationAngle = _maximumRotationAngle;
@synthesize centerLocation = _centerLocation;
@synthesize geoCoordinatesArr = _geoCoordinatesArr;
@synthesize geoCoordinatesDict = _geoCoordinatesDict;

- (id)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if (!self)
		return nil;
    
    latestHeading   = HEADING_NOT_SET;
    prevHeading     = HEADING_NOT_SET;
    self.maximumScaleDistance = 0.1;    // set to .1 prevent NaN errors
	self.minimumScaleFactor = SCALE_FACTOR;
	self.scaleViewsBasedOnDistance = YES;
	self.rotateViewsBasedOnPerspective = NO;
	self.maximumRotationAngle = M_PI / 6.0;
    self.geoCoordinatesArr = [NSMutableArray array];
    self.geoCoordinatesDict = [NSMutableDictionary dictionary];
    
    [self updateCurrentDeviceOrientation];
    
	CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // Default the orientation to UIDeviceOrientationLandscapeLeft
//    if (cameraOrientation == UIDeviceOrientationUnknown || cameraOrientation == UIDeviceOrientationFaceUp ||
//        cameraOrientation == UIDeviceOrientationFaceDown || cameraOrientation == UIDeviceOrientationPortrait ||
//        cameraOrientation == UIDeviceOrientationPortraitUpsideDown) {
//        cameraOrientation = UIDeviceOrientationLandscapeLeft;
//    }
    
//    if (cameraOrientation == UIDeviceOrientationLandscapeLeft || cameraOrientation == UIDeviceOrientationLandscapeRight) {
        screenRect.size.width  = [[UIScreen mainScreen] bounds].size.height;
        screenRect.size.height = [[UIScreen mainScreen] bounds].size.width;
    //    screenRect.size.width  = 480.0;
    //    screenRect.size.height = 320.0;
//    }
    
    viewController.view.frame = screenRect;
    self.displayView = viewController.view;
    
    self.cameraView = [[UIView alloc] initWithFrame:screenRect];
	degreeRange = self.cameraView.bounds.size.width / ADJUST_BY;
        
#if !TARGET_IPHONE_SIMULATOR
    
    AVCaptureSession *avCaptureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    
    if (videoInput) {
        [avCaptureSession addInput:videoInput];
    } else {
        // Handle the failure.
    }
    
    self.cameraView.layer.masksToBounds = YES;
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:avCaptureSession];
    previewLayer.frame = self.cameraView.bounds;
    
    if (IS_IOS_6) {
        if (previewLayer.connection.supportsVideoOrientation) {
            previewLayer.connection.videoOrientation = cameraOrientation;
        }
    } else {
        if ([previewLayer isOrientationSupported]) {
            previewLayer.orientation = cameraOrientation;
        }
    }
        
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;    
    [self.cameraView.layer insertSublayer:previewLayer below:[self.cameraView.layer.sublayers objectAtIndex:0]];
    
    [avCaptureSession setSessionPreset:AVCaptureSessionPresetLow];
    [avCaptureSession startRunning];
    captureSession = avCaptureSession;

#endif

    // Create an arbitrary location to start with
    self.centerLocation = [[CLLocation alloc] initWithLatitude:37.41711 longitude:-122.02528]; 
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
     
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];	
    	
    [self.displayView insertSubview:self.cameraView atIndex:0];
    
  	return self;
}

-(void)unloadAV
{
    [captureSession stopRunning];
    AVCaptureInput* input = [captureSession.inputs objectAtIndex:0];
    [captureSession removeInput:input];
    [previewLayer removeFromSuperlayer];
    captureSession = nil;
    previewLayer = nil;
}

#pragma mark - Location Manager methods

// start our heading readings and our accelerometer readings.
- (void)startListening
{
	if (self.locationManager == nil) {
		self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.headingFilter = HEADING_FILTER;
        self.locationManager.distanceFilter = DISTANCE_FILTER;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
		self.locationManager.delegate = self;
		[self.locationManager startUpdatingHeading];
		[self.locationManager startUpdatingLocation];
	}
			
	if (self.accelerometerManager == nil) {
		self.accelerometerManager = [UIAccelerometer sharedAccelerometer];
		self.accelerometerManager.updateInterval = INTERVAL_UPDATE;
		self.accelerometerManager.delegate = self;
	}
	
	if (self.centerCoordinate == nil)
		self.centerCoordinate = [ARCoordinate coordinateWithRadialDistance:1.0 inclination:0 azimuth:0];
}

- (void)stopListening
{
    NSLog(@"stopListening");
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
    if (self.locationManager) {
        self.locationManager.delegate = nil;
    }
    
    if (self.accelerometerManager) {
        self.accelerometerManager.delegate = nil;
    }
}
     
#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{    
    latestHeading = degreesToRadian(newHeading.magneticHeading);
    
    //Let's only update the Center Coordinate when we have adjusted by more than X degrees
    if (fabs(latestHeading-prevHeading) >= degreesToRadian(DEGREE_TO_UPDATE) || prevHeading == HEADING_NOT_SET) {
        prevHeading = latestHeading;
        [self updateCenterCoordinate];

        [self.delegate didUpdateHeading:newHeading];
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
     fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location of phone changed:%f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    self.centerLocation = newLocation;

    [self.delegate didUpdateLocation:newLocation];
}

- (void)updateCenterCoordinate
{
	double adjustment = 0;

    switch (cameraOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            adjustment = degreesToRadian(270); 
            break;
        case UIDeviceOrientationLandscapeRight:    
            adjustment = degreesToRadian(90);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            adjustment = degreesToRadian(180);
            break;
        default:
            adjustment = 0;
            break;
    }
	
    [self.centerCoordinate setAzimuth:(latestHeading - adjustment)];
	[self updateLocations];
}

- (void)setCenterLocation:(CLLocation *)newLocation
{
    _centerLocation = newLocation;
	
	for (ARGeoCoordinate *geoLocation in self.geoCoordinatesArr) {
		if ([geoLocation isKindOfClass:[ARGeoCoordinate class]]) {
			[geoLocation calibrateUsingOrigin:self.centerLocation];
			
            if (geoLocation.radialDistance > self.maximumScaleDistance) {
				self.maximumScaleDistance = geoLocation.radialDistance;
            }
		}
	}
}
     
#pragma mark - UIAccelerometerDelegate methods

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{	
	switch (cameraOrientation) {
		case UIDeviceOrientationLandscapeLeft:
			viewAngle = atan2(acceleration.x, acceleration.z);
			break;
		case UIDeviceOrientationLandscapeRight:
			viewAngle = atan2(-acceleration.x, acceleration.z);
			break;
		case UIDeviceOrientationPortrait:
			viewAngle = atan2(acceleration.y, acceleration.z);
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			viewAngle = atan2(-acceleration.y, acceleration.z);
			break;	
		default:
			break;
	}
    
    [self updateLocations];
}

#pragma mark - Coordinate methods

- (void)addCoordinate:(ARGeoCoordinate *)coordinate
{
    [self.geoCoordinatesArr addObject:coordinate];
	
	if (coordinate.radialDistance > self.maximumScaleDistance)
		self.maximumScaleDistance = coordinate.radialDistance;
}

- (void)removeCoordinate:(ARGeoCoordinate *)coordinate
{
	[self.geoCoordinatesArr removeObject:coordinate];
}

- (void)clearGeoCoordinates
{
    [self.geoCoordinatesArr removeAllObjects];
    self.geoCoordinatesArr = nil;
}

#pragma mark - Location methods

-(double)findDeltaOfRadianCenter:(double*)centerAzimuth coordinateAzimuth:(double)pointAzimuth
     betweenNorth:(BOOL*)isBetweenNorth
{
	if (*centerAzimuth < 0.0) 
		*centerAzimuth = M_2PI + *centerAzimuth;
	
	if (*centerAzimuth > M_2PI) 
		*centerAzimuth = *centerAzimuth - M_2PI;
	
	double deltaAzimuth = ABS(pointAzimuth - *centerAzimuth);
	*isBetweenNorth		= NO;

	// If values are on either side of the Azimuth of North we need to adjust it.  Only check the degree range
	if (*centerAzimuth < degreesToRadian(degreeRange) && pointAzimuth > degreesToRadian(360-degreeRange)) {
		deltaAzimuth	= (*centerAzimuth + (M_2PI - pointAzimuth));
		*isBetweenNorth = YES;
	}
	else if (pointAzimuth < degreesToRadian(degreeRange) && *centerAzimuth > degreesToRadian(360-degreeRange)) {
		deltaAzimuth	= (pointAzimuth + (M_2PI - *centerAzimuth));
		*isBetweenNorth = YES;
	}
			
	return deltaAzimuth;
}

- (BOOL)shouldDisplayCoordinate:(ARCoordinate *)coordinate
{
	double currentAzimuth = self.centerCoordinate.azimuth;
	double pointAzimuth	  = coordinate.azimuth;
	BOOL isBetweenNorth	  = NO;
	double deltaAzimuth	  = [self findDeltaOfRadianCenter:&currentAzimuth coordinateAzimuth:pointAzimuth betweenNorth:&isBetweenNorth];
	BOOL result			  = NO;
	
  //  NSLog(@"Current %f, Item %f, delta %f, range %f",currentAzimuth,pointAzimuth,deltaAzimith,degreesToRadian([self degreeRange]));
	if (deltaAzimuth <= degreesToRadian(degreeRange))
		result = YES;

//    NSLog(@"shouldDisplayCoordinate:%@ :%@", coordinate.title, (result ? @"Yes" : @"No"));
	return result;
}

- (CGPoint)pointForCoordinate:(ARCoordinate *)coordinate
{
	CGPoint point;
	CGRect realityBounds	= self.displayView.bounds;
	double currentAzimuth	= self.centerCoordinate.azimuth;
	double pointAzimuth		= coordinate.azimuth;
	BOOL isBetweenNorth		= NO;
	double deltaAzimith		= [self findDeltaOfRadianCenter:&currentAzimuth
                                       coordinateAzimuth:pointAzimuth
                                            betweenNorth:&isBetweenNorth];
	
	if ((pointAzimuth > currentAzimuth && !isBetweenNorth) || 
        (currentAzimuth > degreesToRadian(360- degreeRange) && pointAzimuth < degreesToRadian(degreeRange))) {
		point.x = (realityBounds.size.width / 2) + ((deltaAzimith / degreesToRadian(1)) * ADJUST_BY);  // Right side of Azimuth
    }
	else
		point.x = (realityBounds.size.width / 2) - ((deltaAzimith / degreesToRadian(1)) * ADJUST_BY);	// Left side of Azimuth
	
	point.y = (realityBounds.size.height / 2) + (radianToDegrees(M_PI_2 + viewAngle)  * 2.0);
  	
	return point;
}

- (void)updateLocations
{
	NSLog(@"updateLocations");
	debugView.text = [NSString stringWithFormat:@"%.3f %.3f ", -radianToDegrees(viewAngle),
                           radianToDegrees(self.centerCoordinate.azimuth)];
	
    ARGeoCoordinate *geoCoordinate;
	for (geoCoordinate in self.geoCoordinatesArr) {
        ARMarkerView *markerView = (ARMarkerView *)geoCoordinate.markerView;
      
		if ([self shouldDisplayCoordinate:geoCoordinate]) {		
            CGPoint loc = [self pointForCoordinate:geoCoordinate];
            CGFloat scaleFactor = SCALE_FACTOR;
	
			if (self.scaleViewsBasedOnDistance) 
                scaleFactor = scaleFactor - (self.minimumScaleFactor *  geoCoordinate.radialDistance / self.maximumScaleDistance);

//            float width	 = markerView.bounds.size.width  * scaleFactor;
//			float height = markerView.bounds.size.height * scaleFactor;
            float width	 = markerView.startSize.width  * scaleFactor;
			float height = markerView.startSize.height * scaleFactor;
            
  			markerView.frame = CGRectMake(loc.x - width / 2.0, loc.y, width, height);
            [markerView setNeedsDisplay];
			
			CATransform3D transform = CATransform3DIdentity;
			
			// Set the scale if it needs it. Scale the perspective transform if we have one.
			if (self.scaleViewsBasedOnDistance) 
				transform = CATransform3DScale(transform, scaleFactor, scaleFactor, scaleFactor);
		
			if (self.rotateViewsBasedOnPerspective) {
				transform.m34 = 1.0 / 300.0;
		/*
				double itemAzimuth		= [item azimuth];
				double centerAzimuth	= [[self centerCoordinate] azimuth];
				
				if (itemAzimuth - centerAzimuth > M_PI) 
					centerAzimuth += M_2PI;
				
				if (itemAzimuth - centerAzimuth < -M_PI) 
					itemAzimuth  += M_2PI;
		*/		
		//		double angleDifference	= itemAzimuth - centerAzimuth;
		//		transform				= CATransform3DRotate(transform, [self maximumRotationAngle] * angleDifference / 0.3696f , 0, 1, 0);
			}
            
			markerView.layer.transform = transform;
			
			//if marker is not already set then insert it
            if (!markerView.superview) {
				[self.displayView insertSubview:markerView atIndex:1];
			}
		}
		else {
            if (markerView.superview)
                [markerView removeFromSuperview];
        }
	}
    
    [self.delegate didUpdateMarkers];
}

- (NSComparisonResult)LocationSortClosestFirst:(ARCoordinate *)s1 secondCoord:(ARCoordinate*)s2
{    
	if ([s1 radialDistance] < [s2 radialDistance]) 
		return NSOrderedAscending;
	else if ([s1 radialDistance] > [s2 radialDistance]) 
		return NSOrderedDescending;
	else 
		return NSOrderedSame;
}

#pragma mark - Device Orientation

- (void)updateCurrentDeviceOrientation
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

	if (orientation != UIDeviceOrientationUnknown && orientation != UIDeviceOrientationFaceUp && 
        orientation != UIDeviceOrientationFaceDown && orientation != UIDeviceOrientationPortraitUpsideDown &&
        orientation != AVCaptureVideoOrientationPortrait) {
		switch (orientation) {
            case UIDeviceOrientationLandscapeLeft:
                cameraOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                cameraOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
//            case UIDeviceOrientationPortraitUpsideDown:
//                cameraOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
//                break;
//            case UIDeviceOrientationPortrait:
//                cameraOrientation = AVCaptureVideoOrientationPortrait;
//                break;
            default:
                break;
        }
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{	
	prevHeading = HEADING_NOT_SET;
    [self updateCurrentDeviceOrientation];
	
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	// Later we may handle the Orientation of Faceup to show a Map.  For now let's ignore it.
	if (orientation != UIDeviceOrientationUnknown && orientation != UIDeviceOrientationFaceUp && 
        orientation != UIDeviceOrientationFaceDown && orientation != UIDeviceOrientationPortrait &&
        orientation != UIDeviceOrientationPortraitUpsideDown) {
		
		CGAffineTransform transform = CGAffineTransformMakeRotation(degreesToRadian(0));
		CGRect bounds = [[UIScreen mainScreen] bounds];
        
        switch (orientation) {
            case UIDeviceOrientationLandscapeLeft:
                transform		   = CGAffineTransformMakeRotation(degreesToRadian(90));
                bounds.size.width  = [[UIScreen mainScreen] bounds].size.height;
                bounds.size.height = [[UIScreen mainScreen] bounds].size.width;
                break;
            case UIDeviceOrientationLandscapeRight:
                transform		   = CGAffineTransformMakeRotation(degreesToRadian(-90));
                bounds.size.width  = [[UIScreen mainScreen] bounds].size.height;
                bounds.size.height = [[UIScreen mainScreen] bounds].size.width;
                break;
//            case UIDeviceOrientationPortraitUpsideDown:
//                transform = CGAffineTransformMakeRotation(degreesToRadian(180));
//                break;
            default:
                break;
        }
		
        self.cameraView.frame = bounds;
        previewLayer.orientation = cameraOrientation;
        previewLayer.frame = bounds;
  
        self.displayView.transform = CGAffineTransformIdentity;
		self.displayView.transform = transform;
		self.displayView.bounds = bounds;
        
		degreeRange = self.displayView.bounds.size.width / ADJUST_BY;
		[self updateDebugMode:YES];

        [self.delegate didUpdateOrientation:orientation];
	}
}

#pragma mark - Debug features

- (void)updateDebugMode:(BOOL)flag
{
	if (self.debugMode == flag) {
		CGRect debugRect = CGRectMake(0, [[self displayView] bounds].size.height -20, [[self displayView] bounds].size.width, 20);	
		debugView.frame = debugRect;
		return;
	}
	
	if (self.debugMode) {
		debugView = [[UILabel alloc] initWithFrame:CGRectZero];
		debugView.textAlignment = UITextAlignmentCenter;
		debugView.text = @"Waiting...";
		[self.displayView addSubview:debugView];
		[self setupDebugPostion];
	}
	else 
		[debugView removeFromSuperview];
}

-(void)setupDebugPostion
{	
	if (self.debugMode) {
		[debugView sizeToFit];
		CGRect displayRect = self.displayView.bounds;
		
		debugView.frame = CGRectMake(0, displayRect.size.height - debugView.bounds.size.height,
                                       displayRect.size.width, debugView.bounds.size.height);
	}
}

@end
