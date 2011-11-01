//
//  fOSC2DView.h
//  fOSC
//
//  Created by David Kendall on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fOSCDispatcher.h"

#include <math.h>
#include <stdlib.h>

@interface fOSC2DView : UIView {
	NSMutableDictionary *points;
    fOSCDispatcher *dispatcher;
}

+ (NSNumber *)newTouchID;

@property (retain) fOSCDispatcher *dispatcher;

- (NSNumber *)touchIDWithX:(int)x y:(int)y;

@end
