//
//  fOSCDrawController.h
//  fOSC
//
//  Created by David Kendall on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fOSCDispatcher.h"
#import "fOSCDrawView.h"

@interface fOSCDrawViewController : UIViewController {
    fOSCDispatcher *dispatcher;
    NSMutableDictionary *points;
    fOSCDrawView *drawView;
}

@property (retain) fOSCDispatcher *dispatcher;

- (id)initWithDispatcher:(fOSCDispatcher *)disp;
- (void)sendOSCMsg:(NSString *)msg forPoints:(NSDictionary *)pts;


@end
