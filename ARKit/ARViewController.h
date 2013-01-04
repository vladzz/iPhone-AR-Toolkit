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

@property (nonatomic, retain) AugmentedRealityController *agController;
@property (nonatomic, assign) id<ARLocationDelegate> delegate;

- (id)initWithDelegate:(id<ARLocationDelegate>)aDelegate;

@end

