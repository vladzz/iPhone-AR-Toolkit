//
//  OverlayView.h
//  ARKitDemo2
//
//  Created by Yee Peng Chia on 9/18/12.
//  Copyright (c) 2012 Cocoa Star Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OverlayView;

@protocol OverlayViewDelegate <NSObject>

- (void)overlayViewTestDidTap:(OverlayView *)overlayView;

@end

@interface OverlayView : UIView

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) id <OverlayViewDelegate> delegate;

- (IBAction)testClick:(id)sender;

@end
