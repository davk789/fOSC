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
    UIButton *settingsButton;
    fOSCDrawViewController *drawController;
    fOSCSettingsViewController *settingsController;
    fOSCDispatcher *oscDispatcher;
}

@property (retain, nonatomic) IBOutlet UIButton *settingsButton;
@property (retain, nonatomic) fOSCSettingsViewController *settingsController;
@property (retain, nonatomic) fOSCDrawViewController *drawController;

- (IBAction)switchViews:(id)sender;
- (void)resetView;

@end

