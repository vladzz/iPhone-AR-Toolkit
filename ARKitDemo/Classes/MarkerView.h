//
//  CoordinateView.h
//  AR Kit
//
//  Created by Niels W Hansen on 12/19/09.
//  Copyright 2011 Agilite Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARViewProtocol.h"

@class ARGeoCoordinate;

@interface MarkerView : UIView {
    ARGeoCoordinate *coordinateInfo;
    id<ARViewProtocol> delegate;
}

- (id)initForCoordinate:(ARGeoCoordinate *)coordinate withDelgate:(id<ARViewProtocol>) aDelegate;

@property (nonatomic,retain) ARGeoCoordinate *coordinateInfo;
@property (nonatomic, assign) id<ARViewProtocol> delegate;
@property (nonatomic, retain) UILabel *lblDistance;


@end
