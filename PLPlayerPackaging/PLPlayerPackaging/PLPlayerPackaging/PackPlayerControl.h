//
//  PackPlayerControl.h
//  PLPlayerPackaging
//
//  Created by zhouen on 2017/8/22.
//  Copyright © 2017年 nina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PackPlayerControlProtocol.h"

@class PackPlayerSlider;

typedef NS_ENUM(NSInteger ,PlayerControlType) {
    PlayerControlTypeNormalMini = 0,  //普通小屏
    PlayerControlTypeNormalFull ,     //普通大屏
    PlayerControlTypeLivingMini ,     //直播小屏
    PlayerControlTypeLivingFull       //直播大屏
};

@interface PackPlayerControl : UIView
@property (nonatomic, copy) NSString *title;
@property (weak, nonatomic) IBOutlet PackPlayerSlider *progressSlider;

@property (nonatomic, assign, getter=isFullSize) BOOL   fullSize;
@property (nonatomic, assign ,getter=isPlay)     BOOL   play;

@property (nonatomic, weak) id<PackPlayerControlDelegate> controlDelegate;

- (instancetype)initWithType:(PlayerControlType)type;

- (void)playTo:(double)time totalTime:(double)totalTime;

@end
