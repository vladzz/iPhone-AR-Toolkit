//
//  ARViewProtocol.h
//  AR Kit
//
//  Created by Niels Hansen on 9/12/11.
//  Copyright 2011 Agilite Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ARGeoCoordinate;

@protocol ARViewProtocol <NSObject>
-(void) viewClicked:(ARGeoCoordinate *) coordinate;
@end

@protocol ARProtocol <NSObject>
-(void) headingUpdated:(int) value;

@end
