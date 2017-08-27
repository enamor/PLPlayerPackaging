//
//  PackPlayer.m
//  PLPlayerPackaging
//
//  Created by zhouen on 2017/8/22.
//  Copyright © 2017年 nina. All rights reserved.
//

#import "PackPlayer.h"
#import <PLPlayerKit/PLPlayer.h>
#import "PackControlScheduler.h"
#import "PackPlayerControlProtocol.h"
#import "PackPlayerMacro.h"

#import "UINavigationController+NI_allowRote.h"
#import "UITabBarController+NI_allRote.h"
#import "AppDelegate+NI_Extension.h"

@interface PackPlayer ()<PLPlayerDelegate, PackPlayerControlDelegate>
@property (nonatomic, strong) PLPlayer *player;
@property (nonatomic, strong) PLPlayerOption *option;

@property (nonatomic, strong) UIView *playView;

//控制层
@property (nonatomic, strong) PackControlScheduler *playerControl; //小屏控制层

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, assign ,readwrite) BOOL isLiving;

@property (nonatomic, weak) UIView *superPlayerView;
@property (nonatomic, assign) UIStatusBarStyle      barStyle;          //之前StatusBar样式



@property (nonatomic, assign) BOOL                  isCanPlay;         //视频是否可以播放
@property (nonatomic, assign) BOOL                  isLock;            //锁定(旋转、手势)
@property (nonatomic, assign) BOOL                  isFullScreen;      //当前是否全屏
@property (nonatomic, assign) UIDeviceOrientation   currentOrientiation; //当前屏幕方向

@property (nonatomic, assign) BOOL isSeeking;
@property (nonatomic, assign) BOOL beforeBackIsPlay;//记录进入后台前播放状态

@property(nonatomic,strong) NSTimer *timer;


@end

@implementation PackPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _playerControl = [[PackControlScheduler alloc] init];
        self.playView = [[UIView alloc] init];
        self.barStyle = APP.statusBarStyle;
    }
    return self;
}

- (void)dealloc {
    
    [self.playView removeFromSuperview];
    [self.superPlayerView removeFromSuperview];
    self.player = nil;
    
    NSLog(@"%s",__func__);
}

- (void)releasePlayer {
    [self endProcess];
    
    
    [self.player stop];
    [self.playView removeFromSuperview];
    [_player.playerView removeFromSuperview];
    [_playerControl removeFromSuperview];
    self.player = nil;
}

- (void)playWithUrl:(NSString *)strUrl onView:(UIView *)view {
    view.backgroundColor = [UIColor grayColor];
    _superPlayerView = view;
    if (!strUrl) NSAssert(1<0, @"视频URL为空");
#warning 需要处理中文路径过会再处理
    if ([strUrl hasPrefix:@"http://"] || [strUrl hasPrefix:@"https://"]) {
        _url = [NSURL URLWithString:strUrl];
    }else if ([strUrl hasPrefix:@"rtmp"] || [strUrl hasPrefix:@"flv"]){
        _url = [NSURL URLWithString:strUrl];
        _isLiving = YES;
    }else { //本地视频 需要完整路径
        _url = [NSURL fileURLWithPath:strUrl];
    }
    
    if (_player) {
        [self releasePlayer];
    }
    
    // 初始化 PLPlayer
    self.player = [PLPlayer playerWithURL:_url option:self.option];
    
    // 设定代理 (optional)
    self.player.delegate = self;
    
    //获取视频输出视图并添加为到当前 UIView 对象的 Subview
    [view addSubview:self.playView];
    
    [self.playView addSubview:_player.playerView];
    self.playView.frame = view.bounds;
    _player.playerView.frame = _playView.bounds;
    [self.playView addSubview:_playerControl];
    
    _playerControl.frame = _playView.bounds;
    _playerControl.controlDelegate = self;
    
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self.player play];
    
    [self p_initNotificatObserver];
}

- (void)play {
    [self.player play];
    [self startProcess];
}

- (void)pause {
    [self.player pause];
    [self endProcess];
}

- (void)stop {
    [self.player stop];
    [self endProcess];
}

- (void)p_initNotificatObserver {
    //监听屏幕方向
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_initScreenOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    //监听系统音量
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_initAudioVolumeObserver:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_initaudioRouteChangeObserver:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    //进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    //进入后他
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil ];
    
}

- (void)p_initDeviceOrientationObserver {
    //监听屏幕方向
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_initScreenOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)p_removeDeviceOrientationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)p_removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 监听屏幕旋转
- (void)p_initScreenOrientationChanged:(id)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    [self fullScreen:orientation];
}

//监听系统音量改变
- (void)p_initAudioVolumeObserver:(id)notification {
//    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
//    self.volumeSlider.value = volume;
    
}

//耳机插入拔出
- (void)p_initaudioRouteChangeObserver:(id)notification {
    NSDictionary *interuptionDict = [notification userInfo];
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
            // 耳机拔掉
            if (!_isLiving) {
                [self play];
            }
            
            break;
        }
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

//前台
- (void)p_applicationDidBecomeActive {
    if (_beforeBackIsPlay) {
        [self play];
    }
    
    [self p_initDeviceOrientationObserver];
    if (_isFullScreen) {
        APP_DELEGATE.allowRotationType = AllowRotationMaskPortrait;
    }
}


//即将进入后台
- (void)p_applicationWillResignActive {
    _beforeBackIsPlay = self.player.isPlaying;
    [self pause];
    
    [self p_removeDeviceOrientationObserver];
    if (_isFullScreen) {
        
        APP_DELEGATE.allowRotationType = AllowRotationMaskLandscapeLeftOrRight;
    }
}





// 实现 <PLPlayerDelegate> 来控制流状态的变更
- (void)player:(nonnull PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    
    switch (state) {
        case PLPlayerStatusPreparing:
            
            break;
        case PLPlayerStatusReady:
            
            break;
        case PLPlayerStatusCaching:
            
            break;
        case PLPlayerStatusPlaying:{
            [self startProcess];
            [self.playerControl setPlay:YES];
        }
            
            break;
        case PLPlayerStatusPaused:{
            [self.playerControl setPlay:NO];
        }
            
            break;
        case PLPlayerStatusStopped:{
            [self.playerControl setPlay:NO];
            [self endProcess];
        }
            
            break;
        case PLPlayerStatusError:
            
            break;
        case PLPlayerStateAutoReconnecting:
            
            break;
            
            
        default:
            break;
    }
    

    // 这里会返回流的各种状态，你可以根据状态做 UI 定制及各类其他业务操作
    // 除了 Error 状态，其他状态都会回调这个方法
    // 开始播放，当连接成功后，将收到第一个 PLPlayerStatusCaching 状态
    // 第一帧渲染后，将收到第一个 PLPlayerStatusPlaying 状态
    // 播放过程中出现卡顿时，将收到 PLPlayerStatusCaching 状态
    // 卡顿结束后，将收到 PLPlayerStatusPlaying 状态
    
    if (PLPlayerStatusCaching == state) {
//        [self.activityIndicatorView startAnimating];
    } else {
//        [self.activityIndicatorView stopAnimating];
    }

}

- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error {
    // 当发生错误，停止播放时，会回调这个方法
    NSLog(@"%@",error);
}

- (void)player:(nonnull PLPlayer *)player codecError:(nonnull NSError *)error {
    // 当解码器发生错误时，会回调这个方法
    // 当 videotoolbox 硬解初始化或解码出错时
    // error.code 值为 PLPlayerErrorHWCodecInitFailed/PLPlayerErrorHWDecodeFailed
    // 播发器也将自动切换成软解，继续播放
    NSLog(@"%@",error);
}


- (PLPlayerOption *)option {
    if (!_option) {
        _option = [PLPlayerOption defaultOption];
        // 更改需要修改的 option 属性键所对应的值
        [_option setOptionValue:@15 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
        [_option setOptionValue:@2000 forKey:PLPlayerOptionKeyMaxL1BufferDuration];
        [_option setOptionValue:@1000 forKey:PLPlayerOptionKeyMaxL2BufferDuration];
        [_option setOptionValue:@(NO) forKey:PLPlayerOptionKeyVideoToolbox];
        [_option setOptionValue:@(kPLLogInfo) forKey:PLPlayerOptionKeyLogLevel];
        
    }
    return _option;
}



/////////////////////////////////////////////////////////////////////////////
#pragma mark ------ Protocol
- (void)playerControl:(UIView *)control backAction:(UIButton *)sender {
    if (_isFullScreen) {
        _isLock = NO;
        [self fullScreen:UIDeviceOrientationPortrait];
        
    } else {
        if (_playerDelegate) {
            if ([_playerDelegate respondsToSelector:@selector(playerBackBtnAction)]) {
                [_playerDelegate playerBackBtnAction];
            }
        }
    }
}
- (void)playerControl:(UIView *)control fullScreenAction:(UIButton *)sender {
    if (_isFullScreen) {
        _isLock = NO;
        [self fullScreen:UIDeviceOrientationPortrait];
        
    }else {
        if (!sender.selected) {
            [self fullScreen:UIDeviceOrientationLandscapeLeft];
        } else {
            [self fullScreen:UIDeviceOrientationPortrait];
        }
    }

}

- (void)playerControl:(UIView *)control playAction:(UIButton *)sender {
    if (self.player.isPlaying) {
        [self.player pause];
        [self.playerControl setPlay:NO];
    } else {
        
        [self.player play];
        [self.playerControl setPlay:YES];
        
    }
}

- (void)playerControl:(UIView *)control sliderValueChangedEndAction:(UISlider *)sender {
    double time = CMTimeGetSeconds(self.player.totalDuration) * sender.value;
    
    CMTimeScale scale =self.player.currentTime.timescale;
    CMTime cmtime =CMTimeMake(time * scale, scale);
    [self.player seekTo:cmtime];
    self.isSeeking = NO;
}

- (void)playerControl:(UIView *)control sliderValueChangedAction:(UISlider *)sender {
    double time = CMTimeGetSeconds(self.player.totalDuration) * sender.value;
    double totalTime = CMTimeGetSeconds(self.player.totalDuration);
    [self.playerControl playTo:time totalTime:totalTime];
    self.isSeeking = YES;
    //    if (!_isFullScreen) {
    //        [self.playerControl playTo:seekTime totalTime:totalTime];
    //    } else {
    //        __weak typeof(self) weakSelf = self;
    //        [self.playerControl seekPipTo:sender.value * self.avPlayer.totalTime totalTime:self.avPlayer.totalTime];
    //        [self.avPlayer getCImage:sender.value * self.avPlayer.totalTime block:^(UIImage *image) {
    //            [weakSelf.playerControl seekToImage:image];
    //        }];
    //        [self.avPlayer startToSeek];
    //    }
}



#pragma mark - Public
- (void)fullScreen:(UIDeviceOrientation)orientation {
    if (![self judgeIfCanRotate:orientation]) return;
    
    CGAffineTransform tranform = [self getRotateTransform:orientation];
    _currentOrientiation = orientation;
    
    if (orientation == UIDeviceOrientationLandscapeLeft
        ||orientation ==UIDeviceOrientationLandscapeRight ) { //全屏
        [self.playView removeFromSuperview];
        [[UIApplication sharedApplication].keyWindow addSubview:self.playView];
        if ( _player.width < _player.height) {
            //竖屏视频
            CGRect frame = [UIApplication sharedApplication].keyWindow.bounds;
            [self resetFrame:frame];
            
            _isLock = YES;
            self.isFullScreen = YES;
            APP.statusBarStyle = UIStatusBarStyleLightContent;
            return;
        }
        CGFloat height = self.playView.superview.frame.size.width;
        CGFloat width = self.playView.superview.frame.size.height;
        
        [UIView animateWithDuration:0.3f animations:^{
            if (!_isFullScreen) {
                CGRect frame = CGRectMake((height - width)/2.0,(width - height)/2.0, width, height);
                [self resetFrame:frame];
            }
            [self.playView setTransform:tranform];
            
        }];
        
        APP.statusBarOrientation = (UIInterfaceOrientation)orientation;
        APP.statusBarStyle = UIStatusBarStyleLightContent;
        APP.statusBarHidden = NO;
        self.isFullScreen = YES;
        
        //添加手势控制
        //        [self p_addPanRecognizer];
        
    } else if (orientation == UIDeviceOrientationPortrait) { //小屏幕
        [self.playView removeFromSuperview];
        
        //移除亮度控制
        [self.superPlayerView addSubview:self.playView];
        [UIView animateWithDuration:0.3f animations:^{
            [self.playView setTransform:tranform];
            [self resetFrame:_superPlayerView.bounds];
        }];
        
        APP.statusBarOrientation = UIInterfaceOrientationPortrait;
        APP.statusBarStyle = _barStyle;
        APP.statusBarHidden = NO;
        self.isFullScreen = NO;
        
        //删除手势控制
        //        [self p_removePanRecognizer];
    }
}

- (void)resetFrame:(CGRect)frame {
    self.playView.frame = frame;
    self.playerControl.frame = _playView.bounds;
    _player.playerView.frame = _playView.bounds;

}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.playerControl.title = title;
}

- (void)setIsFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;
    [self.playerControl setFullSize:_isFullScreen];
}


//判断是否可以旋转
- (BOOL)judgeIfCanRotate:(UIDeviceOrientation)orientation {
    //视频不能播放禁止旋转
    //    if (!_isCanPlay) return NO;
    //屏幕方向未改变无需旋转
    if (_currentOrientiation == orientation) return NO;
    //竖屏视频锁定/全屏屏幕锁定时
    if (_isLock) return NO;
    if (orientation == UIDeviceOrientationPortrait ||
        orientation == UIDeviceOrientationLandscapeLeft ||
        orientation == UIDeviceOrientationLandscapeRight) {
    } else {
        return NO;
    }
    return YES;
}
//获取旋转角度
- (CGAffineTransform)getRotateTransform:(UIDeviceOrientation)orientation {
    CGAffineTransform tranform = CGAffineTransformIdentity;
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        tranform = CGAffineTransformMakeRotation(M_PI_2);
    } else if (orientation == UIDeviceOrientationLandscapeRight){
        tranform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    return tranform;
}


- (void)startProcess {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(timerFunction:) userInfo:nil repeats:YES];
    }
}

- (void) endProcess {
    if (_timer) {
        [_timer invalidate];
        self.timer  = nil;
    }
}


- (void)timerFunction:(NSTimer *) timer {
    if (self.player.playing  && !_isSeeking) {

        double currentTime = CMTimeGetSeconds(self.player.currentTime);
        double totalTime = CMTimeGetSeconds(self.player.totalDuration);
        [_playerControl playTo:currentTime totalTime:totalTime];
    }
}

@end
