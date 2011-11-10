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

@interface fOSCDispatcher : NSObject {
    AsyncUdpSocket *socket;
    NSString *ip;
    NSNumber *port;
}

@property (retain) NSString *ip;
@property (retain) NSNumber *port;

- (id)sendMsg:(id)first, ...;
- (NSData *)fOSCDataWithAddress:(NSString *)addr identifier:(NSNumber *)i x:(NSNumber *)x y:(NSNumber *)y;

@end


