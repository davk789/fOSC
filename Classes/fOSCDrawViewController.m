//
//  fOSCDrawController.m
//  fOSC
//
//  Created by David Kendall on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "fOSCDrawViewController.h"
#import "fOSCDispatcher.h"
#import "fOSCDrawView.h"
#include <math.h>
#include <stdlib.h>
#import <CoreMotion/CoreMotion.h>
#import <Foundation/Foundation.h>

static UInt32 idCount = 0;
#define MOTION_REFRESH_RATE 45.0
#define ACCEL_GAIN 0.9

#pragma mark fOSC CATEGORIES

@interface NSNumber(fOSCAdditions)
- (NSNumber *)clip;
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

#pragma mark - CLASS IMPLEMENTATION

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

#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = 1.0 / MOTION_REFRESH_RATE;
    
    [motionManager startDeviceMotionUpdates];
    
    fOSCDrawView *view = [[fOSCDrawView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [view setMultipleTouchEnabled:YES];
    self.view = view;
    drawView = view; // keep an extra reference to access the methods of the subclass
    [view release];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [motionManager stopDeviceMotionUpdates];
    [motionManager release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//	return YES;
//}

#pragma mark utility functions



- (void)sendOSCMsg:(NSString *)msg forPoints:(NSDictionary *)pts {
    int i = 0;
    
    CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
    CMAttitude *attitude = deviceMotion.attitude;
    CMAcceleration userAccel = deviceMotion.userAcceleration;
    
    if (referenceAttitude) {
        [attitude multiplyByInverseOfAttitude:referenceAttitude];
    }
    
    for (id touchID in pts) {
        CGPoint cgPoint = [[pts objectForKey:touchID] CGPointValue];
        
        NSNumber *x = [[NSNumber numberWithInt:(int)cgPoint.x] widthUnitValue];
        NSNumber *y = [[NSNumber numberWithInt:(int)cgPoint.y] heightUnitValue];
        NSNumber *pitch = [NSNumber numberWithFloat:(attitude.pitch/M_PI)];
        NSNumber *roll = [NSNumber numberWithFloat:(attitude.roll/M_PI)];
        NSNumber *yaw = [NSNumber numberWithFloat:(attitude.yaw/M_PI)];
        
        NSNumber *accX = [NSNumber numberWithFloat:MIN(MAX(userAccel.x * ACCEL_GAIN, -1.0), 1.0)];
        NSNumber *accY = [NSNumber numberWithFloat:MIN(MAX(userAccel.y * ACCEL_GAIN, -1.0), 1.0)];
        NSNumber *accZ = [NSNumber numberWithFloat:MIN(MAX(userAccel.z * ACCEL_GAIN, -1.0), 1.0)];
        
        [dispatcher sendMsg:msg, touchID, x, y, pitch, roll, yaw, accX, accY, accZ, nil];
        i++; 
    }
    
}

#pragma mark touch section

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if ([points count] == 0) {
        CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
        CMAttitude *attitude = deviceMotion.attitude;
        referenceAttitude = [attitude retain];
    }

    for (UITouch *touch in touches) {
		CGPoint location = [touch locationInView:drawView]; 
        NSValue *nsLocation = [NSValue valueWithCGPoint:location];
        NSNumber *voiceID = [NSNumber generateID];
        [points setObject:nsLocation forKey:voiceID];
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
        [points setObject:nsLocation forKey:voiceID];
        ++i;
    }
    drawView.points = points;
    [self sendOSCMsg:@"/fOSC/move" forPoints:points];
	[drawView setNeedsDisplay];
}

@end
