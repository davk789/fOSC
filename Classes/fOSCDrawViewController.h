//
//  fOSCDrawController.h
//  fOSC
//
//  Created by David Kendall on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class fOSCDispatcher, fOSCDrawView, CMMotionManager, CMAttitude;


@interface fOSCDrawViewController : UIViewController {
    fOSCDispatcher *dispatcher;
    NSMutableDictionary *points;
    fOSCDrawView *drawView;
    CMMotionManager *motionManager;
    CMAttitude *referenceAttitude;

}

@property (retain) fOSCDispatcher *dispatcher;

- (id)initWithDispatcher:(fOSCDispatcher *)disp;
- (void)sendOSCMsg:(NSString *)msg forPoints:(NSDictionary *)pts;


@end
