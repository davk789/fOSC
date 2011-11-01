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

@interface fOSCMessenger : NSObject {
    AsyncUdpSocket *socket;
    NSString *ip;
    NSNumber *port;
}

- (id)sendMsg:(id)first, ...;
- (NSData *)fOSCDataWithAddress:(NSString *)addr identifier:(NSNumber *)i x:(NSNumber *)x y:(NSNumber *)y;
- (NSString *)oscString:(NSString *)str;
- (SInt32)swapInt:(NSNumber *)inVal;
- (CFSwappedFloat32)swapFloat:(NSNumber *)inVal;

@end

@interface fOSCDispatcher : NSObject {
    /* the dispatcher should handle program logic stuff as it pertains to the touch inputs */
    fOSCMessenger *messenger;
    NSMutableArray *touches;
}

- (void)beginAction:(NSDictionary *)points;
- (void)moveAction:(NSDictionary *)points;
- (void)endAction:(NSDictionary *)points;
- (void)sendMessage:(NSString *)msg withPoints:(NSDictionary *)point;

-(NSNumber *)xValueToUnit:(int)x;
-(NSNumber *)yValueToUnit:(int)y;

@end
