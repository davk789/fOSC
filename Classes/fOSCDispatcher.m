//
//  fOSCDispatcher.m
//  fOSC
//
//  Created by David Kendall on 10/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "fOSCDispatcher.h"

@implementation fOSCDispatcher

- (id)init
{
    self = [super init];
    if (self) {
        // initialize variables
        socket = [[AsyncUdpSocket alloc] init];
        port = [[NSNumber numberWithInt:57199] retain];
        ip = @"192.168.1.101"; // pointing at the mac right now
        bufferSize = 6000;
    }
    
    return self;
}

- (void)beginAction:(NSArray *)points {
    for (NSValue *nsPoint in points) {
        CGPoint cgPoint = [nsPoint CGPointValue];
		float x = (float)cgPoint.x;
		float y = (float)cgPoint.y;
        [self sendMsg: @"/fOSC/on", [NSNumber numberWithFloat:x], [NSNumber numberWithFloat:y], nil];
//        NSData *bundle = [NSData dataWithBytes:<#(const void *)#> length:<#(NSUInteger)#>];
    }
    NSLog(@"\nBegin:\n%@", points);
}

- (void)moveAction:(NSArray *)points {
    for (NSValue *nsPoint in points) {
        CGPoint cgPoint = [nsPoint CGPointValue];
		float x = (float)cgPoint.x;
		float y = (float)cgPoint.y;
        [self sendMsg: @"/fOSC/move", [NSNumber numberWithFloat:x], [NSNumber numberWithFloat:y], nil];
        //        NSData *bundle = [NSData dataWithBytes:<#(const void *)#> length:<#(NSUInteger)#>];
    }
}

- (void)endAction:(NSArray *)points {
    for (NSValue *nsPoint in points) {
        CGPoint cgPoint = [nsPoint CGPointValue];
		float x = (float)cgPoint.x;
		float y = (float)cgPoint.y;
        NSLog(@"%f %f", x, y);
        [self sendMsg: @"/fOSC/off", [NSNumber numberWithFloat:x], [NSNumber numberWithFloat:y], nil];

        //        NSData *bundle = [NSData dataWithBytes:<#(const void *)#> length:<#(NSUInteger)#>];
    }
}

// interface section -- maybe separate this out to its own class

- (id)sendMsg:(id)first, ... {
    // collect the arguments in msg
    va_list args;
    va_start(args, first);
    NSMutableArray *msg = [[NSMutableArray alloc] init];
    id obj;
    for (obj = first; obj != nil; obj = va_arg(args, id)) {

        [msg addObject:obj];
    }
    
//    // prepare the osc message buf
//    OSCbuf myBuf;
//    OSCbuf *buf = &myBuf;
//    char bytes[bufferSize];
//    OSC_initBuffer(buf, bufferSize, bytes); // sizeof string
//    
//    OSCTimeTag tt = OSCTT_CurrentTime();
//    OSC_openBundle(buf, tt);
//    
//    // write data to OSC buf
//    char *msgAddress = [[msg objectAtIndex:0] UTF8String];
//    int valx = [[msg objectAtIndex:1] intValue];
//    int valy = [[msg objectAtIndex:2] intValue];
//    
//    OSC_writeAddressAndTypes(buf, msgAddress, ",ii");
//
//    OSC_writeIntArg(buf, valx);
//    OSC_writeIntArg(buf, valy);
//    
//    const char *data = OSC_getPacket(buf);
//    NSData *outData = [NSData dataWithBytes:data length:32]; // why does 32 work?
    
    // instead of using osc lib, just use NSMutableData
    
    NSData *outData = [self getFOSCDataWithAddress:[msg objectAtIndex:0] 
                                                 x:(NSNumber *)[msg objectAtIndex:1]
                                                 y:(NSNumber *)[msg objectAtIndex:2]];

    //send the data from the osc buf
    [socket sendData:outData toHost:ip port:[port intValue] withTimeout:-1 tag:1];

//    OSC_closeBundle(buf);    

    return self;
}

- (NSData *)getFOSCDataWithAddress:(NSString *)addr x:(NSNumber *)x y:(NSNumber *)y {
    // specifically, just make the osc data for this fOSC version. worry about reusability later
    NSMutableData *data = [NSMutableData data];
    
    NSData *msgAddr = [[self getOSCString:addr] dataUsingEncoding:NSASCIIStringEncoding];
    NSData *tags = [[self getOSCString:@",ii"] dataUsingEncoding:NSASCIIStringEncoding];
    SInt32 swapX = [self swapInt:x];
    SInt32 swapY = [self swapInt:y];
    NSData *xArg = [NSData dataWithBytes:&swapX length:4];
    NSData *yArg = [NSData dataWithBytes:&swapY length:4];
    
    [data appendData:msgAddr];
    [data appendData:tags];
    [data appendData:xArg];
    [data appendData:yArg];
    
    return data;
}

- (NSString *)getOSCString:(NSString *)str {
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



@end
