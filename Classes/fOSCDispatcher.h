//
//  fOSCDispatcher.h
//  fOSC
//
//  Created by David Kendall on 10/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  Process the active points and send the formatted data as a udp bundle.
//
//  This probably means that this class should also handle some sort of "voice"
//  management for the number of fingers down
//
//

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"
#import "OSC-client.h" // trying to get rid of this right now


// instead of asyncudpsocket, let's try lo
//#import <lo/lo.h> // or not

@interface fOSCDispatcher : NSObject {
    AsyncUdpSocket *socket;
    NSString *ip;
    NSNumber *port;
    int bufferSize;
}

- (id)sendMsg:(id)first, ...;
- (NSData *)getFOSCDataWithAddress:(NSString *)addr x:(NSNumber *)x y:(NSNumber *)y;
- (NSString *)getOSCString:(NSString *)str;
- (SInt32)swapInt:(NSNumber *)inVal;

- (void)beginAction:(NSArray *)points;
- (void)moveAction:(NSArray *)points;
- (void)endAction:(NSArray *)points;

@end
