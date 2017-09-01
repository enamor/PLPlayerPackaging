//
//  NINetMonitor.m
//  FYJI
//
//  Created by zhouen on 2017/8/31.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "NINetMonitor.h"

@interface NINetMonitor ()
@property (nonatomic, strong) NIReachability *reachability;
@property (nonatomic, copy) void(^networkStatus)(NINetworkStatus) ;

@end

@implementation NINetMonitor
static NSString * const remoteHostName = @"www.baidu.com";

+ (instancetype)sharedMonitor {
    
    static NINetMonitor *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[NINetMonitor alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:_sharedClient selector:@selector(reachabilityChanged:) name:kNIReachabilityChangedNotification object:nil];
    });
    
    return _sharedClient;
    
}


+ (void)startMonitorWithCallBack:(void(^)(NINetworkStatus))networkStatus {
    NINetMonitor *monitor = [NINetMonitor sharedMonitor];
    monitor.networkStatus = networkStatus;
    monitor.reachability = [NIReachability reachabilityForInternetConnection];
    [monitor.reachability  startNotifier];
}

+ (void)stopNotifierMonitor {
    [[NINetMonitor sharedMonitor].reachability stopNotifier];
}

+ (NINetworkStatus)currentReachabilityStatus {
    return [NINetMonitor sharedMonitor].reachability.currentReachabilityStatus;
}

- (void) reachabilityChanged:(NSNotification *)note {
    NINetMonitor *monitor = [NINetMonitor sharedMonitor];
    NIReachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[NIReachability class]]);
    
    NINetworkStatus netStatus = [curReach currentReachabilityStatus];
    if (monitor.networkStatus) {
        monitor.networkStatus(netStatus);
    }
}



@end
