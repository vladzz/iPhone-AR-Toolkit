//
//  MyARViewController.h
//  ARKitDemo2
//
//  Modified by Yee Peng Chia on 9/19/12.
//  Copyright (c) 2012 Cocoa Star Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARControllerDelegate.h"
#import "OverlayView.h"

@class ARController;

@interface MyARViewController : UIViewController <ARControllerDelegate, OverlayViewDelegate>

@property (nonatomic, strong) ARController *arController;
@property (nonatomic, strong) OverlayView *overlayView;

@end

