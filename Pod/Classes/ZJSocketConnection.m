//
//  EZJAsyncSocket.m
//  Pods
//
//  Created by apple on 15/12/13.
//
//

#import "ZJSocketConnection.h"
#import "GCDAsyncSocket.h"

@interface ZJSocketConnection() <GCDAsyncSocketDelegate>

@end

@implementation ZJSocketConnection

- (instancetype)init{
    if (self = [super init]) {
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)dealloc {
    _asyncSocket.delegate = nil;
    _asyncSocket = nil;
}

- (void)connectWithHost:(NSString *)hostName port:(uint16_t)port {
    NSError *error = nil;
    [_asyncSocket connectToHost:hostName onPort:port error:&error];
    if (error) {
        NSLog(@"[EZJSocketConnection] connectWithHost error: %@", error.description);
        if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectWithError:)]) {
            [_delegate didDisconnectWithError:error];
        }
    }
}

- (void)disconnect
{
    _asyncSocket.userData = @(1);// 声明是由用户主动切断
    [_asyncSocket disconnect];
}

- (BOOL)isConnected
{
    return [_asyncSocket isConnected];
}

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag
{
    [_asyncSocket readDataWithTimeout:timeout tag:tag];
}

- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout tag:(long)tag
{
    [_asyncSocket writeData:data withTimeout:timeout tag:tag];
}

#pragma mark GCDAsyncSocketDelegate

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"[EZJSocketConnection] didDisconnect...%@",err.description);
    if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectWithError:)]) {
        [_delegate didDisconnectWithError:err];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"[EZJSocketConnection] didConnectToHost:%@, port:%zd",host,port);
    if (_delegate && [_delegate respondsToSelector:@selector(didConnectToHost:port:)]) {
        [_delegate didConnectToHost:host port:port];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"[EZJSocketConnection] didReadData: %@, tag:%ld",str,tag);
    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveData:tag:)]) {
        [_delegate didReceiveData:data tag:tag];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"[EZJSocketConnection] didWriteDataWithTag: %ld",tag);
    [_asyncSocket readDataWithTimeout:-1 tag:0];
}

@end
