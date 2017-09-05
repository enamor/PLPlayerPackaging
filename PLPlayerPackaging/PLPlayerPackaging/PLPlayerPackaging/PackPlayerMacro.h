//
//  PackPlayerMacro.h
//  NIPlayer
//
//  Created by zhouen on 2017/6/2.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#ifndef PackPlayerMacro_h
#define PackPlayerMacro_h

#import "AppDelegate.h"

// 屏幕尺寸
#define SCREEN_BOUNDS    [UIScreen mainScreen].bounds
// 屏幕宽
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
// 屏幕高
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height


#define  weakly  __weak typeof(self) weakSelf = self;

//点击聊天 通知外部
#define Will_Chat @"Will_Chat"
#define Will_Chat_Notification [[NSNotificationCenter defaultCenter] postNotificationName:Will_Chat object:nil]



/** 获取NIPlayer.bundle中图片 */
#define BUNDLE_PATH [[NSBundle mainBundle] pathForResource:@"Pack" ofType:@"bundle"]
#define IMAGE_PATH(img) [BUNDLE_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",img]]
#define BUNDLE_IMAGE(img) [UIImage imageWithContentsOfFile:IMAGE_PATH(img)]


//十六进制颜色
#define HEX_COLOR_A(rgbValue ,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define HEX_COLOR(rgbValue) HEX_COLOR_A(rgbValue,1.0)

#define APP_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define APP [UIApplication sharedApplication]
#endif /* NIPlayerMacro_h */
