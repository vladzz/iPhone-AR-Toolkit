//
//  ARMarkerViewDelegate.h
//  ARKit
//
//  Created by Yee Peng Chia on 9/18/12.
//  Copyright (c) 2012 Cocoa Star Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ARMarkerView;

@protocol ARMarkerViewDelegate <NSObject>

@optional
- (void)markerViewDidTap:(ARMarkerView *)markerView;

@end
