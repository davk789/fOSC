//
//  fOSCDispatcher.m
//  fOSC
//
//  Created by David Kendall on 10/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "fOSCDispatcher.h"

@implementation fOSCMessenger

- (id)init
{
    self = [super init];
    if (self) {
        // initialize variables
        socket = [[AsyncUdpSocket alloc] init];
        port = [[NSNumber numberWithInt:57200] retain];
        ip = @"192.168.1.103";
    }
    
    return self;
}

- (id)sendMsg:(id)first, ... {
    // collect the arguments in msg
    va_list args;
    va_start(args, first);
    NSMutableArray *msg = [[NSMutableArray alloc] init];
    id obj;
    for (obj = first; obj != nil; obj = va_arg(args, id)) {
        
        [msg addObject:obj];
    }
    // use the msg to get the properly formatted binary data to send
    NSData *outData = [self fOSCDataWithAddress:[msg objectAtIndex:0] 
                                     identifier:(NSNumber *)[msg objectAtIndex:1]
                                              x:(NSNumber *)[msg objectAtIndex:2]
                                              y:(NSNumber *)[msg objectAtIndex:3]];
    // ... and then send
    [socket sendData:outData toHost:ip port:[port intValue] withTimeout:-1 tag:1];
    
    return self;
}

- (NSData *)fOSCDataWithAddress:(NSString *)addr identifier:(NSNumber *)i x:(NSNumber *)x y:(NSNumber *)y {
    // specifically, just make the osc data for this fOSC version. worry about reusability later
    NSMutableData *data = [NSMutableData data];
    
    NSData *msgAddr = [[self oscString:addr] dataUsingEncoding:NSASCIIStringEncoding];
    NSData *tags = [[self oscString:@",iff"] dataUsingEncoding:NSASCIIStringEncoding];
    SInt32 swapI = [self swapInt:i];
    CFSwappedFloat32 swapX = [self swapFloat:x];
    CFSwappedFloat32 swapY = [self swapFloat:y];
    NSData *iArg = [NSData dataWithBytes:&swapI length:4];
    NSData *xArg = [NSData dataWithBytes:&swapX length:4];
    NSData *yArg = [NSData dataWithBytes:&swapY length:4];
    
    [data appendData:msgAddr];
    [data appendData:tags];
    [data appendData:iArg];
    [data appendData:xArg];
    [data appendData:yArg];
    
    return data;
}

- (NSString *)oscString:(NSString *)str {
    // Copied straight from the Pony Express example
    // string + 1 null in termination + 0-3 nulls in padding for 4-byte alignment
    NSUInteger numberOfNulls = 4 - (str.length & 3);
    return [str stringByPaddingToLength:str.length+numberOfNulls withString:@"\0" startingAtIndex:0];
}

- (SInt32)swapInt:(NSNumber *)inVal {
    // also copied straight from the pony express example.
    // byte swap the integer value to adopt OSC's endianness
    SInt32 value = 0;
    CFNumberGetValue((CFNumberRef)inVal, kCFNumberSInt32Type, &value);
    SInt32 swappedValue = CFSwapInt32HostToBig(value);
    return swappedValue;
}

- (CFSwappedFloat32)swapFloat:(NSNumber *)inVal {
    Float32 value = 0;
    CFNumberGetValue((CFNumberRef)inVal, kCFNumberFloat32Type, &value);
    CFSwappedFloat32 swappedValue = CFConvertFloat32HostToSwapped(value);
    return swappedValue;
}




@end

@implementation fOSCDispatcher

/**
 do all the logic to manage the osc data.
 */

- (id)init
{
    self = [super init];
    if (self) {
        messenger = [[fOSCMessenger alloc] init];
        touches = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)beginAction:(NSDictionary *)points {
    [self sendMessage:@"/fOSC/start" withPoints:points];
}

- (void)moveAction:(NSDictionary *)points {
    [self sendMessage:@"/fOSC/move" withPoints:points];
}

- (void)endAction:(NSDictionary *)points {
    [self sendMessage:@"/fOSC/end" withPoints:points];
}

- (NSNumber *)voiceIDWithX:(float)x y:(float)y {
    NSLog(@"fuck\n");
    return [NSNumber numberWithInt:0];
}

- (void)sendMessage:(NSString *)msg withPoints:(NSDictionary *)points {
    int i = 0;
    for (id touchID in points) {
        CGPoint cgPoint = [[points objectForKey:touchID] CGPointValue];
        
		NSNumber *x = [self xValueToUnit:(int)cgPoint.x];
		NSNumber *y = [self yValueToUnit:(int)cgPoint.y];
        float fX = [x floatValue]; // DEBUG
        float fY = [y floatValue]; // DEBUG
        int indInt = [touchID intValue]; // DEBUG
        printf("\ni: %i:\tx: %f\ty: %f\t%s", indInt, fX, fY, [msg UTF8String]);
        
        [messenger sendMsg:msg, touchID, x, y, nil];
        i++; 
    }
}

- (NSNumber *)xValueToUnit:(int)x {
    float scale = (float)x / 768.0;
    NSNumber *unit = [NSNumber numberWithFloat:scale];
    
    return unit;
}

- (NSNumber *)yValueToUnit:(int)y {
    float scale = (float)y / 1024.0;
    NSNumber *unit = [NSNumber numberWithFloat:scale];
    return unit;
}


@end



