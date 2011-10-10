//
//  fOSCAppDelegate.h
//  fOSC
//
//  Created by David Kendall on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class fOSCViewController;

@interface fOSCAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    fOSCViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet fOSCViewController *viewController;

@end

