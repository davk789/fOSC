//
//  fOSCViewController.h
//  fOSC
//
//  Created by David Kendall on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fOSCDrawViewController.h"
#import "fOSCDispatcher.h"
#import "fOSCSettingsViewController.h"

@interface fOSCViewController : UIViewController {
    fOSCDrawViewController *drawController;
    fOSCSettingsViewController *settingsController;
    fOSCDispatcher *oscDispatcher;
}

@end

