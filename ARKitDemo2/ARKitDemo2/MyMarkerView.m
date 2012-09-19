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
    self = [super initWithFrame:CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT)];
	
	if (self) {
        self.coordinate = coordinate;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
                
		self.titleLabel	= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT)];
		self.titleLabel.numberOfLines = 3;
		self.titleLabel.backgroundColor = [UIColor colorWithWhite:.3 alpha:BOX_ALPHA];
        self.titleLabel.font = [UIFont systemFontOfSize:18];
		self.titleLabel.textColor = [UIColor whiteColor];
		self.titleLabel.textAlignment = UITextAlignmentLeft;
        self.titleLabel.text = [NSString stringWithFormat:@"%@\n%@m", self.coordinate.title,
                                [NSNumber numberWithDouble:self.coordinate.distanceFromOrigin]];
        
		[self.titleLabel sizeToFit];
        [self addSubview:self.titleLabel];
        
        self.frame = self.titleLabel.frame;
        
        // Store the startSize
        self.startSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
	}
	
    return self;
}

@end
