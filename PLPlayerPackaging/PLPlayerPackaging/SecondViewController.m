//
//  SecondViewController.m
//  PLPlayerPackaging
//
//  Created by zhouen on 2017/8/22.
//  Copyright © 2017年 nina. All rights reserved.
//

#import "SecondViewController.h"
#import "PackPlayer.h"

@interface SecondViewController ()<PackPlayerDelegate>
@property (nonatomic, strong) PackPlayer *player;
@property (nonatomic, strong) UIView *playView;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [PackPlayer sharedPlayer].playerDelegate = self;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.playView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 200)];
    [self.view addSubview:_playView];
    
    
    
    UIButton *btn1 = [[UIButton alloc ]initWithFrame:CGRectMake(100, 300, 100, 40)];
    [btn1 setTitle:@"直播" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(livingPlayer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    
    UIButton *btn2 = [[UIButton alloc ]initWithFrame:CGRectMake(240, 300, 100, 40)];
    [btn2 setTitle:@"视频" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(videoPlayer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}

- (void)livingPlayer {
    NSString *url = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
    [PackPlayer playWithUrl:url onView:_playView];
    [PackPlayer setTitle:@"正在直播"];
}

- (void)videoPlayer {
    NSString *url = @"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4";
    [PackPlayer playWithUrl:url onView:_playView];
    [PackPlayer setTitle:@"正在看视频"];
}
- (void)dealloc {
    [PackPlayer releasePlayer];
}

#pragma mark - PlayerDelegate
//  返回
- (void)playerBackBtnAction {
    [PackPlayer releasePlayer];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)playerShareAction:(UIButton *)sender {
    
}
//控件是否隐藏
- (void)playerControlHidden:(BOOL)isHidden {
//    APP.statusBarHidden = isHidden;
}

//即将旋转屏幕
- (void)screenOrientationWillChange {
    [self.view endEditing:YES];
}

//发送
- (void)playerChatView:(PlayerFullChatView *)chatView SendAction:(UITextField *)textField {
    [[PackPlayer sharedPlayer] sendBarrageWithText:@"我自己发的" isMine:YES];
    textField.text = nil;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //如果是用的自动布局需要添加以下方法
    [[PackPlayer sharedPlayer] initPlayerLayer];
}

@end
