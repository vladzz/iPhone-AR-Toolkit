//
//  ARViewController.h
//  ARKitDemo
//
//  Modified by Niels W Hansen on 12/31/11.
//  Copyright 2011 Agilite Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARControllerDelegate.h"
#import "OverlayView.h"

@class ARController;

@interface MyARViewController : UIViewController <ARControllerDelegate, OverlayViewDelegate>

@property (nonatomic, strong) ARController *arController;
@property (nonatomic, strong) OverlayView *overlayView;

@end

