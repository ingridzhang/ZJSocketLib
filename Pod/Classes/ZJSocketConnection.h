//
//  ZJAsyncSocketConnection.h
//  Pods
//
//  Created by apple on 15/12/13.
//
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket;
@protocol ZJSocketConnectionDelegate <NSObject>

- (void)didDisconnectWithError:(NSError *)error;
- (void)didConnectToHost:(NSString *)host port:(uint16_t)port;
- (void)didReceiveData:(NSData *)data tag:(long)tag;

@end

@interface ZJSocketConnection : NSObject

@property (nonatomic,strong) GCDAsyncSocket *asyncSocket;
@property (nonatomic, weak) id<ZJSocketConnectionDelegate> delegate;
@property (nonatomic,strong) NSData *inputData;

- (void)connectWithHost:(NSString *)hostName port:(uint16_t)port;
- (void)disconnect;

- (BOOL)isConnected;
- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout tag:(long)tag;

@end
