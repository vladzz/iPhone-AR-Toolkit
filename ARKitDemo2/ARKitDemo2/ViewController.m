//
//  ViewController.m
//  ARKitDemo2
//
//  Created by Yee Peng Chia on 9/19/12.
//  Copyright (c) 2012 Cocoa Star Apps. All rights reserved.
//

#import "ViewController.h"
#import "ARKit.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize arViewController = _arViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)launchAR:(id)sender
{
    if (self.arViewController == nil) {
        if ([ARKit deviceSupportsAR]) {
            self.arViewController = [[MyARViewController alloc] init];
        }
    }

    [self presentViewController:self.arViewController animated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
        toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
    
    return YES;
}

@end
