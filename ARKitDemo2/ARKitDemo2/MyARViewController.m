//
//  MyARViewController.m
//  ARKitDemo2
//
//  Modified by Yee Peng Chia on 9/19/12.
//  Copyright (c) 2012 Cocoa Star Apps. All rights reserved.
//

#import "MyARViewController.h"
#import "ARController.h"
#import "ARGeoCoordinate.h"
#import "MyMarkerView.h"

@interface MyARViewController (PrivateMethods)

- (MyMarkerView *)findClosestMarker;
- (CGFloat)distanceFromDisplayCenter:(MyMarkerView *)marker;
- (BOOL)markerViewIntersects:(MyMarkerView *)markerView withClosestMarker:(MyMarkerView *)closestView;

@end

@implementation MyARViewController

@synthesize arController = _arController;
@synthesize overlayView = _overlayView;

#pragma mark - Initialization

- (id)init
{	
    self = [super initWithNibName:@"MyARViewController" bundle:nil];
	
	if (self) {
        [self setWantsFullScreenLayout:YES];        
    }
    
 	return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    // Create the ARController instance
    self.arController = [[ARController alloc] initWithViewController:self];
    self.arController.delegate = self;
    self.arController.debugMode = NO;
    self.arController.minimumScaleFactor = 0.1;
    self.arController.rotationFactor = 5.0;

    // Create some ARGeoCoordinate objects
    CLLocation *location = [[CLLocation alloc] initWithLatitude:40.709827 longitude:-74.010628];
    ARGeoCoordinate *coordinate = [ARGeoCoordinate coordinateWithLocation:location locationTitle:@"One Liberty Plaza"];
    MyMarkerView *marker = [[MyMarkerView alloc] initWithCoordinate:coordinate];
    [self.arController addCoordinate:coordinate];
    
    location = [[CLLocation alloc] initWithLatitude:40.710522 longitude:-74.009308];
    coordinate = [ARGeoCoordinate coordinateWithLocation:location locationTitle:@"Cafe Tomato"];
    marker = [[MyMarkerView alloc] initWithCoordinate:coordinate];
    [self.arController addCoordinate:coordinate];
    
    location = [[CLLocation alloc] initWithLatitude:40.709763 longitude:-74.008842];
    coordinate = [ARGeoCoordinate coordinateWithLocation:location locationTitle:@"Toasties"];
    marker = [[MyMarkerView alloc] initWithCoordinate:coordinate];
    [self.arController addCoordinate:coordinate];
    
    // Add the Overlay view
    self.overlayView.frame = self.view.frame;
    [self.view addSubview:self.overlayView];
    
    // Initiates listeners for device sensor events
    [self.arController startListening];
}

- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
}

#pragma mark - Rotation handling

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait || 
        interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
    
	return YES;
}

#pragma mark - ARControllerDelegate methods

- (void)didUpdateHeading:(CLHeading *)newHeading 
{
//    NSLog(@"Heading Updated");
}

- (void)didUpdateLocation:(CLLocation *)newLocation 
{
//    NSLog(@"Location Updated");
    self.overlayView.statusLabel.text = @"Location Updated";
}

- (void)didUpdateOrientation:(UIDeviceOrientation) orientation
{
//    NSLog(@"Orientation Updated");    
    self.overlayView.statusLabel.text = @"Orientation Updated";
}

// Called by agController when its locations are updated
- (void)didUpdateMarkers
{
//    NSLog(@"didUpdateMarkers:%d", [self.arController.displayView.subviews count]);
}

#pragma mark - DTOverlayViewDelegate methods

- (void)overlayViewTestDidTap:(OverlayView *)overlayView
{
    MyMarkerView *closestMarker = [self findClosestMarker];
    self.overlayView.statusLabel.text = closestMarker.geoCoordinate.title;
}

- (MyMarkerView *)findClosestMarker
{
    MyMarkerView *closestMarker = nil;
    NSArray *subviews = self.arController.displayView.subviews;
    int subviewsCount = [subviews count] - 1;
        
    for (int i=subviewsCount; i>=0; i--) {
        UIView *subview = [subviews objectAtIndex:i];
                
        if ([subview isKindOfClass:[MyMarkerView class]]) {
            if (closestMarker == nil) {
                closestMarker = (MyMarkerView *)subview;
            } else {
                MyMarkerView *marker = (MyMarkerView *)subview;
                
                /**
                 * Find the Marker view closest to the display center and on top of the view hierarchy
                 */
                if (([self distanceFromDisplayCenter:marker] < [self distanceFromDisplayCenter:closestMarker]) &&
                    ![self markerViewIntersects:marker withClosestMarker:closestMarker]) {
                    closestMarker = marker;
                }
            }
            NSLog(@"closestMarker:%@", closestMarker.geoCoordinate.title);
        }
    }
    
    return closestMarker;
}
                    
- (CGFloat)distanceFromDisplayCenter:(MyMarkerView *)marker
{
    CGPoint markerPoint = marker.center;
    CGPoint centerPoint = CGPointMake(240.0, 160.0);
    CGFloat xDist = (markerPoint.x - centerPoint.x);
    CGFloat yDist = (markerPoint.y - centerPoint.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

/**
 * Detects if the 2 Marker views are intersecting
 */
- (BOOL)markerViewIntersects:(MyMarkerView *)markerView withClosestMarker:(MyMarkerView *)closestView
{
    if (CGRectIntersectsRect(markerView.frame, closestView.frame))
        return YES;

    return NO;
}

#pragma mark - Lazy getter

/**
 * Load OverlayView from xib
 */
- (OverlayView *)overlayView
{
    if (_overlayView == nil) {
        NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil]; 
        
        for (id view in xib) { 
            if ([view isKindOfClass:[OverlayView class]]) {
                self.overlayView = view;
                self.overlayView.delegate = self;
                break;
            }
        }
    }
    
    return _overlayView;
}

@end
