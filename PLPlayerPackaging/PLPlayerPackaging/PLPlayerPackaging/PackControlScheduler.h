//
//  PackControlScheduler.h
//  PLPlayerPackaging
//
//  Created by zhouen on 2017/8/22.
//  Copyright © 2017年 nina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PackPlayerControlProtocol.h"

@interface PackControlScheduler : UIView
@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign, getter=isFullSize) BOOL   fullSize;
@property (nonatomic, assign ,getter=isPlay)     BOOL   play;

@property (nonatomic, weak) id<PackPlayerControlDelegate> controlDelegate;

- (void)playTo:(double)time totalTime:(double)totalTime;
@end
