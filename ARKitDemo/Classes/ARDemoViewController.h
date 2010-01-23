//
//  ARDemoViewController.h
//  ARKitDemo
//
//  Created by Niels W Hansen on 1/23/10.
//  Copyright 2010 Agilite Software. All rights reserved.
//

#import <UIKit/UIKit.h>



@class AugmentedRealityController;

@interface ARDemoViewController : UIViewController {
	AugmentedRealityController	*agController;
}

@property (nonatomic, retain) AugmentedRealityController *agController;

@end
