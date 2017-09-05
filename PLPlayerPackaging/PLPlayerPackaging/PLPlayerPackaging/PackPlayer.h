//
//  PackPlayer.h
//  PLPlayerPackaging
//
//  Created by zhouen on 2017/8/22.
//  Copyright © 2017年 nina. All rights reserved.
//

/*
 *  尼玛恶心的七牛播放器 2.3 频繁切换播放有崩溃问题  2.4.3 pause无效  3.0.0 frame设置无效
 *  ------------------------我也是醉了
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PlayerOuterProtocol.h"
#import "PackPlayerMacro.h"
#import "NINetMonitor.h"

@protocol PackPlayerDelegate <NSObject ,PlayerOuterProtocol>

@optional

- (void)playerBackBtnAction;
- (void)playerShareBtnAction;

@end

@interface PackPlayer : NSObject

//播放器所在view
@property (nonatomic, readonly, strong) UIView  *playView;

//是否为直播
@property (nonatomic, readonly, assign) BOOL    isLiving;


@property (nonatomic, weak) id<PackPlayerDelegate> playerDelegate;

//播放器是否全屏状态
@property (nonatomic, readonly, assign) BOOL isFullSize;


@property (nonatomic, copy) NSString *title;


+ (instancetype)sharedPlayer;

- (void)playWithUrl:(NSString *)strUrl onView:(UIView *)view;

/**
 *  Player开启视频
 */
- (void)play;

/**
 *  Player暂停视频
 */
- (void)pause;

/**
 *  Player停止播放
 */
- (void)stop;

/**
 *  释放播放器
 */
- (void)releasePlayer;

//发送弹幕
- (void)sendBarrageWithText:(NSString *)text isMine:(BOOL)isMine;


/**
 进入全屏
 */
- (void)becomeFullScreen;

/**
 进入小屏
 */
- (void)becomeMiniScreen;

//用自动布局需要调用此方法
- (void)initPlayerLayer;



//此方法自动创建单例
+ (void)playWithUrl:(NSString *)strUrl onView:(UIView *)view;

+ (void)releasePlayer;

/**
 *  Player开启视频
 */
+ (void)play;

/**
 *  Player暂停视频
 */
+ (void)pause;

/**
 *  Player停止播放
 */
+ (void)stop;

+ (void)setTitle:(NSString *)title;

@end
