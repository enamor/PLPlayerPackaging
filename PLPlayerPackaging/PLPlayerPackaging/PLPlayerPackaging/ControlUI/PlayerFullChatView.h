//
//  PlayerFullChatView.h
//  PLPlayerPackaging
//
//  Created by zhouen on 2017/8/30.
//  Copyright © 2017年 nina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerFullChatView;
@protocol PlayerFullChatViewDelegate <NSObject>

- (void)chatView:(PlayerFullChatView *)chatView sendAction:(UITextField *)textField;

@end

@interface PlayerFullChatView : UIView
- (void)becomeResponder;
- (void)resignResponder;
- (BOOL)isFirstResponder;

@property (nonatomic, weak) id<PlayerFullChatViewDelegate> delegate;
@property (nonatomic, copy) NSString *placeHolder;
@end
