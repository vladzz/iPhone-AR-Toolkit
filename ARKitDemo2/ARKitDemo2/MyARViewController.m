//
//  ARViewController.m
//  ARKitDemo
//
//  Modified by Niels W Hansen on 12/31/11.
//  Copyright 2011 Agilite Software. All rights reserved.
//

#import "MyARViewController.h"
#import "ARController.h"
#import "ARGeoCoordinate.h"
#import "MyMarkerView.h"

@interface MyARViewController (PrivateMethods)

- (MyMarkerView *)findClosestMarker;
- (CGFloat)distanceFromDisplayCenter:(MyMarkerView *)marker;
- (CGFloat)distanceFromCurrentLocation:(CLLocation *)location;

//- (void)postTweet:(NSString *)title withHashTag:(NSString *)hashtag;
//- (void)postTweetComplete:(NSString *)output;
//- (void)postTweetFailed:(NSError *)error;

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
 
    self.arController = [[ARController alloc] initWithViewController:self];
    self.arController.delegate = self;
    self.arController.debugMode = NO;   //YES;
	self.arController.scaleViewsBasedOnDistance = YES;
    self.arController.minimumScaleFactor = 0.2;
	self.arController.rotateViewsBasedOnPerspective = YES;

    // Create the ARGeoCoordinate object
    CLLocation *location = [[CLLocation alloc] initWithLatitude:40.709827 longitude:-74.010628];
    ARGeoCoordinate *coordinate = [ARGeoCoordinate coordinateWithLocation:location locationTitle:@"One Liberty Plaza"];
    MyMarkerView *marker = [[MyMarkerView alloc] initWithCoordinate:coordinate];
    coordinate.markerView = marker;
    [self.arController addCoordinate:coordinate];
    
    location = [[CLLocation alloc] initWithLatitude:40.710522 longitude:-74.009308];
    coordinate = [ARGeoCoordinate coordinateWithLocation:location locationTitle:@"Cafe Tomato"];
    marker = [[MyMarkerView alloc] initWithCoordinate:coordinate] ;
    coordinate.markerView = marker;
    [self.arController addCoordinate:coordinate];
    
    location = [[CLLocation alloc] initWithLatitude:40.709763 longitude:-74.008842];
    coordinate = [ARGeoCoordinate coordinateWithLocation:location locationTitle:@"Toasties"];
    marker = [[MyMarkerView alloc] initWithCoordinate:coordinate] ;
    coordinate.markerView = marker;
    [self.arController addCoordinate:coordinate];
    
    [self.view addSubview:self.overlayView];
    
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
//    self.overlayView.statusLabel.text = @"Location Updated";
//    
//    if (!self.poiModel.isLoading) {
//        [self.poiModel searchVenuesForLocation:newLocation];
//        self.overlayView.statusLabel.text = @"Load Venues";
//    }
}

- (void)didUpdateOrientation:(UIDeviceOrientation) orientation
{
//    NSLog(@"Orientation Updated");    
//    if (orientation == UIDeviceOrientationPortrait)
//        NSLog(@"Protrait");
//    self.overlayView.statusLabel.text = @"Orientation Updated";
}

// Called by agController when its locations are updated
- (void)didUpdateMarkers
{
//    NSLog(@"didUpdateMarkers:%d", [self.arController.displayView.subviews count]);
//    for (UIView *subview in self.agController.displayView.subviews) {
//        if ([subview isKindOfClass:[DTMarkerView class]]) {
//            [self.overlayView displayControls];
//            break;
//        }
//    }
}

//#pragma mark - ARLocationDelegate method
//
//- (NSMutableArray *)geoLocations 
//{
//    return self.poiModel.geoLocations;
//}

#pragma mark - DTPOIModel delegate methods

//- (void)poiModelSearchVenuesDidLoad
//{
//    int venuesCount = [self.poiModel.geoLocations count];
//    NSLog(@"poiModelSearchVenuesDidLoad:%d", venuesCount);
//    
//    self.overlayView.statusLabel.text = [NSString stringWithFormat:@"Venues Loaded:%d", venuesCount];
//    
//	if (venuesCount > 0) {
//		for (ARGeoCoordinate *coordinate in self.poiModel.geoLocations) {
////            NSLog(@"coordinate:%@", coordinate.title);
//			DTMarkerView *marker = [[DTMarkerView alloc] initForCoordinate:coordinate withDelgate:nil] ;
//            coordinate.markerView = marker;
//			[self.agController addCoordinate:coordinate];
//		}
//	}
//}

//- (void)poiModel:(DTPOIModel *)model searchVenuesDidFail:(NSError *)error
//{
//    NSLog(@"poiModelSearchVenuesDidFail");
//    self.overlayView.statusLabel.text = @"Venues Load Failed";
//    NSString *message = [[error userInfo] objectForKey:@"errorDetail"];
//    
//    if (error.code == kSearchNovenuesErrorCode) {
//        message = @"Search returned no venues. Please try again later.";
//    }
//    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Load Venues Error" 
//                                                        message:message
//                                                       delegate:nil 
//                                              cancelButtonTitle:NSLocalizedString(@"OK", @"") 
//                                              otherButtonTitles:nil];
//    [alertView show];
//}

#pragma mark - DTOverlayViewDelegate methods

//- (void)overlayView:(DTOverlayView *)overlayView didTweetWithHashTag:(NSString *)hashtag
//{
//    DTMarkerView *closestMarker = [self findClosestMarker];
//    NSLog(@"closestMarker:%@", closestMarker.coordinateInfo.title);
//
//    if (closestMarker != nil) {
//        [self postTweet:closestMarker.coordinateInfo.title withHashTag:hashtag];
//    }
//}

- (void)overlayViewTestDidTap:(OverlayView *)overlayView
{
    MyMarkerView *closestMarker = [self findClosestMarker];
    self.overlayView.statusLabel.text = closestMarker.coordinate.title;
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
                NSLog(@"%@: %f, %f", marker.coordinate.title, marker.center.x, marker.center.y);
//                NSLog(@"distance from center:%f", [self distanceFromDisplayCenter:marker]);
                if (
//                    ([self distanceFromCurrentLocation:[(MarkerView *)subview coordinateInfo].geoLocation] <
//                     [self distanceFromCurrentLocation:closestMarker.coordinateInfo.geoLocation]) &&
                    ([self distanceFromDisplayCenter:marker] < [self distanceFromDisplayCenter:closestMarker])) {
//                    ([subviews indexOfObject:subview] > [subviews indexOfObject:closestMarker])) {
                    closestMarker = marker;
                    NSLog(@"closestMarker:%@", closestMarker.coordinate.title);
                }
            }
        }
    }
    
    return closestMarker;
}
                    
- (CGFloat)distanceFromDisplayCenter:(MyMarkerView *)marker
{
//    CGPoint markerPoint = [marker convertPoint:marker.center toView:self.view];
    CGPoint markerPoint = marker.center;
    NSLog(@"marker:%@, markerPoint: %f, %f", marker.coordinate.title, markerPoint.x, markerPoint.y);
    CGPoint centerPoint = CGPointMake(240.0, 160.0);
    CGFloat xDist = (markerPoint.x - centerPoint.x);
    CGFloat yDist = (markerPoint.y - centerPoint.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

- (CGFloat)distanceFromCurrentLocation:(CLLocation *)location
{
    return [location distanceFromLocation:self.arController.centerLocation];
}

#pragma mark - Instance methods

//- (void)postTweet:(NSString *)title withHashTag:(NSString *)hashtag
//{
//	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
//    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//	
//    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
//        if(granted) {
//            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
//			if ([accountsArray count] > 0) {
//				ACAccount *account = [accountsArray objectAtIndex:0];
//                NSString *message = [NSString stringWithFormat:@"%@ is #%@. #drivebytweeting", title, hashtag];
//                NSLog(@"postTweet:%@", message);
//                
//                TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"]  
//                                                             parameters:[NSDictionary dictionaryWithObject:message forKey:@"status"] 
//                                                          requestMethod:TWRequestMethodPOST];
//                
//                [postRequest setAccount:account];
//                
//                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
//                    if (error) {
//                        [self performSelectorOnMainThread:@selector(postTweetFailed:) withObject:error waitUntilDone:NO];
//                    } else {                        
////                        NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
//                        [self performSelectorOnMainThread:@selector(postTweetComplete:) withObject:title waitUntilDone:NO];
//                    }        
//                }];
//            }
//        }
//    }];
//}

//- (void)postTweetComplete:(NSString *)output
//{
//    NSLog(@"postCompleteHandler:%@", output);
//    self.overlayView.statusLabel.text = [NSString stringWithFormat:@"Tweet Sent for %@", output];
//}
//
//- (void)postTweetFailed:(NSError *)error
//{
//    self.overlayView.statusLabel.text = @"Tweet Failed";
//}

#pragma mark - Lazy getter

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
