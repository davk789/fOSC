//
//  fOSC2DView.m
//  fOSC
//
//  Created by David Kendall on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "fOSC2DView.h"

#include <math.h>
#include <stdlib.h>

@implementation fOSC2DView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		points = [NSMutableArray arrayWithCapacity:NUMPOINTS];
    }
    return self;
}
// touch event section

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches) {
		NSLog(@"blah");
		CGPoint location = [touch locationInView:self]; 
		NSValue *nsLocation = [NSValue valueWithCGPoint:location];
		[points addObject:nsLocation];
	}
	//[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches) {
		int ind = [points count] - 1;
		[points removeObjectAtIndex:ind];
	}
	//[self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat color[4] = {1.0, 1.0, 0.0, 1.0};
	CGContextSetStrokeColor(context, color);
	CGContextSetFillColor(context, color);
	//for (int i = 0; i < [points count]; ++i) {
//	for (NSValue *val in points) {
//		///***********
//		CGPoint point = [val CGPointValue];
//		float x = (float)point.x * self.bounds.size.width;
//		float y = (float)point.y * self.bounds.size.height;
//		CGContextAddArc(context, x, y, 15, 0, M_PI * 2.0, 0);
//		CGContextFillPath(context);		
//	}
	
	
}

- (void)dealloc {
    [super dealloc];
}


@end
