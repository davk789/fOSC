//
//  fOSCViewController.m
//  fOSC
//
//  Created by David Kendall on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "fOSCViewController.h"

@implementation fOSCViewController


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
	// running my entire app here (for now)
    [super viewDidLoad];
    
    drawController = [[fOSCDrawViewController alloc] init];
    oscDispatcher = [[fOSCDispatcher alloc] init];
    [drawController setDispatcher:oscDispatcher];

    
    settingsController = [[fOSCSettingsViewController alloc] init];
//	[self.view addSubview:[drawController view]];
    
    [self.view addSubview:[settingsController view]];
    
    
    
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // the view does not resize when switching orientations. I will fix this later. leave the defaults for now.
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
    [drawController release];
    [oscDispatcher release];
    [settingsController release];
}

@end
