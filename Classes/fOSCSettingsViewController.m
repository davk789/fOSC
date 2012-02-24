//
//  fOSCSettingsViewController.m
//  fOSC
//
//  Created by David Kendall on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "fOSCSettingsViewController.h"
#import "fOSCDispatcher.h"
// used in getLocalIP only
#import <ifaddrs.h>
#import <arpa/inet.h>

#define TCP_DISABLED YES

@implementation fOSCSettingsViewController

@synthesize portField, ipField, protocolControl, localIPLabel, dispatcher;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil dispatcher:(fOSCDispatcher *)disp {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        self.dispatcher = disp;
        self.portField = [[UITextField alloc] init];
        self.ipField = [[UITextField alloc] init];
        if(TCP_DISABLED) {
            self.protocolControl.hidden = YES;
        }
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

- (IBAction)updateProtocol:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = @"protocol";
    NSString *value = [NSString stringWithFormat:@"%i", protocolControl.selectedSegmentIndex];
    [defaults setObject:value forKey:key];
    self.dispatcher.protocol = [NSNumber numberWithInt:protocolControl.selectedSegmentIndex];
    [defaults synchronize];
}

// copied directly from http://stackoverflow.com/questions/7072989/iphone-ipad-how-to-get-my-ip-address-programmatically
- (NSString *)getLocalIP {    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];               
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    portField.delegate = self;
    ipField.delegate = self;
    
    [self.dispatcher disconnect];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // probably should verify the data here
    NSString *port = [prefs stringForKey:@"outport"];
    if (port) {
        self.portField.text = port;
    }
    
    NSString *ip = [prefs stringForKey:@"hostip"];
    if (ip) {
        self.ipField.text = ip;
    }
    
    NSString *localIP = [self getLocalIP];
    self.localIPLabel.text = localIP;
    
    NSString *protocol = [prefs stringForKey:@"protocol"];
    if (protocol) {
        self.protocolControl.selectedSegmentIndex = [protocol intValue];
    }
    
}

- (void)viewWillUnload {
    // this should work because I am freeing the view when switching over to the draw view
    [self.dispatcher connect];

}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [portField release];
    [ipField release];
    [protocolControl release];
    [localIPLabel release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
