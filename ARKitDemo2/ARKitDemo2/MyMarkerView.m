//
//  MyMarkerView.m
//  ARKitDemo2
//
//  Modified by Yee Peng Chia on 9/19/12.
//  Copyright (c) 2012 Cocoa Star Apps. All rights reserved.
//

#import "MyMarkerView.h"
#import "ARGeoCoordinate.h"

#define BOX_WIDTH   100
#define BOX_HEIGHT  100

@implementation MyMarkerView

@synthesize titleLabel = _titleLabel;

#pragma mark - Initialization

- (id)initWithCoordinate:(ARGeoCoordinate *)coordinate
{
    self = [super initWithFrame:CGRectZero];
	
	if (self) {
        self.geoCoordinate = coordinate;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
        self.clipsToBounds = NO;
                
        // Create the title label
		self.titleLabel	= [[IPInsetLabel alloc] initWithFrame:CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT)];
        self.titleLabel.insets = UIEdgeInsetsMake(5, 5, 5, 5);
		self.titleLabel.numberOfLines = 3;
        self.titleLabel.backgroundColor = [UIColor clearColor];     
        self.titleLabel.font = [UIFont systemFontOfSize:17];
		self.titleLabel.textColor = [UIColor whiteColor];
		self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.text = [NSString stringWithFormat:@"%@\n%.3f km", self.geoCoordinate.title,
                                self.geoCoordinate.distanceFromOrigin];
        [self.titleLabel resizeHeightToFitText];
        
        CGRect labelFrame = self.titleLabel.frame;
        
        [self addSubview:self.titleLabel];
        
        CGRect targFrame = CGRectMake(0, 0, labelFrame.size.width, labelFrame.size.height);
        self.frame = targFrame;
        
        // Store the startSize
        self.startSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
	}
	
    return self;
}

#pragma mark - View lifecycle

- (void)drawRect:(CGRect)rect
{
    // Update the titleLabel
    self.titleLabel.text = [NSString stringWithFormat:@"%@\n%.3f km", self.geoCoordinate.title,
                            self.geoCoordinate.distanceFromOrigin];
    
    [self.titleLabel resizeHeightToFitText];
    
    CGRect labelFrame = self.titleLabel.frame;
    CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                              labelFrame.size.width, labelFrame.size.height);
    self.frame = frame;
}

@end
