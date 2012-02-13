//
//  fOSCDrawController.h
//  fOSC
//
//  Created by David Kendall on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class fOSCDispatcher;
@class fOSCDrawView;

@interface fOSCDrawViewController : UIViewController {
    fOSCDispatcher *dispatcher;
    NSMutableDictionary *points;
    fOSCDrawView *drawView;
}

@property (retain) fOSCDispatcher *dispatcher;

- (id)initWithDispatcher:(fOSCDispatcher *)disp;
- (void)sendOSCMsg:(NSString *)msg forPoints:(NSDictionary *)pts;


@end
