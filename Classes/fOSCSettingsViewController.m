//
//  fOSCSettingsViewController.m
//  fOSC
//
//  Created by David Kendall on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "fOSCSettingsViewController.h"

@implementation fOSCSettingsViewController

@synthesize portField, ipField, dispatcher;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil dispatcher:(fOSCDispatcher *)disp {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        self.dispatcher = disp;
        self.portField = [[UITextField alloc] init];
        self.ipField = [[UITextField alloc] init];
    }
    
    return self;
}

- (id)initWithDispatcher:(fOSCDispatcher *)disp {
    // how is this class being initialized?
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - actions

- (void)setDispatcher:(fOSCDispatcher *)oscDispatcher {
    dispatcher = oscDispatcher;
    [portField setText:dispatcher.ip];
    [ipField setText:[NSString stringWithFormat:@"%i", dispatcher.port]];
}

- (IBAction)updateIP:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = @"hostip";
    NSString *value = ipField.text;
    [defaults setObject:value forKey:key];
    self.dispatcher.ip = value;
    [defaults synchronize];
}

- (IBAction)updatePort:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = @"outport";
    NSString *value = portField.text;
    [defaults setObject:value forKey:key];
    self.dispatcher.port = [NSNumber numberWithInt:[value intValue]];
    [defaults synchronize];	
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    portField.delegate = self;
    ipField.delegate = self;

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *port = [prefs stringForKey:@"outport"];
    if (port) {
        self.portField.text = port;
    }
    else {
        NSLog(@"\nA problem occurred with the port number %@\n", port);
    }
    
    NSString *ip = [prefs stringForKey:@"hostip"];
    if (ip) {
        self.ipField.text = ip;
    }
    else {
        NSLog(@"\nA problem occurred with the ip address %@\n", ip);
    }
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [portField release];
    [ipField release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
