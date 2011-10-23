//
//  fOSCViewController.h
//  fOSC
//
//  Created by David Kendall on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fOSC2DView.h"
#import "fOSCDispatcher.h"


@interface fOSCViewController : UIViewController {
    fOSC2DView *controlView;
    fOSCDispatcher *oscDispatcher;
}

@end

