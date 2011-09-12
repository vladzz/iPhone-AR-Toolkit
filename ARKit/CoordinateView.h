//
//  CoordinateView.h
//  iPhoneAugmentedRealityLib
//
//  Created by Niels W Hansen on 12/19/09.
//  Copyright 2009 Agilite Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ARCoordinate;

@interface CoordinateView : UIView {
	NSString *title;
}

- (id)initForCoordinate:(ARCoordinate *)coordinate;

@property (nonatomic,retain) NSString *title;
@end
