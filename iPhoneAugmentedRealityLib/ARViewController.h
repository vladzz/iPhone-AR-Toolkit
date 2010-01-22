//
//  ARKViewController.h
//  iPhoneAugmentedRealityLib
//
//  Created by Zac White on 8/1/09.
//  Updated by Niels Hansen 12/19/09
//  Copyright 2009 Agilite Software. All rights reserved.
//
#import <UIKit/UIKit.h>

@class AugmentedRealityController;

@interface ARViewController : UIViewController  {

	UIImagePickerController		*cameraController;
	AugmentedRealityController	*agController;
}

@property (nonatomic, retain) UIImagePickerController *cameraController;
@property (nonatomic, retain) AugmentedRealityController *agController;

@end
