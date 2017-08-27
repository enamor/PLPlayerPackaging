//
//  PackPlayer.h
//  PLPlayerPackaging
//
//  Created by zhouen on 2017/8/22.
//  Copyright © 2017年 nina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PackPlayerDelegate <NSObject>

- (void)playerBackBtnAction;

@end

@interface PackPlayer : NSObject

@property (nonatomic, assign ,readonly) BOOL isLiving; //是否为直播

@property (nonatomic, weak) id<PackPlayerDelegate> playerDelegate;

@property (nonatomic, copy) NSString *title;

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
@end
