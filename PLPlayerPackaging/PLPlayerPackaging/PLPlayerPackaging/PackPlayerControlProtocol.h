//
//  NIPlayerControlProtocol.h
//  NIPlayer
//
//  Created by zhouen on 2017/6/28.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#ifndef PackPlayerControlProtocol_h
#define PackPlayerControlProtocol_h

typedef NS_ENUM(NSInteger ,PlayerErrorStatus) {
    PlayerErrorStatusError = 0,            //播放失败
    PlayerErrorStatusNetViaWWAN ,          //移动数据
    PlayerErrorStatusNotReachable          //没有网络
};


typedef NS_ENUM(NSInteger ,PlayerControlType) {
    PlayerControlTypeNormalMini = 0,  //普通小屏
    PlayerControlTypeNormalFull ,     //普通大屏
    PlayerControlTypeLivingMini ,     //直播小屏
    PlayerControlTypeLivingFull       //直播大屏
};

@protocol  PackPlayerControlDelegate<NSObject>

@optional
- (void)playerControl:(UIView *)control backAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control shareAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control fullScreenAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control playAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control errorAction:(PlayerErrorStatus)status ;
- (void)playerControl:(UIView *)control nextAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control sliderValueChangedAction:(UISlider *)sender ;
- (void)playerControl:(UIView *)control sliderValueChangedEndAction:(UISlider *)sender ;

//弹幕
- (void)playerBarrageAction:(UIButton *)sender ;


//发送
- (void)playerControl:(UIView *)control sliderValueChangedEndAction:(UISlider *)sender ;

@end

#endif /* PackPlayerControlProtocol_h */
