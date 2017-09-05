//
//  ViewController.m
//  PLPlayerPackaging
//
//  Created by zhouen on 2017/8/22.
//  Copyright © 2017年 nina. All rights reserved.
//

#import "ViewController.h"
#import "PackPlayer.h"
#import "SecondViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIView *playView;
@property (nonatomic, strong) PackPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _player = [[PackPlayer alloc] init];
    
//    self.playView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 200)];
//    _playView.backgroundColor = [UIColor blackColor];
//    
//    NSString *url = @"http://baobab.wdjcdn.com/1456653443902B.mp4";
//    [self.view addSubview:_playView];
//    
//    [_player playWithUrl:url onView:_playView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 400, 250, 100)];
    [btn setTitle:@"进入下一页播放视频" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor blackColor];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];

}

- (void)btnAction {
//    NSString *url = @"http://baobab.wdjcdn.com/1456653443902B.mp4";
//    [_player playWithUrl:url onView:_playView];
    [self.navigationController pushViewController:[SecondViewController new] animated:YES];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
