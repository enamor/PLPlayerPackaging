//
//  PackControlScheduler.m
//  PLPlayerPackaging
//
//  Created by zhouen on 2017/8/22.
//  Copyright © 2017年 nina. All rights reserved.
//

#import "PackControlScheduler.h"
#import "PackPlayerControl.h"
#import "PackPlayerSlider.h"

@interface PackControlScheduler ()
@property (nonatomic, strong) PackPlayerControl *miniControl; //小屏控制层
@property (nonatomic, strong) PackPlayerControl *fullControl; //大屏控制层


@end
@implementation PackControlScheduler

- (instancetype)init
{
    self = [super init];
    if (self) {
        _miniControl = [[PackPlayerControl alloc] initWithType:PlayerControlTypeNormalMini];
        _fullControl = [[PackPlayerControl alloc] initWithType:PlayerControlTypeNormalFull];
        _fullControl.hidden = YES;
        
        [self addSubview:_miniControl];
        [self addSubview:_fullControl];
    }
    return self;
}

- (void)setFullSize:(BOOL)fullSize {
    _fullSize = fullSize;
    _fullControl.hidden = !_fullSize;
    _miniControl.hidden = _fullSize;
    
    _fullControl.fullSize = _fullSize;
    _miniControl.fullSize = _fullSize;
    
//    if (_fullSize) {
//        _fullControl.progressSlider.value = _miniControl.progressSlider.value;
//        _fullControl.progressSlider.cacheValue  = _miniControl.progressSlider.cacheValue;
//        _fullControl.play = _miniControl.isPlay;
//    } else {
//        _miniControl.progressSlider.value = _fullControl.progressSlider.value;
//        _miniControl.progressSlider.cacheValue  = _fullControl.progressSlider.cacheValue;
//        _miniControl.play = _fullControl.isPlay;
//    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _fullControl.title = title;
}

- (void)setControlDelegate:(id<PackPlayerControlDelegate>)controlDelegate {
    _controlDelegate = controlDelegate;
    _miniControl.controlDelegate = _controlDelegate;
    _fullControl.controlDelegate = _controlDelegate;
}

- (void)setPlay:(BOOL)play {
    _play = play;
    [_fullControl setPlay:_play];
    [_miniControl setPlay:_play];

}
- (void)playTo:(double)time totalTime:(double)totalTime {
    [_fullControl playTo:time totalTime:totalTime];
    [_miniControl playTo:time totalTime:totalTime];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    _miniControl.frame = self.bounds;
    _fullControl.frame = self.bounds;
}

@end
