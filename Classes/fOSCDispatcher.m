//
//  fOSCDispatcher.m
//  fOSC
//
//  Created by David Kendall on 10/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "fOSCDispatcher.h"

@interface NSString(fOSCAdditions)
- (NSString*)oscString;
@end
@implementation NSString(fOSCAdditions)
- (NSString*)oscString {
    // string + 1 null in termination + 0-3 nulls in padding for 4-byte alignment
    NSUInteger numberOfNulls = 4 - (self.length & 3);
    return [self stringByPaddingToLength:self.length+numberOfNulls withString:@"\0" startingAtIndex:0];
}
@end

@interface NSNumber(fOSCAdditions)
- (SInt32)oscInt;
- (CFSwappedFloat32)oscFloat;
@end
// OSC uses big-endian numerical values
@implementation NSNumber(fOSCAdditions)
- (SInt32)oscInt {
    SInt32 value = 0;
    CFNumberGetValue((__bridge CFNumberRef)self, kCFNumberSInt32Type, &value);
    SInt32 swappedValue = CFSwapInt32HostToBig(value);
    return swappedValue;
}
- (CFSwappedFloat32)oscFloat {
    Float32 value = 0;
    CFNumberGetValue((__bridge CFNumberRef)self, kCFNumberFloat32Type, &value);
    CFSwappedFloat32 swappedValue = CFConvertFloat32HostToSwapped(value);
    return swappedValue;
}
@end

@implementation fOSCDispatcher

@synthesize ip, port;

- (id)init
{
    self = [super init];
    if (self) {
        // initialize variables
        socket = [[AsyncUdpSocket alloc] init];
        port = [[NSNumber numberWithInt:57200] retain];
        ip = @"192.168.1.100";
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
    [socket release];
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
    
    NSData *msgAddr = [[addr oscString] dataUsingEncoding:NSASCIIStringEncoding];
    NSData *tags = [[@",iff" oscString] dataUsingEncoding:NSASCIIStringEncoding];
    SInt32 swapI = [i oscInt];
    CFSwappedFloat32 swapX = [x oscFloat];
    CFSwappedFloat32 swapY = [y oscFloat];
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

@end



