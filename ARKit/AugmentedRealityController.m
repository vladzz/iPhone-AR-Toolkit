//
//  AugmentedRealityController.m
//  iPhoneAugmentedRealityLib
//
//  Modified by Niels W Hansen on 10/02/11.
//  Copyright 2011 Agilite Software. All rights reserved.
//

#import "AugmentedRealityController.h"
#import "ARCoordinate.h"
#import "ARGeoCoordinate.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#define kFilteringFactor 0.05
#define degreesToRadian(x) (M_PI * (x) / 180.0)
#define radianToDegrees(x) ((x) * 180.0/M_PI)
#define BOX_WIDTH 150
#define BOX_HEIGHT 100
#define BOX_GAP 10
#define ADJUST_BY 30


@interface AugmentedRealityController (Private)
- (void) updateCenterCoordinate;
- (void) startListening;
- (double) findDeltaOfRadianCenter:(double*)centerAzimuth coordinateAzimuth:(double)pointAzimuth betweenNorth:(BOOL*) isBetweenNorth;
- (CGPoint) pointInView:(UIView *)realityView withView:(UIView *)viewToDraw forCoordinate:(ARCoordinate *)coordinate forIndex:(int)frameIndex;
- (BOOL) viewportContainsView:(UIView *)viewToDraw forCoordinate:(ARCoordinate *)coordinate;
@end

@implementation AugmentedRealityController

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
@synthesize coordinates;
@synthesize debugMode;
@synthesize currentOrientation;
@synthesize degreeRange;
@synthesize rootViewController;
@synthesize closeButton;
@synthesize debugView;
@synthesize latestHeading;
@synthesize viewAngle;
@synthesize coordinateViews;
@synthesize captureSession;
@synthesize previewLayer;
@synthesize ARView;
@synthesize verticleDiff, prevHeading;
@synthesize startPoint, endPoint;
@synthesize totalDisplayed, prevTotalDisplayed;


- (id)initWithViewController:(ARViewController *)vc {
    
    if (!(self = [super init]))
		return nil;
	
    [self setLatestHeading: -1.0f];
    [self setVerticleDiff:0.0f];
    [self setPrevHeading:-1.0f];
	[self setRootViewController: vc];
	[self setDebugMode:NO];
	[self setMaximumScaleDistance: 0.0];
	[self setMinimumScaleFactor: 1.0];
	[self setScaleViewsBasedOnDistance: NO];
	[self setRotateViewsBasedOnPerspective: NO];
	[self setMaximumRotationAngle: M_PI / 6.0];
    
    [self setCoordinates:[[NSMutableArray alloc] init]];
	[self setCoordinateViews:[[NSMutableArray alloc] init]];
	
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	
	UIView *arView = [[UIView alloc] initWithFrame: screenRect];
     
	[self setCurrentOrientation:UIDeviceOrientationPortrait];
	[self setDegreeRange:[arView bounds].size.width / ADJUST_BY];
    
    UIView *displayV= [[UIView alloc] initWithFrame: screenRect];
	
    [self setCurrentOrientation:UIDeviceOrientationPortrait];
	

	[vc setView:displayV];
    [[vc view] insertSubview:arView atIndex:0];

#if !TARGET_IPHONE_SIMULATOR
    
    AVCaptureSession *avCaptureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    
    if (videoInput) {
        [avCaptureSession addInput:videoInput];
    }
    else {
        // Handle the failure.
    }
    
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:avCaptureSession];
    
    UIView *view        = arView;
    CALayer *viewLayer  = [view layer];
    
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [newCaptureVideoPreviewLayer setFrame:bounds];
    
    if ([newCaptureVideoPreviewLayer isOrientationSupported]) {
        [newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
    
    [self setPreviewLayer:newCaptureVideoPreviewLayer];
    [newCaptureVideoPreviewLayer release];
    
    [avCaptureSession setSessionPreset:AVCaptureSessionPresetLow];
    [avCaptureSession startRunning];
    
    [self setCaptureSession:avCaptureSession];  
    [avCaptureSession release];

#endif

    CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:37.41711 longitude:-122.02528];
	
	[self setCenterLocation: newCenter];
	[newCenter release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];	
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    
    [closeBtn setTitle:@"Close" forState:UIControlStateNormal];
    
    [closeBtn setBackgroundColor:[UIColor greenColor]];
    [closeBtn addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [displayV addSubview:closeBtn];
    	
	[self startListening];
    
    [self setCloseButton:closeBtn];
    [self setARView:arView];
    [self setDisplayView:displayV];
    
    [arView release];
    [closeBtn release];
    [displayV release];
	
	return self;
}

-(void)unloadAV {
    [captureSession stopRunning];
    AVCaptureInput* input = [captureSession.inputs objectAtIndex:0];
    [captureSession removeInput:input];
    [[self previewLayer] removeFromSuperlayer];
    [self setCaptureSession:nil];
    [self setPreviewLayer:nil];	
}

- (IBAction)closeButtonClicked:(id)sender {
    [self stopListening];
    [self unloadAV];
    [[self rootViewController] dismissModalViewControllerAnimated:YES];
}

- (void)startListening {
	
	// start our heading readings and our accelerometer readings.
	if (![self locationManager]) {
		CLLocationManager *newLocationManager = [[CLLocationManager alloc] init];
        [self setLocationManager: newLocationManager];
        [newLocationManager release];
		[[self locationManager] setHeadingFilter: 1.0];
        [[self locationManager] setDistanceFilter:2.0];
		[[self locationManager] setDesiredAccuracy: kCLLocationAccuracyNearestTenMeters];
		[[self locationManager] startUpdatingHeading];
		[[self locationManager] startUpdatingLocation];
		[[self locationManager] setDelegate: self];
	}
			
	if (![self accelerometerManager]) {
		[self setAccelerometerManager: [UIAccelerometer sharedAccelerometer]];
		[[self accelerometerManager] setUpdateInterval: 0.75];
		[[self accelerometerManager] setDelegate: self];
	}
	
	if (![self centerCoordinate]) 
		[self setCenterCoordinate:[ARCoordinate coordinateWithRadialDistance:1.0 inclination:0 azimuth:0]];
}

- (void)stopListening {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
    if ([self locationManager]) {
       [[self locationManager] setDelegate: nil];
    }
    
    if ([self accelerometerManager]) {
       [[self accelerometerManager] setDelegate: nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	
    latestHeading = degreesToRadian(newHeading.magneticHeading);
    
    if (prevHeading == -1)  
		prevHeading = newHeading.magneticHeading;
	    
	[self updateCenterCoordinate];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

		[self setCenterLocation:newLocation];
}

-(void) setupDebugPostion {
	
	if ([self debugMode]) {
		[debugView sizeToFit];
		CGRect displayRect = [[self displayView] bounds];
		
		[debugView setFrame:CGRectMake(0, displayRect.size.height - [debugView bounds].size.height,  displayRect.size.width, [debugView bounds].size.height)];
	}
}

- (void)updateCenterCoordinate {
	
	double adjustment = 0;
	
	if (currentOrientation == UIDeviceOrientationLandscapeLeft)
		adjustment = degreesToRadian(270); 
	else if (currentOrientation == UIDeviceOrientationLandscapeRight)
		adjustment = degreesToRadian(90);
	else if (currentOrientation == UIDeviceOrientationPortraitUpsideDown)
		adjustment = degreesToRadian(180);

	[[self centerCoordinate] setAzimuth: latestHeading - adjustment];

	[self updateLocations];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	switch (currentOrientation) {
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
	
//	[self updateCenterCoordinate];
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

- (void)addCoordinate:(ARCoordinate *)coordinate augmentedView:(UIView *)agView animated:(BOOL)animated {
	
	[coordinates addObject:coordinate];
	
	if ([coordinate radialDistance] > [self maximumScaleDistance]) 
		[self setMaximumScaleDistance: [coordinate radialDistance]];
	
	[coordinateViews addObject:agView];
}

- (void)removeCoordinate:(ARCoordinate *)coordinate {
	[self removeCoordinate:coordinate animated:YES];
}

- (void)removeCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated {
	[coordinates removeObject:coordinate];
}

- (void)removeCoordinates:(NSArray *)coordinateArray {	
	
	for (ARCoordinate *coordinateToRemove in coordinateArray) {
		NSUInteger indexToRemove = [coordinates indexOfObject:coordinateToRemove];
		
		//TODO: Error checking in here.
		[coordinates	 removeObjectAtIndex:indexToRemove];
		[coordinateViews removeObjectAtIndex:indexToRemove];
	}
}

-(double) findDeltaOfRadianCenter:(double*)centerAzimuth coordinateAzimuth:(double)pointAzimuth betweenNorth:(BOOL*) isBetweenNorth {

	if (*centerAzimuth < 0.0) 
		*centerAzimuth = (M_PI * 2.0) + *centerAzimuth;
	
	if (*centerAzimuth > (M_PI * 2.0)) 
		*centerAzimuth = *centerAzimuth - (M_PI * 2.0);
	
	double deltaAzimith = ABS(pointAzimuth - *centerAzimuth);
	*isBetweenNorth		= NO;

	// If values are on either side of the Azimuth of North we need to adjust it.  Only check the degree range
	if (*centerAzimuth < degreesToRadian([self degreeRange]) && pointAzimuth > degreesToRadian(360-[self degreeRange])) {
		deltaAzimith	= (*centerAzimuth + ((M_PI * 2.0) - pointAzimuth));
		*isBetweenNorth = YES;
	}
	else if (pointAzimuth < degreesToRadian([self degreeRange]) && *centerAzimuth > degreesToRadian(360-[self degreeRange])) {
		deltaAzimith	= (pointAzimuth + ((M_PI * 2.0) - *centerAzimuth));
		*isBetweenNorth = YES;
	}
			
	return deltaAzimith;
}

- (BOOL)viewportContainsView:(UIView *)viewToDraw  forCoordinate:(ARCoordinate *)coordinate {
	
	double currentAzimuth = [[self centerCoordinate] azimuth];
	double pointAzimuth	  = [coordinate azimuth];
	BOOL isBetweenNorth	  = NO;
	double deltaAzimith	  = [self findDeltaOfRadianCenter: &currentAzimuth coordinateAzimuth:pointAzimuth betweenNorth:&isBetweenNorth];
	BOOL result			  = NO;
	
  //  NSLog(@"Current %f, Item %f, delta %f, range %f",currentAzimuth,pointAzimuth,deltaAzimith,degreesToRadian([self degreeRange]));
    
    
	if (deltaAzimith <= degreesToRadian([self degreeRange]))
		result = YES;

	return result;
}

- (void)updateLocations {
	
	if (!coordinateViews || [coordinateViews count] == 0) 
		return;
	
	[debugView setText: [NSString stringWithFormat:@"%.3f %.3f ", -radianToDegrees(viewAngle), radianToDegrees([[self centerCoordinate] azimuth])]];
	
	int index		= 0;
	totalDisplayed	= 0;
	int frameIndex  = 0;
	
	for (ARCoordinate *item in coordinates) {
		
		UIView *viewToDraw = [coordinateViews objectAtIndex:index];
		
		if ([self viewportContainsView:viewToDraw forCoordinate:item]) {
			
			CGPoint loc = [self pointInView:[self displayView] withView:viewToDraw forCoordinate:item forIndex:frameIndex];
			
            frameIndex++;
            CGFloat scaleFactor = 1.0;
	
			if ([self scaleViewsBasedOnDistance]) 
				scaleFactor = 1.0 - [self minimumScaleFactor]*([item radialDistance] / [self maximumScaleDistance]);
			
			float width	 = [viewToDraw bounds].size.width  * scaleFactor;
			float height = [viewToDraw bounds].size.height * scaleFactor;
            
            if(loc.y == 0 && verticleDiff > 0)
				verticleDiff = 0;
			
			[viewToDraw setFrame:CGRectMake(loc.x - width / 2.0, loc.y + verticleDiff, width, height)];
            
			totalDisplayed++;
			
			CATransform3D transform = CATransform3DIdentity;
			
			// Set the scale if it needs it. Scale the perspective transform if we have one.
			if ([self scaleViewsBasedOnDistance]) 
				transform = CATransform3DScale(transform, scaleFactor, scaleFactor, scaleFactor);
		
			if ([self rotateViewsBasedOnPerspective]) {
				transform.m34 = 1.0 / 300.0;
		/*		
				double itemAzimuth		= [item azimuth];
				double centerAzimuth	= [[self centerCoordinate] azimuth];
				
				if (itemAzimuth - centerAzimuth > M_PI) 
					centerAzimuth += 2 * M_PI;
				
				if (itemAzimuth - centerAzimuth < -M_PI) 
					itemAzimuth  += 2 * M_PI;
		*/		
		//		double angleDifference	= itemAzimuth - centerAzimuth;
		//		transform				= CATransform3DRotate(transform, [self maximumRotationAngle] * angleDifference / 0.3696f , 0, 1, 0);
			}
			[[viewToDraw layer] setTransform:transform];
			
			//if we don't have a superview, set it up.
			if (!([viewToDraw superview])) {
				[[self displayView] insertSubview:viewToDraw atIndex:1];
			}
		} 
		else 
            if ([viewToDraw superview])
                [viewToDraw removeFromSuperview];
		
		index++;
	}
}

- (CGPoint)pointInView:(UIView *)realityView withView:(UIView *)viewToDraw forCoordinate:(ARCoordinate *)coordinate forIndex:(int)frameIndex {	
	
	CGPoint point;
	CGRect realityBounds	= [realityView bounds];
	double currentAzimuth	= [[self centerCoordinate] azimuth];
	double pointAzimuth		= [coordinate azimuth];
	BOOL isBetweenNorth		= NO;
	double deltaAzimith		= [self findDeltaOfRadianCenter: &currentAzimuth coordinateAzimuth:pointAzimuth betweenNorth:&isBetweenNorth];
	
	if ((pointAzimuth > currentAzimuth && !isBetweenNorth) || (currentAzimuth > degreesToRadian(360-[self degreeRange]) && pointAzimuth < degreesToRadian([self degreeRange])))
		point.x = (realityBounds.size.width / 2) + ((deltaAzimith / degreesToRadian(1)) * ADJUST_BY);  // Right side of Azimuth
	else
		point.x = (realityBounds.size.width / 2) - ((deltaAzimith / degreesToRadian(1)) * ADJUST_BY);	// Left side of Azimuth
	
	point.y = (realityBounds.size.height / 2) + (radianToDegrees(M_PI_2 + viewAngle)  * 2.0);
    
/*
    if(frameIndex == 0)
		point.y = 0;  
	else
		// Adding radianToDegrees part in Y-Axis making point bousing continously so ignore it.
		point.y = frameIndex * (BOX_HEIGHT + BOX_GAP); // + (radianToDegrees(M_PI_2 + viewAngle)  * 2.0);
 */   
	
	return point;
}

-(NSComparisonResult) LocationSortClosestFirst:(ARCoordinate *) s1 secondCoord:(ARCoordinate*) s2 {
    
	if ([s1 radialDistance] < [s2 radialDistance]) 
		return NSOrderedAscending;
	else if ([s1 radialDistance] > [s2 radialDistance]) 
		return NSOrderedDescending;
	else 
		return NSOrderedSame;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	verticleDiff = 0;
	prevHeading = -1;
	
	// Later we may handle the Orientation of Faceup to show a Map.  For now let's ignore it.
	if (orientation != UIDeviceOrientationUnknown && orientation != UIDeviceOrientationFaceUp && orientation != UIDeviceOrientationFaceDown) {
		
		CGAffineTransform transform = CGAffineTransformMakeRotation(degreesToRadian(0));
		CGRect bounds = [[UIScreen mainScreen] bounds];
          
		if (orientation == UIDeviceOrientationLandscapeLeft) {
			transform		   = CGAffineTransformMakeRotation(degreesToRadian(90));
			bounds.size.width  = [[UIScreen mainScreen] bounds].size.height;
			bounds.size.height = [[UIScreen mainScreen] bounds].size.width;
            [[self previewLayer] setOrientation:AVCaptureVideoOrientationLandscapeRight];
		}
		else if (orientation == UIDeviceOrientationLandscapeRight) {
			transform		   = CGAffineTransformMakeRotation(degreesToRadian(-90));
			bounds.size.width  = [[UIScreen mainScreen] bounds].size.height;
			bounds.size.height = [[UIScreen mainScreen] bounds].size.width;
            [[self previewLayer] setOrientation:AVCaptureVideoOrientationLandscapeLeft];
		}
		else if (orientation == UIDeviceOrientationPortraitUpsideDown)
        {
			transform = CGAffineTransformMakeRotation(degreesToRadian(180));
            [[self previewLayer] setOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
        }
		
        if (orientation == UIDeviceOrientationPortrait)
            [[self previewLayer] setOrientation:AVCaptureVideoOrientationPortrait];
        
        [[self ARView] setFrame:bounds];
		[[self previewLayer] setFrame:bounds];

        [displayView setTransform:CGAffineTransformIdentity];
		[displayView setTransform: transform];
		[displayView setBounds:bounds];  
        
		[self setDegreeRange:[[self displayView] bounds].size.width / ADJUST_BY];
		[self setDebugMode:YES];
	}
}

- (void)setDebugMode:(BOOL)flag {

	if ([self debugMode] == flag) {
		currentOrientation = [[UIDevice currentDevice] orientation];

		CGRect debugRect  = CGRectMake(0, [[self displayView] bounds].size.height -20, [[self displayView] bounds].size.width, 20);	
		[debugView setFrame: debugRect];
		return;
	}
	
	debugMode = flag;
	
	if ([self debugMode]) {
		debugView = [[UILabel alloc] initWithFrame:CGRectZero];
		[debugView setTextAlignment: UITextAlignmentCenter];
		[debugView setText: @"Waiting..."];
		[displayView addSubview:debugView];
		[self setupDebugPostion];
	}
	else 
		[debugView removeFromSuperview];
}

- (void)dealloc {
    [self unloadAV];
    [closeButton release];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [ARView release];
    locationManager.delegate = nil;
    [UIAccelerometer sharedAccelerometer].delegate = nil;
	[locationManager release];
	[coordinateViews release];
	[coordinates release];
	[debugView release];
    [super dealloc];
}

#pragma mark -	
#pragma mark Touch events

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if([touches count] == 1) {
		UITouch *theTouch = [touches anyObject];
        startPoint = [theTouch locationInView:self.displayView];
	}
	
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if([touches count] == 1) {
		UITouch *theTouch = [touches anyObject];		
        endPoint = [theTouch locationInView:self.displayView];
		float diff = endPoint.y - startPoint.y;
		
		//NSLog(@"%f %f %d", verticleDiff, diff, totalDisplayed);
		
		// Do not scroll down if last point reached
		// Always allow scrolling up, we restrict it in UpdateLocations method.
		if ( diff > 0 || (ABS(verticleDiff) + diff + [[UIScreen mainScreen] bounds].size.height) < totalDisplayed * (BOX_GAP + BOX_HEIGHT)) 
			// We just care about verticle difference
			verticleDiff += diff;
    	
		if(ABS(diff) > 100 || ABS(endPoint.x - startPoint.x) > 100)
			[self updateLocations];
		
		// Update the start point
		startPoint.x = endPoint.x;
		startPoint.y = endPoint.y;
		
		// update the previous total displayed
		prevTotalDisplayed = totalDisplayed;
	}
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if([touches count] == 1) {
		UITouch *theTouch = [touches anyObject];		
        endPoint = [theTouch locationInView:self.displayView];
		float diff = endPoint.y - startPoint.y;
		
		//NSLog(@"%f %f %d", verticleDiff, diff, totalDisplayed);
		
		// Do not scroll down if last point
		if (diff > 0 || (ABS(verticleDiff) + diff + [[UIScreen mainScreen] bounds].size.height) < totalDisplayed * (BOX_GAP + BOX_HEIGHT)) 
			verticleDiff += diff;// We just care about verticle difference
		
		// Always update the locations
		[self updateLocations];
		
		// update the previous total displayed
		prevTotalDisplayed = totalDisplayed;
	}
}

@end
