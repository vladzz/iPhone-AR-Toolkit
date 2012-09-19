//
//  ARMarkerView.m
//  ARKit
//
//  Created by Yee Peng Chia on 9/18/12.
//  Copyright (c) 2012 Cocoa Star Apps. All rights reserved.
//

#import "ARMarkerView.h"
#import "ARGeoCoordinate.h"

@implementation ARMarkerView

@synthesize coordinate = _coordinate;
@synthesize delegate = _delegate;
@synthesize startSize = _startSize;

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context
{
    if ([keyPath isEqual:@"distanceFromOrigin"]) {
//        NSString* changedName = [change objectForKey:NSKeyValueChangeNewKey];
        // do something with the changedName - call a method or update the UI here
//        self.nameLabel.text = changedName;
        [self setNeedsDisplay];
    }
}

/**
 * Explicit setter creates a reference back to the marker instance
 */
- (void)setCoordinate:(ARGeoCoordinate *)coordinate
{
    _coordinate = coordinate;
    _coordinate.markerView = self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@ was touched!", self.coordinate.title);
    [self.delegate markerViewDidTap:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.frame, point))
        return YES; // touched the view;
    
    return NO;
}

@end
