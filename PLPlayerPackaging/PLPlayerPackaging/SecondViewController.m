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
    [super viewDidLoad];
    
    _player = [[PackPlayer alloc] init];
    _player.playerDelegate = self;
    
    self.playView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 200)];
    [self.view addSubview:_playView];
    
    
    
    
    UIButton *btn = [[UIButton alloc ]initWithFrame:CGRectMake(100, 300, 100, 100)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnaction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // Do any additional setup after loading the view.
}

- (void)btnaction {
    [_player playWithUrl:@"http://baobab.wdjcdn.com/1456653443902B.mp4" onView:_playView];
    _player.title = @"哈哈哈哈哈哈哈";
}
- (void)dealloc {
    [self.player releasePlayer];
    NSLog(@"销毁");
}

- (void)playerBackBtnAction {
    [self.player releasePlayer];
//    [_playView removeFromSuperview];
//    self.playView = nil;
    self.player = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotate {
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
