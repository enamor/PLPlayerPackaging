//
//  PlayerOuterProtocol.h
//  PLPlayerPackaging
//
//  Created by zhouen on 2017/8/30.
//  Copyright © 2017年 nina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerFullChatView.h"
@protocol PlayerOuterProtocol <NSObject>
@optional
//发送
- (void)playerChatView:(PlayerFullChatView *)chatView SendAction:(UITextField *)textField;

//分享
- (void)playerShareAction:(UIButton *)sender ;

//是否隐藏控制层
- (void)playerControlHidden:(BOOL)isHidden;


//大小屏即将改变
- (void)screenOrientationWillChange;

@end
