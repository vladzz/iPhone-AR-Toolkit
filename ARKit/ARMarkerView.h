//
//  ARMarkerView.h
//  ARKit
//
//  Created by Yee Peng Chia on 9/18/12.
//  Copyright (c) 2012 Cocoa Star Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARMarkerViewDelegate.h"

@class ARGeoCoordinate;

@interface ARMarkerView : UIView

@property (nonatomic,strong) ARGeoCoordinate *coordinate;
@property (nonatomic, weak) id <ARMarkerViewDelegate> delegate;

@property (nonatomic, assign) CGSize startSize;

@end
