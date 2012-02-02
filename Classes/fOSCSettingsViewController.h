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
    UITextField *portField;
    UITextField *ipField;
    UILabel *localIPLabel;
    fOSCDispatcher *dispatcher;
}

@property (retain, nonatomic) fOSCDispatcher *dispatcher;
@property (retain, nonatomic) IBOutlet UITextField *portField, *ipField;
@property (retain, nonatomic) IBOutlet UILabel *localIPLabel;

- (IBAction)updateIP:(id)sender;
- (IBAction)updatePort:(id)sender;

- (void)getLocalIP;

- (id)initWithDispatcher:(fOSCDispatcher *)disp;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil dispatcher:(fOSCDispatcher *)disp;

@end
