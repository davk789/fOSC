//
//  fOSCDispatcher.m
//  fOSC
//
//  Created by David Kendall on 10/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "fOSCDispatcher.h"
#import "AsyncUdpSocket.h"
#import "AsyncSocket.h"

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

@synthesize ip, port, protocol;


- (id)init
{
    self = [super init];
    if (self) {
        // initialize variables
        protocol = 0; // 0 = udp , 1 = tcp
        port = [[NSNumber numberWithInt:57200] retain];
        ip = @"192.168.1.100";
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
    if (udpSocket) {
        [udpSocket release];
    }
    if (tcpSocket) {
        [tcpSocket disconnect];
        [tcpSocket release];
    }
}

#pragma mark - actions

- (void)setProtocol:(NSNumber *)pr {
    if (protocol == pr) {
        return;
    }
    
    protocol = pr;
    
    if ([pr intValue] == 1) { // 1 = tcp
        if (udpSocket) {
            [udpSocket release];
        }
        tcpSocket = [[AsyncSocket alloc] initWithDelegate:self];
    }
    else if ([pr intValue] == 0) { // 0 = udp
        if (tcpSocket) {
            [tcpSocket release];
        }
        udpSocket = [[AsyncUdpSocket alloc] init];
    }
    else {
        NSLog(@"Received invalid protocol argument. Setting to UDP...\n");
        [self setProtocol:[NSNumber numberWithInt:0]];
    }
    
}

#pragma mark - tcp actions

- (void)connect {
    if (tcpSocket) {
        [tcpSocket connectToHost:ip onPort:[port intValue] withTimeout:-1 error:nil];
    }
    else {
        NSLog(@"socket not found. aborting connection.\n");
    }
}

- (void)disconnect {
    // dumb
    if (tcpSocket) {
        [tcpSocket disconnect];
    }
}

#pragma mark - output

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
    NSData *outData = [self buildOSCMessageWithArgs:msg];
    // ... and then send
    
    if ([protocol intValue] == 1) {
        [tcpSocket writeData:outData withTimeout:3 tag:0];
    }
    else if ([protocol intValue] == 0) {
        [udpSocket sendData:outData toHost:ip port:[port intValue] withTimeout:-1 tag:1];
    }
    
    return self;
}

- (NSData *)buildOSCMessageWithArgs:(NSArray *)args {

    NSMutableData *data = [NSMutableData data];

    NSString *addr = [args objectAtIndex:0];
    NSNumber *i = [args objectAtIndex:1];
        
    NSData *msgAddr = [[addr oscString] dataUsingEncoding:NSASCIIStringEncoding];
    [data appendData:msgAddr];

    // argument order: address identifier x y pitch roll yaw accelX accelY accelZ
    NSData *tags = [[@",iffffffff" oscString] dataUsingEncoding:NSASCIIStringEncoding];
    [data appendData:tags];
    
    SInt32 swapI = [i oscInt];    
    NSData *iArg = [NSData dataWithBytes:&swapI length:4];
    [data appendData:iArg];

    for (int n = 2; n < [args count]; ++n) {
        CFSwappedFloat32 swap = [[args objectAtIndex:n] oscFloat];
        NSData *blob = [NSData dataWithBytes:&swap length:4];
        [data appendData:blob];
    }
        
    if ([protocol intValue] == 1) { // tcp argument separator
        NSData *sep = [[@"\r\n\r\n" oscString] dataUsingEncoding:NSASCIIStringEncoding];
        [data appendData:sep];
    }
    
    return data;
}


@end



