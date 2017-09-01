//
//  NINetMonitor.h
//  FYJI
//
//  Created by zhouen on 2017/8/31.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIReachability.h"
@interface NINetMonitor : NSObject
+ (void)startMonitorWithCallBack:(void(^)(NINetworkStatus))networkStatus;


+ (NINetworkStatus)currentReachabilityStatus;

+ (void)stopNotifierMonitor;
@end
