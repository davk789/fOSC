//
//  fOSCViewController.m
//  fOSC
//
//  Created by David Kendall on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "fOSCViewController.h"
#import "fOSCDrawViewController.h"
#import "fOSCDispatcher.h"
#import "fOSCSettingsViewController.h"


@implementation fOSCViewController

@synthesize settingsButton;
@synthesize settingsController, drawController;
/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *ip = [prefs stringForKey:@"hostip"];
    if (!ip) {
        ip = @"192.168.1.100";
        [prefs setObject:ip forKey:@"hostip"];
        [prefs synchronize];
    }
    
    NSString *port = [prefs stringForKey:@"outport"];
    if (!port) {
        port = @"57200";
        [prefs setObject:port forKey:@"outport"];
        [prefs synchronize];
    }    
    
    oscDispatcher = [[fOSCDispatcher alloc] init];
    
    oscDispatcher.ip = ip;
    // probably should check for junk values here
    oscDispatcher.port = [NSNumber numberWithInt:[port intValue]];

    drawController = [[fOSCDrawViewController alloc] initWithDispatcher:oscDispatcher];
    
	[self.view insertSubview:drawController.view atIndex: 0];
    
    self.settingsButton.hidden = YES;
    
    [ip release];
    [port release];
    
}

- (void)resetView {
    if (self.drawController.view.superview == nil) {
        [settingsController.view removeFromSuperview];
        [self.view insertSubview:drawController.view atIndex:0];
    }
    self.settingsButton.hidden = YES;
}

- (IBAction)switchViews:(id)sender {
	[UIView beginAnimations:@"View Flip" context:nil];
	[UIView setAnimationDuration:1.25];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

    if (self.settingsController.view.superview == nil) {
        
        [self.settingsButton setHidden:YES];
        
        if (self.settingsController == nil) {
            fOSCSettingsViewController *contr = [[fOSCSettingsViewController alloc] initWithNibName:@"fOSCSettingsViewController"                   
                                                                                             bundle:nil
                                                                                         dispatcher:oscDispatcher];
            self.settingsController = contr;
            [contr release];
        }
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
        
		[drawController viewWillAppear:YES];
		[settingsController viewWillDisappear:YES];
		
		[drawController.view removeFromSuperview];
		[self.view insertSubview:settingsController.view atIndex:0];
        
		[settingsController viewDidDisappear:YES];
		[drawController viewDidAppear:YES];

    } else {
        [self.settingsButton setHidden:NO];
        if (self.drawController == nil) {
            fOSCDrawViewController *contr = [[fOSCDrawViewController alloc] initWithDispatcher:oscDispatcher];
            self.drawController = contr;
            [contr release];
        }
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
        
		[settingsController viewWillAppear:YES];
		[drawController viewWillDisappear:YES];
		
		[settingsController.view removeFromSuperview];
		[self.view insertSubview:drawController.view atIndex:0];
        
		[drawController viewDidDisappear:YES];
		[settingsController viewDidAppear:YES];
    }
    [UIView commitAnimations];
    
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // my app should support other orientations eventually
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
    [oscDispatcher release];
}

@end
