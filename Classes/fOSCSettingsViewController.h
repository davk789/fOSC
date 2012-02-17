//
//  fOSCSettingsViewController.h
//  fOSC
//
//  Created by David Kendall on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>

@class fOSCDispatcher;

@interface fOSCSettingsViewController : UIViewController <UITextFieldDelegate> {
    UITextField *portField;
    UITextField *ipField;
    UILabel *localIPLabel;
    UISegmentedControl *protocolControl;
    fOSCDispatcher *dispatcher;
}

@property (retain, nonatomic) fOSCDispatcher *dispatcher;
@property (retain, nonatomic) IBOutlet UITextField *portField, *ipField;
@property (retain, nonatomic) IBOutlet UILabel *localIPLabel;
@property (retain, nonatomic) IBOutlet UISegmentedControl *protocolControl;

- (IBAction)updateIP:(id)sender;
- (IBAction)updatePort:(id)sender;
- (IBAction)setProtocol:(id)sender;

- (NSString *)getLocalIP;

- (id)initWithDispatcher:(fOSCDispatcher *)disp;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil dispatcher:(fOSCDispatcher *)disp;

@end
