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
#import "HJDanmaku.h"
#import "IBCBarrageView.h"

#import "AppDelegate+NI_Extension.h"
#import "UINavigationController+NI_allowRote.h"
#import "UITabBarController+NI_allRote.h"

#import "NINetMonitor.h"

@interface PackPlayer ()<PLPlayerDelegate, PackPlayerControlDelegate>
@property (nonatomic, strong) PLPlayer *player;
@property (nonatomic, strong) PLPlayerOption *option;

@property (nonatomic, strong, readwrite) UIView *playView;

//控制层
@property (nonatomic, strong) PackControlScheduler *playerControl; //小屏控制层

//弹幕
@property (nonatomic, strong)IBCBarrageView *barrageView;

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
@property (nonatomic, assign) BOOL isClosedBarrage;   //是否开启弹幕

@property(nonatomic,strong) NSTimer *timer;


@property(nonatomic,strong) NSTimer *loadingTimer;  //监听播放器状态 七牛播放器状态返回不对


@property (nonatomic, strong) UIView *fullView;


@end

@implementation PackPlayer

- (instancetype)initWithType:(BOOL)isLiving onView:(UIView *)view{
    self = [super init];
    if (self) {
        _isLiving = isLiving;
        _superPlayerView = view;
    
        self.playView = [[UIView alloc] init];
        self.playView.backgroundColor = [UIColor blackColor];
        self.barStyle = APP.statusBarStyle;
        
        [self p_initPlayerUI];
        
        
        
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.playView = [[UIView alloc] init];
        self.playView.backgroundColor = [UIColor blackColor];
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
    [self endLoadingTimer];
    
    [self.player stop];
    [_player.playerView removeFromSuperview];
    self.player = nil;
    
    [self.playView removeFromSuperview];
    [_playerControl removeFromSuperview];
    self.playerControl = nil;
    
    [self p_removeObserver];
}

- (void)playWithUrl:(NSString *)strUrl onView:(UIView *)view{
    _superPlayerView = view;
    [self playWithUrl:strUrl];
}

- (void)playWithUrl:(NSString *)strUrl {
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
    
    [self rePlay];
}


- (void)p_initPlayerUI {
    [_superPlayerView addSubview:self.playView];
    self.playView.frame = _superPlayerView.bounds;
    
    [self.playView addSubview:self.playerControl];
    _playerControl.frame = _playView.bounds;
    _playerControl.controlDelegate = self;
    _playerControl.outerDelegate = self.playerDelegate;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
#warning 待七牛播放器问题修复后再解决
//    [self p_initNetworkStatusObserver];
}

- (void)setPlayerDelegate:(id<PackPlayerDelegate>)playerDelegate {
    _playerDelegate = playerDelegate;
    _playerControl.outerDelegate = self.playerDelegate;
}


- (void)rePlay {
    [self p_removeObserver];
    [self.playerControl errorBtnDismiss];
    
    if (_player) {
        [self endProcess];
        [self.player stop];
        [_player.playerView removeFromSuperview];
        self.player = nil;
    }
    [self plPlayerPlay];
}

- (void)plPlayerPlay {
    // 初始化 PLPlayer
    self.player = [PLPlayer playerWithURL:_url option:self.option];
    
    // 设定代理 (optional)
    self.player.delegate = self;
    [self.playView insertSubview:_player.playerView atIndex:0];
    _player.playerView.frame = _playView.bounds;
    [self play];
    
    [self p_initNotificatObserver];
}

- (void)initFrame {
    if (!_isFullScreen) {
        self.playView.frame = _superPlayerView.bounds;
        _player.playerView.frame = _playView.bounds;
        
        _playerControl.frame = _playView.bounds;
    }
    
}

- (void)play {
    [self.player play];
    
    if (!_isLiving) {
        [self startProcess];
    }
    
}

- (void)pause {
    [self.player pause];
    [self.playerControl endLoading];
    if (!_isLiving) {
        [self endProcess];
    }
    
}

- (void)stop {
    [self.player stop];
    [self.playerControl endLoading];
    if (!_isLiving) {
        [self endProcess];
    }
    
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

- (void)p_initNetworkStatusObserver {
    
    __weak typeof(self) weakSelf = self;
    [NINetMonitor startMonitorWithCallBack:^(NINetworkStatus networkStatus) {
        switch (networkStatus) {
            case NotReachable:
                
                [weakSelf pause];
                [weakSelf.playerControl playErrorStatus:PlayerErrorStatusNotReachable];
                break;
            case ReachableViaWiFi:{
                [weakSelf rePlay];
            }
    
                break;
            case ReachableViaWWAN:{
                [weakSelf.player stop];
                [weakSelf.playerControl playErrorStatus:PlayerErrorStatusNetViaWWAN];
            }

                break;
                
            default:
                break;
        }
    }];
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
            if (_isLiving) {
                [self play];
            } else {
                [self pause];
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
        if ([APP_DELEGATE respondsToSelector:@selector(setAllowRotationType:)]) {
            APP_DELEGATE.allowRotationType = AllowRotationMaskPortrait;
        }
    }
}


//即将进入后台
- (void)p_applicationWillResignActive {
    _beforeBackIsPlay = self.player.isPlaying;
    [self pause];
    
    [self p_removeDeviceOrientationObserver];
    if (_isFullScreen) {
        if ([APP_DELEGATE respondsToSelector:@selector(setAllowRotationType:)]) {
            APP_DELEGATE.allowRotationType = AllowRotationMaskLandscapeLeftOrRight;
        }
        
    }
}





// 实现 <PLPlayerDelegate> 来控制流状态的变更
- (void)player:(nonnull PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    
    if (PLPlayerStatusCaching == state) {
        [self.playerControl startLoading];
        [self startLoadingTimer];
    } else {
        [self.playerControl endLoading];
    }
    
    switch (state) {
        case PLPlayerStatusPreparing:
            
            break;
        case PLPlayerStatusReady:
            
            break;
        case PLPlayerStatusCaching:
            
            break;
        case PLPlayerStatusPlaying:{
            [self.playerControl setPlay:YES];
            [self.playerControl endLoading];
        }
            
            break;
        case PLPlayerStatusPaused:{
            [self.playerControl setPlay:NO];
        }
            
            break;
        case PLPlayerStatusStopped:{
            [self.playerControl setPlay:NO];

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
    
    

}

- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error {
    // 当发生错误，停止播放时，会回调这个方法
    NSLog(@"%@",error);
    if (_isFullScreen) {
        [self fullScreen:UIDeviceOrientationPortrait];
    }
    [self.playerControl endLoading];
    
    if (NINetMonitor.currentReachabilityStatus == NotReachable) {
        [self.playerControl playErrorStatus:PlayerErrorStatusNotReachable];
    } else {
        [self.playerControl playErrorStatus:PlayerErrorStatusError];
    }
    
}

- (void)player:(nonnull PLPlayer *)player codecError:(nonnull NSError *)error {
    // 当解码器发生错误时，会回调这个方法
    // 当 videotoolbox 硬解初始化或解码出错时
    // error.code 值为 PLPlayerErrorHWCodecInitFailed/PLPlayerErrorHWDecodeFailed
    // 播发器也将自动切换成软解，继续播放
    NSLog(@"%@",error);
    
    if (_isFullScreen) {
        [self fullScreen:UIDeviceOrientationPortrait];
    }
    [self.playerControl endLoading];
    
    if (NINetMonitor.currentReachabilityStatus == NotReachable) {
        [self.playerControl playErrorStatus:PlayerErrorStatusNotReachable];
    } else {
        [self.playerControl playErrorStatus:PlayerErrorStatusError];
    }

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

- (void)playerControl:(UIView *)control shareAction:(UIButton *)sender {
    if (_playerDelegate) {
        if ([_playerDelegate respondsToSelector:@selector(playerShareBtnAction)]) {
            [_playerDelegate playerShareBtnAction];
        }
    }
}

- (void)playerControl:(UIView *)control errorAction:(PlayerErrorStatus)status {
    switch (status) {
        case PlayerErrorStatusError:{
            [self rePlay];
        }
            
            break;
        case PlayerErrorStatusNetViaWWAN:{
            [self rePlay];
        }
            
            break;
        case PlayerErrorStatusNotReachable:
            
            break;
            
        default:
            break;
    }
}

- (void)playerControl:(UIView *)control fullScreenAction:(UIButton *)sender {
    if (_isFullScreen) {
        _isLock = NO;
        [self fullScreen:UIDeviceOrientationPortrait];
        
    }else {
        [self fullScreen:UIDeviceOrientationLandscapeLeft];
//        if (!sender.selected) {
//            
//        } else {
//            [self fullScreen:UIDeviceOrientationPortrait];
//        }
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
/**
 进入全屏
 */
- (void)becomeFullScreen {
     [self fullScreen:UIDeviceOrientationLandscapeLeft];
}
- (void)becomeMiniScreen {
    [self fullScreen:UIDeviceOrientationPortrait];
}


- (void)fullScreen:(UIDeviceOrientation)orientation {
    if (![self judgeIfCanRotate:orientation]) return;
    
    CGAffineTransform tranform = [self getRotateTransform:orientation];
    _currentOrientiation = orientation;
    
    if (orientation == UIDeviceOrientationLandscapeLeft
        ||orientation ==UIDeviceOrientationLandscapeRight ) { //全屏
        [self.playView removeFromSuperview];
        
        APP_DELEGATE.allowRotationType = AllowRotationMaskLandscapeLeftOrRight;
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.playView];
        
        CGFloat width = MAX(SCREEN_WIDTH, SCREEN_HEIGHT);
        CGFloat height = MIN(SCREEN_WIDTH, SCREEN_HEIGHT);
        _playerControl.hidden = YES;
        [UIView animateWithDuration:0.3f animations:^{
            if (!_isFullScreen) {
                CGRect frame = CGRectMake((height - width)/2.0,(width - height)/2.0, width, height);
                
                [self resetFrame:frame];
            }
            [self.playView setTransform:tranform];
            
        }completion:^(BOOL finished) {
            _playerControl.hidden = NO;
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
        }];
        
        APP.statusBarOrientation = (UIInterfaceOrientation)orientation;
        APP.statusBarStyle = UIStatusBarStyleLightContent;
        APP.statusBarHidden = NO;
        self.isFullScreen = YES;
        
        //添加手势控制
        //        [self p_addPanRecognizer];
        
    } else if (orientation == UIDeviceOrientationPortrait) { //小屏幕
        [self.playView removeFromSuperview];
        
        APP_DELEGATE.allowRotationType = AllowRotationMaskPortrait;
        //移除亮度控制
        [self.superPlayerView addSubview:self.playView];
        _playerControl.hidden = YES;
        [UIView animateWithDuration:0.3f animations:^{
            [self.playView setTransform:tranform];
            [self resetFrame:_superPlayerView.bounds];
        }completion:^(BOOL finished) {
            _playerControl.hidden = NO;
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
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
    
    
    if (_isFullScreen && !_isClosedBarrage) {
        [self showBarrageView];

    }else {
        [self.barrageView clearScreen];
        [self.barrageView removeFromSuperview];
    }
    
}

//弹幕
- (void)playerBarrageAction:(UIButton *)sender {
    _isClosedBarrage = sender.selected;
    if (_isFullScreen && !_isClosedBarrage) {
        [self showBarrageView];

    } else {
        [self.barrageView removeFromSuperview];
    }
}

- (void)sendBarrageWithText:(NSString *)text {
    if (_isFullScreen && !_isClosedBarrage) {
        [self.barrageView sendBarrage:text];
    }
}

- (void)showBarrageView {
    [self.playView addSubview:self.barrageView];
    self.barrageView.frame = CGRectMake(0, _playerControl.frame.origin.y + 49, _playerControl.frame.size.width,_playerControl.frame.size.height - 49 );
    self.barrageView.userInteractionEnabled = NO;
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
    if (_isLiving) return;
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(timerFunction:) userInfo:nil repeats:YES];
    }
}

- (void)startLoadingTimer {
    if (!_loadingTimer) {
        _loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadingObserver) userInfo:nil repeats:YES];
    }
}


- (void) endProcess {
    if (_isLiving) return;
    if (_timer) {
        [_timer invalidate];
        self.timer  = nil;
    }
}

- (void)loadingObserver {
    if ([self.player isPlaying]) {
        [self.playerControl endLoading];
    }
    [self endLoadingTimer];
}

- (void)endLoadingTimer {
    if (_loadingTimer) {
        [_loadingTimer invalidate];
        self.loadingTimer  = nil;
    }
}


- (void)timerFunction:(NSTimer *) timer {
    if (self.player.playing  && !_isSeeking) {

        double currentTime = CMTimeGetSeconds(self.player.currentTime);
        double totalTime = CMTimeGetSeconds(self.player.totalDuration);
        [_playerControl playTo:currentTime totalTime:totalTime];
    }
}

- (PackControlScheduler *)playerControl {
    if (!_playerControl) {
        _playerControl = [[PackControlScheduler alloc] initWithType:_isLiving];
    }
    return _playerControl;
}

- (IBCBarrageView *)barrageView {
    if (!_barrageView) {
        _barrageView = [[IBCBarrageView alloc] init];
    }
    return _barrageView;
}

- (BOOL)isFullSize {
    return _isFullScreen;
}


@end
