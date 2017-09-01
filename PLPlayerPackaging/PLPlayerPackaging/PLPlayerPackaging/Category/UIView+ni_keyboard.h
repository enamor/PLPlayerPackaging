//
//  UIView+keyboard.h
//  NIControls
//
//  Created by zhouen on 2017/6/9.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , SuspensionType){
    SuspensionTypeBottom = 0, //底部停留
    SuspensionTypeHiden,      //底部隐藏
};

@interface UIView (ni_keyboard)

@property (nonatomic, assign) SuspensionType type;

- (void)addKeyboardObserver;


/**
 分两种类型

 @param type 1：弹出后停留在底部 、2 、消失
 */
- (void)addKeyboardObserverWithType:(SuspensionType)type;
- (void)removeKeyboardObserver;

@end
