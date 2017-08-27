//
//  PackPlayerControl.m
//  PLPlayerPackaging
//
//  Created by zhouen on 2017/8/22.
//  Copyright © 2017年 nina. All rights reserved.
//

#import "PackPlayerControl.h"
#import "PackPlayerSlider.h"
#import "PackPlayerMacro.h"

@interface PackPlayerControl ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *topBar;

@property (weak, nonatomic) IBOutlet UIImageView *topBgImageView;

@property (weak, nonatomic) IBOutlet UIView *bottomBar;

@property (weak, nonatomic) IBOutlet UIImageView *bottomBgImageView;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@property (weak, nonatomic) IBOutlet UIButton *fullBtn;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;




@property (nonatomic, assign) PlayerControlType contrlType;


@property (nonatomic, strong) NSTimer *timer;


@end

@implementation PackPlayerControl

- (instancetype)initWithType:(PlayerControlType)type {
    NSArray *controls = [[NSBundle mainBundle] loadNibNamed:@"PackPlayerControl" owner:nil options:nil];
    if (type < controls.count) {
        self = controls[type];
    }
    self.contrlType = type;
    [self p_setUI];
    return self;

}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)setFullSize:(BOOL)fullSize {
    _fullSize = fullSize;
    
    [self endAnimation];
    [self controrHidden:NO];
    [self startAnimation];
    
//    [self controrHidden:_play];
    
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)p_setUI {
    
    switch (_contrlType) {
        case PlayerControlTypeNormalMini:{
            [self.backBtn setImage:BUNDLE_IMAGE(@"player_button_close") forState:UIControlStateNormal];
            
            [self.playBtn setImage:BUNDLE_IMAGE(@"miniplayer_bottom_play") forState:UIControlStateNormal];
            [self.playBtn setImage:BUNDLE_IMAGE(@"miniplayer_bottom_pause") forState:UIControlStateSelected];
            
            [self.fullBtn setImage:BUNDLE_IMAGE(@"miniplayer_icon_fullsize") forState:UIControlStateNormal];
            [self.fullBtn setImage:BUNDLE_IMAGE(@"miniplayer_icon_fullsize") forState:UIControlStateSelected];
            
            [self p_setProgress];
        }
            
            break;
        case PlayerControlTypeNormalFull:{
            [self.backBtn setImage:BUNDLE_IMAGE(@"fullplayer_icon_back") forState:UIControlStateNormal];
            
            [self.playBtn setImage:BUNDLE_IMAGE(@"fullplayer_icon_play") forState:UIControlStateNormal];
            [self.playBtn setImage:BUNDLE_IMAGE(@"fullplayer_icon_pause") forState:UIControlStateSelected];
            
            [self.fullBtn setImage:BUNDLE_IMAGE(@"miniplayer_icon_fullsize") forState:UIControlStateNormal];
            [self.fullBtn setImage:BUNDLE_IMAGE(@"miniplayer_icon_fullsize") forState:UIControlStateSelected];
            
            [self p_setProgress];
        }
            
            break;
        case PlayerControlTypeLivingMini:
            
            break;
        case PlayerControlTypeLivingFull:
            
            break;
            
        default:
            break;
    }
    
    
    
    //添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapControl:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
}

- (void)p_setProgress {
    [self.progressSlider setThumbImage:BUNDLE_IMAGE(@"fullplayer_progress_point") forState:UIControlStateNormal];
    self.progressSlider.minimumTrackTintColor = HEX_COLOR(0xF1B795);
    self.progressSlider.maximumTrackTintColor = [UIColor blackColor];
    self.progressSlider.cacheTrackTintColor = [UIColor lightGrayColor];
    
    self.topBgImageView.image = BUNDLE_IMAGE(@"miniplayer_mask_top");
    self.bottomBgImageView.image = BUNDLE_IMAGE(@"miniplayer_mask_bottom");
    
    [self.progressSlider addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [self.progressSlider addTarget:self action:@selector(sliderValueChangedEndAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
}

- (void)startAnimation {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(controlAnimation) userInfo:nil repeats:NO];
    }
}
- (void)endAnimation {
    if (_timer) {
        [_timer invalidate];
        self.timer  = nil;
    }
}

- (void)didTapControl:(UITapGestureRecognizer *)gest {
    [self endAnimation];
    
    [self controrHidden:!_topBar.hidden];
    
    if (!self.topBar.hidden) {
        [self startAnimation];
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    //    if (gestureRecognizer == self.shrinkPanGesture && self.isCellVideo) {
    //        if (!self.isBottomVideo || self.isFullScreen) {
    //            return NO;
    //        }
    //    }
    //    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && gestureRecognizer != self.shrinkPanGesture) {
    //        if ((self.isCellVideo && !self.isFullScreen) || self.playDidEnd || self.isLocked){
    //            return NO;
    //        }
    //    }
    //    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
    //        if (self.isBottomVideo && !self.isFullScreen) {
    //            return NO;
    //        }
    //    }
    if ([touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }

    return YES;
}


- (void)controlAnimation {
    [self controrHidden:YES];
}

- (void)controrHidden:(BOOL)isHidden {
    self.topBar.hidden = isHidden;
    self.bottomBar.hidden = isHidden;
    self.playBtn.hidden = isHidden;
    
    if (_fullSize) {
        APP.statusBarHidden = isHidden;
    } else {
        APP.statusBarHidden = NO;
    }
    
}

- (void)setPlay:(BOOL)play {
    _play = play;
    self.playBtn.selected = _play;
    
    if (_play) {
        [self startAnimation];
    } else {
        [self endAnimation];
        [self controrHidden:NO];
    }
}

- (void)playTo:(double)time totalTime:(double)totalTime {
    NSString *dtime = [self hourTime:time];
    NSString *dtotal = [self hourTime:totalTime];
    
    self.currentTimeLabel.text = dtime;
    self.totalTimeLabel.text = dtotal;
    self.progressSlider.value = time/totalTime;
    
}

- (NSString *)hourTime:(double)second {
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    } else {
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [dateFormatter stringFromDate:d];
    return showtimeNew;
}



- (IBAction)backAction:(id)sender {
    if ([_controlDelegate respondsToSelector:@selector(playerControl:backAction:)]) {
        [_controlDelegate playerControl:self backAction:sender];
    }
}

- (IBAction)fullSizeAction:(id)sender {
    if ([_controlDelegate respondsToSelector:@selector(playerControl:fullScreenAction:)]) {
        [_controlDelegate playerControl:self fullScreenAction:sender];
    }
}


- (IBAction)playAction:(id)sender {
    if ([_controlDelegate respondsToSelector:@selector(playerControl:playAction:)]) {
        [_controlDelegate playerControl:self playAction:sender];
    }
}


- (void)sliderValueChangedAction:(UISlider *)sender {
    [self endAnimation];
    if ([_controlDelegate respondsToSelector:@selector(playerControl:sliderValueChangedAction:)]) {
        [_controlDelegate playerControl:self sliderValueChangedAction:sender];
    }
}
- (void)sliderValueChangedEndAction:(UISlider *)sender {
    [self startAnimation];
    if ([_controlDelegate respondsToSelector:@selector(playerControl:sliderValueChangedEndAction:)]) {
        [_controlDelegate playerControl:self sliderValueChangedEndAction:sender];
    }
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self endAnimation];
}


@end
