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

@synthesize geoCoordinate = _geoCoordinate;
@synthesize delegate = _delegate;
@synthesize startSize = _startSize;

/**
 * Redraws the view whenever the distanceFromOrigin property changes
 */
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context
{
    if ([keyPath isEqual:@"distanceFromOrigin"]) {
        [self setNeedsDisplay];
    }
}

/**
 * Explicit setter creates a reference back to the marker instance
 */
- (void)setGeoCoordinate:(ARGeoCoordinate *)coordinate
{
    _geoCoordinate = coordinate;
    _geoCoordinate.markerView = self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@ was touched!", self.geoCoordinate.title);
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
