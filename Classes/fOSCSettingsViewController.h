//
//  fOSCSettingsViewController.h
//  fOSC
//
//  Created by David Kendall on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "fOSCDispatcher.h"

@interface fOSCSettingsViewController : UIViewController <UITextFieldDelegate> {
    UITextField *portField; // the default text will display this value, from the dispatcher
    UITextField *ipField;
    fOSCDispatcher *dispatcher;
}

@property (retain, nonatomic) fOSCDispatcher *dispatcher;
@property (retain, nonatomic) IBOutlet UITextField *portField, *ipField;

- (IBAction)updateIP:(id)sender;
- (IBAction)updatePort:(id)sender;

- (id)initWithDispatcher:(fOSCDispatcher *)disp;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil dispatcher:(fOSCDispatcher *)disp;

@end
