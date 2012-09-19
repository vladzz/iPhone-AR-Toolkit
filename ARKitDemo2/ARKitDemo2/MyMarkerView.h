//
//  CoordinateView.h
//  AR Kit
//
//  Created by Niels W Hansen on 12/31/11.
//  Copyright 2011 Agilite Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARMarkerView.h"

@interface MyMarkerView : ARMarkerView

@property (nonatomic, strong) UILabel *titleLabel;

- (id)initWithCoordinate:(ARGeoCoordinate *)coordinate;

@end
