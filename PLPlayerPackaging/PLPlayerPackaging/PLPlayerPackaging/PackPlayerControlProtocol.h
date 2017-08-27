//
//  NIPlayerControlProtocol.h
//  NIPlayer
//
//  Created by zhouen on 2017/6/28.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#ifndef PackPlayerControlProtocol_h
#define PackPlayerControlProtocol_h

@protocol  PackPlayerControlDelegate<NSObject>

@optional
- (void)playerControl:(UIView *)control backAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control fullScreenAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control playAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control errorAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control nextAction:(UIButton *)sender ;
- (void)playerControl:(UIView *)control sliderValueChangedAction:(UISlider *)sender ;
- (void)playerControl:(UIView *)control sliderValueChangedEndAction:(UISlider *)sender ;

@end

#endif /* PackPlayerControlProtocol_h */
