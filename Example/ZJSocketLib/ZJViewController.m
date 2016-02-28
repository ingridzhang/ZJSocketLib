//
//  ZJViewController.m
//  ZJSocketLib
//
//  Created by zhangjing on 02/28/2016.
//  Copyright (c) 2016 zhangjing. All rights reserved.
//

#import "ZJViewController.h"
#import "ZJSocketConnection.h"
#import "GCDAsyncSocket.h"

@interface ZJViewController ()
{
    NSString *_serverHost;
    int _serverPort;
    ZJSocketConnection *_connection;
}
@property (weak, nonatomic) IBOutlet UITextField *requestText;
@property (weak, nonatomic) IBOutlet UITextField *responseText;

@property (nonatomic,weak) NSTimer *writeTimer;
- (IBAction)write:(UIButton *)sender;

@end

@implementation ZJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _serverHost = @"127.0.0.1";
    _serverPort = 1234;
    [self openConnection];
}

#pragma mark ZJSocketConnection method
- (void)openConnection
{
    [self closeConnection];
    _connection = [[ZJSocketConnection alloc] init];
    _connection.delegate = self;
    [_connection connectWithHost:_serverHost port:_serverPort];
}

- (void)closeConnection
{
    _connection.asyncSocket.userData = @(1);
    if (_connection) {
        _connection.delegate = nil;
        [_connection disconnect];
        _connection = nil;
    }
}

#pragma mark EZJSocketConnectionDelegate method

- (void)didDisconnectWithError:(NSError *)error
{
    //    if (![_connection.asyncSocket.userData isEqualToString:@(1)]) {
    //        [self openConnection];
    //    }
}

- (void)didConnectToHost:(NSString *)host port:(UInt16)port
{
    
}

- (void)didReceiveData:(NSData *)data tag:(long)tag
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"didReceiveData...str:%@",str);
}

#pragma mark 测试方法

- (IBAction)write:(UIButton *)sender {
    self.writeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(writeData) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.writeTimer forMode:NSRunLoopCommonModes];
}

- (void)writeData {
    
    NSMutableString *dataStr = [NSMutableString stringWithString:self.requestText.text];
    if ([dataStr isEqual:@""]) {
        return;
    }
    NSLog(@"[writeData]%@",dataStr);
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [self openConnection];
    [_connection writeData:data timeout:-1 tag:0];
}

- (IBAction)closeSocket {
    [self.writeTimer invalidate];
    self.writeTimer = nil;
    [self closeConnection];
}

@end
