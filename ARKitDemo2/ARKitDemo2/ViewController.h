//
//  ViewController.h
//  ARKitDemo2
//
//  Created by Yee Peng Chia on 9/19/12.
//  Copyright (c) 2012 Cocoa Star Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyARViewController.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) MyARViewController *arViewController;

- (IBAction)launchAR:(id)sender;

@end
