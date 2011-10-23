//
//  fOSC2DView.m
//  fOSC
//
//  Created by David Kendall on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "fOSC2DView.h"


@implementation fOSC2DView

@synthesize dispatcher;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        points = [[NSMutableArray alloc] init];
        self.multipleTouchEnabled = YES;
    }
    return self;
}
// touch event section

// action functions -- turn these in to callbacks or something

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches) {
		CGPoint location = [touch locationInView:self]; 
		NSValue *nsLocation = [NSValue valueWithCGPoint:location];
		[points addObject:nsLocation];
	}
    //if (dispatcher != NULL)
    [dispatcher beginAction:points];
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSMutableArray *removed = [[NSMutableArray alloc] init];
	for (UITouch *touch in touches) {
		int ind = [points count] - 1;
        [removed addObject:[points objectAtIndex:ind]];
		[points removeObjectAtIndex:ind];
	}
    [dispatcher endAction:removed];
	[self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [dispatcher endAction:points];
	for (UITouch *touch in touches) {
		int ind = [points count] - 1;
		[points removeObjectAtIndex:ind];
	}
	[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    int i = 0;
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self];
        NSValue *nsLocation = [NSValue valueWithCGPoint:location];
        [points replaceObjectAtIndex:i withObject:nsLocation];
        ++i;
    }
    [dispatcher moveAction:points];
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat color[4] = {1.0, 1.0, 0.0, 1.0};
	CGContextSetStrokeColor(context, color);
	CGContextSetFillColor(context, color);
    // optimize this by clearing only the area around the previous circles, do this later
    CGContextClearRect(context, self.bounds);
	for (NSValue *val in points) {
		CGPoint point = [val CGPointValue];
		float x = (float)point.x;
		float y = (float)point.y;
		CGContextAddArc(context, x, y, 35, 0, M_PI * 2.0, 0);
		CGContextFillPath(context);		
	}
	
	
}

- (void)dealloc {
    [super dealloc];
}


@end
