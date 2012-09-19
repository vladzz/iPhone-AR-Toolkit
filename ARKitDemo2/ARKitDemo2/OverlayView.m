//
//  OverlayView.m
//  ARExample
//
//  Created by Peng on 9/18/12.
//  Copyright (c) 2012 Cocoa Star Apps. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView

@synthesize statusLabel = _statusLabel;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)testClick:(id)sender
{
    [self.delegate overlayViewTestDidTap:self];
}

@end
