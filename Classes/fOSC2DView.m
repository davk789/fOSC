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

static UInt32 touchIDCount = 0;

+ (NSNumber *)newTouchID {
    touchIDCount = ++touchIDCount % 65536; // up to 2**16 note polyphony. should be good enough for touch
    return [NSNumber numberWithInt:touchIDCount];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        points = [[NSMutableDictionary alloc] init];
        self.multipleTouchEnabled = YES;
    }
    return self;
}
// touch event section

// action functions

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches) {
		CGPoint location = [touch locationInView:self]; 
		NSValue *nsLocation = [NSValue valueWithCGPoint:location];
        
        NSNumber *voiceID = [self touchIDWithX:location.x y:location.y];
        
        if ([voiceID intValue] < 0) {
            // only add a new point if an old one is not detected. this is a workaround, and will
            // not fix the core problems like touchEndeds not matching up properly with touchBegin
            [points setObject:nsLocation forKey:[[self class] newTouchID]];
        }
	}
    [dispatcher beginAction:points];
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSMutableDictionary *removed = [[NSMutableDictionary alloc] init];
	for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self];

        NSNumber *voiceID = [self touchIDWithX:location.x y:location.y];
        
        if ([voiceID intValue] < 0) {
            printf("\nThe fucking point has no neighbor. Ignoring now.");
            return;
        }

        NSValue *point = [points objectForKey:voiceID];
        [removed setObject:point forKey:voiceID];
        
		[points removeObjectForKey:voiceID];
	}
    [dispatcher endAction:removed];
	[self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    int i = 0;
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self];
        NSValue *nsLocation = [NSValue valueWithCGPoint:location];
        NSNumber *voiceID = [self touchIDWithX:location.x y:location.y];
        
        if ([voiceID intValue] < 0) {
            printf("\nThe fucking point has no neighbor. Ignoring now.");
            return;
        }

        [points setObject:nsLocation forKey:voiceID];
        ++i;
    }
    [dispatcher moveAction:points];
	[self setNeedsDisplay];
}

// action helpers

- (NSNumber *)touchIDWithX:(int)x y:(int)y {
    printf("\nx: %i\ty: %i", x, y);
    int voiceID = -1;
    
    float pointTotal = x + y;
    
    int runningDifference = 1024;
    
    for (id key in points) {
        CGPoint cgTouch = [[points objectForKey:key] CGPointValue];
        int touchX = cgTouch.x;
        int touchY = cgTouch.y;
        int touchTotal = touchX + touchY;
        float difference = abs(touchTotal - pointTotal);
        if (difference < runningDifference) {
            voiceID = [key intValue];
            runningDifference = difference;
        }
    }
    
    return [NSNumber numberWithInt:voiceID];
}


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
}


@end
