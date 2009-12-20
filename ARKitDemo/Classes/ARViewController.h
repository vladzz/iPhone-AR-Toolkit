//
//  ARKViewController.h
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
//  Updated by Niels Hansen 12/19/09
//  Copyright 2009 Agilite Software. All rights reserved.
//

@class AugmentedReality;

@interface ARViewController : UIViewController  {

	UIImagePickerController *cameraController;
	AugmentedReality *agController;
}

@property (nonatomic, retain) UIImagePickerController *cameraController;
@property (nonatomic, retain) AugmentedReality *agController;

@end
