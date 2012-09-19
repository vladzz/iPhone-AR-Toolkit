//
//  MyMarkerView.h
//  ARKitDemo2
//
//  Modified by Yee Peng Chia on 9/19/12.
//  Copyright (c) 2012 Cocoa Star Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARMarkerView.h"

@interface MyMarkerView : ARMarkerView

@property (nonatomic, strong) UILabel *titleLabel;

- (id)initWithCoordinate:(ARGeoCoordinate *)coordinate;

@end
