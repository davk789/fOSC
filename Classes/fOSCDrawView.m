//
//  fOSCDrawView.m
//  fOSC
//
//  Created by David Kendall on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "fOSCDrawView.h"


@implementation fOSCDrawView

@synthesize points;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        points = [[NSMutableDictionary alloc] init];
        self.multipleTouchEnabled = YES;
    }
    return self;
}
// touch event section


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	CGContextRef context = UIGraphicsGetCurrentContext();
    // optimize this by clearing only the area around the previous circles, do this later

    CGFloat bg[4] = {0.3, 0.45, 0.55, 1.0};
    CGContextSetFillColor(context, bg);
    CGContextFillRect(context, self.bounds);
    
	CGFloat color[4] = {1.0, 1.0, 0.0, 1.0};
	CGContextSetStrokeColor(context, color);
	CGContextSetFillColor(context, color);

	for (id key in points) {
		CGPoint point = [[points objectForKey:key] CGPointValue];
		float x = (float)point.x;
		float y = (float)point.y;
		CGContextAddArc(context, x, y, 35, 0, M_PI * 2.0, 0);
		CGContextFillPath(context);		
	}
	
	
}

- (void)dealloc {
    [super dealloc];
    [points release];
}


@end
