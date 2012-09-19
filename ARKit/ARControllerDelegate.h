//
//  ARControllerDelegate.h
//  ARKit
//
//  Created by Yee Peng Chia on 9/5/12.
//  Copyright (c) 2012 Cocoa Star Apps, Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

@protocol ARControllerDelegate <NSObject>

- (void)didUpdateHeading:(CLHeading *)newHeading;
- (void)didUpdateLocation:(CLLocation *)newLocation;
- (void)didUpdateOrientation:(UIDeviceOrientation)orientation;
- (void)didUpdateMarkers;

@end
