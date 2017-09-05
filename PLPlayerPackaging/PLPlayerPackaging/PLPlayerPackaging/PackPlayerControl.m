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
#import "UIView+ni_keyboard.h"
#import "PlayerFullChatView.h"

@interface PackPlayerControl ()<UIGestureRecognizerDelegate ,PlayerFullChatViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *topBar;

@property (weak, nonatomic) IBOutlet UIImageView *topBgImageView;

@property (weak, nonatomic) IBOutlet UIView *bottomBar;

@property (weak, nonatomic) IBOutlet UIImageView *bottomBgImageView;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;

@property (weak, nonatomic) IBOutlet UIButton *shareBtn;  //分享

@property (weak, nonatomic) IBOutlet UIButton *barrageBtn; //弹幕开关

@property (weak, nonatomic) IBOutlet UIButton *chatBtn;   //聊天

@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@property (weak, nonatomic) IBOutlet UIButton *fullBtn; //全屏

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@property (nonatomic, strong) UIButton *errorBtn;
@property (nonatomic, strong) UIView *coverView;




@property (nonatomic, assign) PlayerControlType contrlType;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;     //菊花


@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) BOOL isLiving;



@property (nonatomic, strong) PlayerFullChatView *chatView;



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
    
    [_chatView removeFromSuperview];
    
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
    
    self.topBgImageView.image = BUNDLE_IMAGE(@"miniplayer_mask_top");
    self.bottomBgImageView.image = BUNDLE_IMAGE(@"miniplayer_mask_bottom");
    
    switch (_contrlType) {
        case PlayerControlTypeNormalMini:{
            [self.backBtn setImage:BUNDLE_IMAGE(@"player_button_close") forState:UIControlStateNormal];
            
            [self.playBtn setImage:BUNDLE_IMAGE(@"miniplayer_black_play") forState:UIControlStateNormal];
            [self.playBtn setImage:BUNDLE_IMAGE(@"miniplayer_black_pause") forState:UIControlStateSelected];
            
            [self.fullBtn setImage:BUNDLE_IMAGE(@"miniplayer_icon_fullsize") forState:UIControlStateNormal];
//            [self.fullBtn setImage:BUNDLE_IMAGE(@"fullplayer_icon_smallSize") forState:UIControlStateSelected];
            
            [self p_setProgress];
        }
            
            break;
        case PlayerControlTypeNormalFull:{
            [self.backBtn setImage:BUNDLE_IMAGE(@"fullplayer_icon_back") forState:UIControlStateNormal];
            
            [self.playBtn setImage:BUNDLE_IMAGE(@"fullplayer_icon_play") forState:UIControlStateNormal];
            [self.playBtn setImage:BUNDLE_IMAGE(@"fullplayer_icon_pause") forState:UIControlStateSelected];
            
            [self.fullBtn setImage:BUNDLE_IMAGE(@"fullplayer_white_smallSize") forState:UIControlStateNormal];
//            [self.fullBtn setImage:BUNDLE_IMAGE(@"fullplayer_white_smallSize") forState:UIControlStateSelected];
            
            [self p_setProgress];
        }
            
            break;
        case PlayerControlTypeLivingMini:{
            _isLiving = YES;
            [self.backBtn setImage:BUNDLE_IMAGE(@"fullplayer_icon_back") forState:UIControlStateNormal];
            
            self.bottomBgImageView.image = nil;
            [self.shareBtn setImage:BUNDLE_IMAGE(@"miniplayer_share") forState:UIControlStateNormal];
            [self.fullBtn setImage:BUNDLE_IMAGE(@"miniplayer_icon_fullsize") forState:UIControlStateNormal];
//            [self.fullBtn setImage:BUNDLE_IMAGE(@"fullplayer_icon_smallSize") forState:UIControlStateSelected];
        }
            break;
        case PlayerControlTypeLivingFull:{
            _isLiving = YES;
            [self.backBtn setImage:BUNDLE_IMAGE(@"fullplayer_icon_back") forState:UIControlStateNormal];
            
            [self.chatBtn setImage:BUNDLE_IMAGE(@"fullplayer_chat") forState:UIControlStateNormal];
            
            
            [self.barrageBtn setImage:BUNDLE_IMAGE(@"fullplayer_danmu_open") forState:UIControlStateNormal];
            [self.barrageBtn setImage:BUNDLE_IMAGE(@"fullplayer_danmu_close") forState:UIControlStateSelected];
            
            [self.shareBtn setImage:BUNDLE_IMAGE(@"fullplayer_share") forState:UIControlStateNormal];
            
            [self.fullBtn setImage:BUNDLE_IMAGE(@"fullplayer_icon_smallSize") forState:UIControlStateNormal];
            
            self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            self.bottomBgImageView.image = nil;
        }
            
            
            break;
            
        default:
            break;
    }
    
    
    
    //添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapControl:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
}

- (void)playErrorStatus:(PlayerErrorStatus)status; {
//    [self addSubview:self.coverView];
//    self.coverView.frame = self.bounds;
    
    [self.errorBtn removeFromSuperview];
    self.errorBtn.tag = status;
    [self.errorBtn setTitle:[self playErrorStatusDes:status] forState:UIControlStateNormal];
    [self.errorBtn sizeToFit];
    [self addSubview:_errorBtn];
    
    CGFloat w = _errorBtn.frame.size.width + 20;
    CGFloat h = _errorBtn.frame.size.height + 10;
    CGFloat x = (self.frame.size.width - w) / 2.0;
    CGFloat y = (self.frame.size.height - h) / 2.0;
    _errorBtn.frame = CGRectMake(x, y, w, h);
    _errorBtn.layer.cornerRadius = 4;
    _errorBtn.layer.masksToBounds = YES;
    
}

- (void)p_setProgress {
    if (_progressSlider) {
        [self.progressSlider setThumbImage:BUNDLE_IMAGE(@"player_progress_point_blue") forState:UIControlStateNormal];
        self.progressSlider.minimumTrackTintColor = HEX_COLOR(0x4d92ff);
        self.progressSlider.maximumTrackTintColor = [UIColor blackColor];
        self.progressSlider.cacheTrackTintColor = [UIColor lightGrayColor];
        
        
        [self.progressSlider addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [self.progressSlider addTarget:self action:@selector(sliderValueChangedEndAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    }
    
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

- (void)startLoading {
    [self.indicator removeFromSuperview];
    [self addSubview:self.indicator];
    _indicator.center = self.center;
    
    [self.indicator startAnimating];
}
- (void)endLoading {
    [self.indicator stopAnimating];
    [self.indicator removeFromSuperview];
}

- (void)didTapControl:(UITapGestureRecognizer *)gest {
    [self endAnimation];
    
    if ([self.chatView isFirstResponder]) {
        [self.chatView resignResponder];
        [self startAnimation];
        return;
    }
    
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
    
    self.playBtn.hidden = isHidden;
    
    if (_fullSize) {
        APP.statusBarHidden = isHidden;
        
        if (_isLiving) {
            self.bottomBar.hidden = NO;
        } else {
            self.bottomBar.hidden = isHidden;
        }
    } else {
        APP.statusBarHidden = NO;
        self.bottomBar.hidden = isHidden;
    }
    
    if ([_outerDelegate respondsToSelector:@selector(playerControlHidden:)]) {
        [_outerDelegate playerControlHidden:isHidden];
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

- (void)dismissKeyboard {
    [self.chatView resignResponder];
}

- (void)errorBtnDismiss {
    [self.errorBtn removeFromSuperview];
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

- (IBAction)shareAction:(id)sender {
//    if ([_controlDelegate respondsToSelector:@selector(playerControl:shareAction:)]) {
//        [_controlDelegate playerControl:self shareAction:sender];
//    }
    
    if ([_outerDelegate respondsToSelector:@selector(playerShareAction:)]) {
        [_outerDelegate playerShareAction:sender];
    }
}

- (void)errorAction:(UIButton *)sender {
    if ([_controlDelegate respondsToSelector:@selector(playerControl:errorAction:)]) {
        [_controlDelegate playerControl:self errorAction:sender.tag];
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

- (IBAction)chatBtn:(id)sender {
    Will_Chat_Notification;
    [self.chatView removeFromSuperview];
    [self addSubview:self.chatView];
    self.chatView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 44);
    [self.chatView addKeyboardObserverWithType:SuspensionTypeHiden];
    [self.chatView becomeResponder];
    
}
- (IBAction)barrageBtnAction:(id)sender {
    self.barrageBtn.selected = !_barrageBtn.selected;
    if ([_controlDelegate respondsToSelector:@selector(playerBarrageAction:)]) {
        [_controlDelegate playerBarrageAction:_barrageBtn];
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

//聊天发送
- (void)chatView:(PlayerFullChatView *)chatView sendAction:(UITextField *)textField {
    if ([_outerDelegate respondsToSelector:@selector(playerChatView:SendAction:)]) {
        [_outerDelegate playerChatView:chatView SendAction:textField];
    }
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self endAnimation];
}

- (UIButton *)errorBtn {
    if (!_errorBtn) {
        _errorBtn = [[UIButton alloc] init];
//        [_errorBtn setImage:BUNDLE_IMAGE(@"play_error") forState:UIControlStateNormal];
        [_errorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _errorBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [_errorBtn addTarget:self action:@selector(errorAction:) forControlEvents:UIControlEventTouchUpInside];
        _errorBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _errorBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        _errorBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    }
    return _errorBtn;
}
- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    
    return _coverView;
}
- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _indicator;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    _indicator.center = self.center;
    _errorBtn.center = self.center;
}

- (UIView *)chatView {
    if (!_chatView) {
        _chatView = [[PlayerFullChatView alloc] init];
        _chatView.delegate = self;
    }
    return _chatView;
}


- (NSString *)playErrorStatusDes:(PlayerErrorStatus)status {
    switch (status) {
        case PlayerErrorStatusError:
            return @"播放失败，点击重试";
            break;
        case PlayerErrorStatusNetViaWWAN:
            return @"当前为移动网络，是否继续？";
            break;
        case PlayerErrorStatusNotReachable:
            return @"网络异常，请检查网络开关状态！";
            break;
        default:
            break;
    }
    return @"播放失败，点击重试";
}


@end
