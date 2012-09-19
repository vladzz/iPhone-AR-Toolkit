//
//  ARGeoCoordinate.h
//  AR Kit
//
//  Created by Haseman on 8/1/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ARCoordinate.h"

@interface ARGeoCoordinate : ARCoordinate

@property (nonatomic, strong) CLLocation *geoLocation;
@property (nonatomic, strong) UIView *markerView;
@property (nonatomic, assign) double distanceFromOrigin;

- (float)angleFromCoordinate:(CLLocationCoordinate2D)first toCoordinate:(CLLocationCoordinate2D)second;

- (void)calibrateUsingOrigin:(CLLocation *)origin;

+ (ARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location locationTitle:(NSString*)titleOfLocation;

+ (ARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location fromOrigin:(CLLocation *)origin;


@end
