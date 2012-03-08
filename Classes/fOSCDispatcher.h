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

@class AsyncUdpSocket;
@class AsyncSocket;

@interface fOSCDispatcher : NSObject {
    AsyncUdpSocket *udpSocket;
    AsyncSocket *tcpSocket;
    
    NSNumber *protocol; // 0 = udp , 1 = tcp
    NSString *ip;
    NSNumber *port;
}

@property (retain, nonatomic) NSNumber *protocol;
@property (retain, nonatomic) NSString *ip;
@property (retain, nonatomic) NSNumber *port;

- (id)sendMsg:(id)first, ...;
- (NSData *)buildOSCMessageWithArgs:(NSArray *)args;
- (void)connect;
- (void)disconnect;


@end


