//
//  PackPlayerControl.h
//  PLPlayerPackaging
//
//  Created by zhouen on 2017/8/22.
//  Copyright © 2017年 nina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PackPlayerControlProtocol.h"
#import "PlayerOuterProtocol.h"

@class PackPlayerSlider;


@interface PackPlayerControl : UIView
@property (nonatomic, copy) NSString *title;
@property (weak, nonatomic) IBOutlet PackPlayerSlider *progressSlider;

@property (nonatomic, assign, getter=isFullSize) BOOL   fullSize;
@property (nonatomic, assign ,getter=isPlay)     BOOL   play;

@property (nonatomic, weak) id<PackPlayerControlDelegate> controlDelegate;
@property (nonatomic, weak) id<PlayerOuterProtocol> outerDelegate;

- (instancetype)initWithType:(PlayerControlType)type;

- (void)playTo:(double)time totalTime:(double)totalTime;

- (void)playErrorStatus:(PlayerErrorStatus)status;

- (void)startLoading;

- (void)endLoading;

- (void)errorBtnDismiss;

- (void)dismissKeyboard;

@end
