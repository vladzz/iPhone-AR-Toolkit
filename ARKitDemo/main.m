//
//  main.m
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
// Updated by Niels Hansen 9/11/11
//  Copyright Agilite Software 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARKitDemoAppDelegate.h"


int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([ARKitDemoAppDelegate class]));
    [pool release];
    return retVal;
}
