//
//  MyMarkerView.m
//  ARKitDemo2
//
//  Modified by Yee Peng Chia on 9/19/12.
//  Copyright (c) 2012 Cocoa Star Apps. All rights reserved.
//

#import "MyMarkerView.h"
#import "ARGeoCoordinate.h"

#define BOX_WIDTH   150
#define BOX_HEIGHT  50
#define BOX_GAP     10
#define BOX_ALPHA   1.0
#define LABEL_HEIGHT 20.0

@implementation MyMarkerView

@synthesize titleLabel = _titleLabel;

- (id)initWithCoordinate:(ARGeoCoordinate *)coordinate
{
    self = [super initWithFrame:CGRectZero];
	
	if (self) {
        self.coordinate = coordinate;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
        self.clipsToBounds = NO;
                
        // Create the title label
		self.titleLabel	= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT)];
		self.titleLabel.numberOfLines = 3;
        self.titleLabel.backgroundColor = [UIColor clearColor];     
        self.titleLabel.font = [UIFont systemFontOfSize:18];
		self.titleLabel.textColor = [UIColor whiteColor];
		self.titleLabel.textAlignment = UITextAlignmentLeft;
        self.titleLabel.text = [NSString stringWithFormat:@"%@\n%.3f km", self.coordinate.title,
                                self.coordinate.distanceFromOrigin];
        
		[self.titleLabel sizeToFit];
        
        CGRect labelFrame = self.titleLabel.frame;
        labelFrame = CGRectMake(10, 10, labelFrame.size.width, labelFrame.size.height);
        self.titleLabel.frame = labelFrame;
        
        [self addSubview:self.titleLabel];
        
        CGRect targFrame = CGRectMake(0, 0, labelFrame.size.width+40, labelFrame.size.height+40);
        self.frame = targFrame;
        
        // Store the startSize
        self.startSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
	}
	
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Update the titleLabel
    self.titleLabel.text = [NSString stringWithFormat:@"%@\n%.3f km", self.coordinate.title,
                            self.coordinate.distanceFromOrigin];
}

@end
