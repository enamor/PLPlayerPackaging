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

@property (nonatomic, assign ,readonly) BOOL isLiving; //是否为直播

@property (nonatomic, weak) id<PackPlayerDelegate> playerDelegate;
@property (nonatomic, readonly, strong) UIView *playView;

@property (nonatomic, readonly, assign) BOOL isFullSize;


@property (nonatomic, copy) NSString *title;


/**
 是否为直播(直接init的方式创建会自动判断是否为直播)

 @param isLiving yes直播、no 非直播
 @return self
 */
- (instancetype)initWithType:(BOOL)isLiving  onView:(UIView *)view;

- (void)playWithUrl:(NSString *)strUrl;

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

- (void)releasePlayer;

//发送弹幕
- (void)sendBarrageWithText:(NSString *)text;


/**
 进入全屏
 */
- (void)becomeFullScreen;

/**
 进入小屏
 */
- (void)becomeMiniScreen;

//用自动布局需要调用此方法
- (void)initFrame;


@end
