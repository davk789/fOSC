//
//  fOSCDrawController.m
//  fOSC
//
//  Created by David Kendall on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "fOSCDrawViewController.h"

#include <math.h>
#include <stdlib.h>

static UInt32 idCount = 0;

#pragma mark fOSC CATEGORIES

@interface NSNumber(fOSCAdditions)
+ (NSNumber *)generateID;
- (NSNumber *)widthUnitValue;
- (NSNumber *)heightUnitValue;
@end

@implementation NSNumber(fOSCAdditions)
+ (NSNumber *)generateID {
    idCount = ++idCount % 65536; // 2**16 available IDs. should be good enough for touch
    return [NSNumber numberWithInt:idCount];
}

- (NSNumber *)widthUnitValue {
    float scale = [self floatValue] / 768.0;
    NSNumber *unit = [NSNumber numberWithFloat:scale];
    return unit;
}

- (NSNumber *)heightUnitValue {
    float scale = [self floatValue] / 1024.0;
    NSNumber *unit = [NSNumber numberWithFloat:scale];
    return unit;
}

@end

@interface NSDictionary(fOSCAdditions)
- (NSNumber *)nearestKeyWithX:(int)x y:(int)y;
@end

@implementation NSDictionary(fOSCAdditions)
- (NSNumber *)nearestKeyWithX:(int)x y:(int)y {
    int voiceID = -1;
    
    float pointTotal = x + y;
    
    int runningDifference = 1024;
    
    for (id key in self) {
        CGPoint cgTouch = [[self objectForKey:key] CGPointValue];
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
@end

#pragma mark CLASS IMPLEMENTATION

@implementation fOSCDrawViewController

@synthesize dispatcher;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        points = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id)initWithDispatcher:(fOSCDispatcher *)disp {
    self = [super init];
    if (self) {
        points = [[NSMutableDictionary alloc] init];
        self.dispatcher = disp;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [points release];
    [drawView release];
    [super dealloc];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    fOSCDrawView *view = [[fOSCDrawView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [view setMultipleTouchEnabled:YES];
    self.view = view;
    drawView = view; // keep an extra reference to access the methods of the subclass
    
    [view release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//	return YES;
//}

#pragma mark - touch section

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches) {
		CGPoint location = [touch locationInView:drawView]; 
        NSValue *nsLocation = [NSValue valueWithCGPoint:location];
        NSNumber *voiceID = [NSNumber generateID];
        [points setObject:nsLocation forKey:voiceID];
        NSLog(@"\n/fOSC/start %@ %@", voiceID, nsLocation);
	}
    drawView.points = points;
    [self sendOSCMsg:@"/fOSC/start" forPoints:points];
	[drawView setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSMutableDictionary *removed = [[NSMutableDictionary alloc] init];
	for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:drawView];
        
        NSNumber *voiceID = [points nearestKeyWithX:location.x y:location.y];
        
        NSValue *point = [points objectForKey:voiceID];
        NSLog(@"\n/fOSC/end %@ %@", voiceID, point);
        [removed setObject:point forKey:voiceID];
        
		[points removeObjectForKey:voiceID];
	}
    drawView.points = points;

    [self sendOSCMsg:@"/fOSC/end" forPoints:removed];
	[drawView setNeedsDisplay];
    [removed autorelease];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    int i = 0;
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:drawView];
        NSValue *nsLocation = [NSValue valueWithCGPoint:location];
        NSNumber *voiceID = [points nearestKeyWithX:location.x y:location.y];
//        NSLog(@"\n/fOSC/move %@ %@", voiceID, nsLocation);
        [points setObject:nsLocation forKey:voiceID];
        ++i;
    }
    drawView.points = points;
    [self sendOSCMsg:@"/fOSC/move" forPoints:points];
	[drawView setNeedsDisplay];
}

- (void)sendOSCMsg:(NSString *)msg forPoints:(NSDictionary *)pts {
    int i = 0;
    for (id touchID in pts) {
        CGPoint cgPoint = [[pts objectForKey:touchID] CGPointValue];
        
        NSNumber *x = [[NSNumber numberWithInt:(int)cgPoint.x] widthUnitValue];
        NSNumber *y = [[NSNumber numberWithInt:(int)cgPoint.y] heightUnitValue];
        
        [dispatcher sendMsg:msg, touchID, x, y, nil];
        i++; 
    }

}

@end
