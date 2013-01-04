//
//  ARViewController.h
//  ARKitDemo
//
//  Modified by Niels W Hansen on 12/31/11.
//  Modified by Ed Rackham (a1phanumeric) 2013
//

#import <UIKit/UIKit.h>
#import "ARLocationDelegate.h"
#import "ARViewProtocol.h"

@class AugmentedRealityController;

@interface ARViewController : UIViewController<ARMarkerDelegate, ARDelegate>

@property (nonatomic, assign) id<ARLocationDelegate> delegate;

@property (assign, nonatomic, setter = setDebugMode:)                       BOOL debugMode;
@property (assign, nonatomic, setter = setShowsRadar:)                      BOOL showsRadar;
@property (assign, nonatomic, setter = setScaleViewsBasedOnDistance:)       BOOL scaleViewsBasedOnDistance;
@property (assign, nonatomic, setter = setMinimumScaleFactor:)              float minimumScaleFactor;
@property (assign, nonatomic, setter = setRotateViewsBasedOnPerspective:)   BOOL rotateViewsBasedOnPerspective;

- (id)initWithDelegate:(id<ARLocationDelegate>)aDelegate;

@end

