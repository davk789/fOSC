//
//  fOSCDrawView.h
//  fOSC
//
//  Created by David Kendall on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fOSCDispatcher.h"

#include <math.h>
#include <stdlib.h>

@class fOSCDrawViewController;

@interface fOSCDrawView : UIView {
	NSMutableDictionary *points;
}

@property (retain) NSMutableDictionary *points;
@end
