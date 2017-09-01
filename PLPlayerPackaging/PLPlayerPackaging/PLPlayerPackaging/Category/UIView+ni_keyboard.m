//
//  UIView+keyboard.m
//  NIControls
//
//  Created by zhouen on 2017/6/9.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "UIView+ni_keyboard.h"
#import <objc/message.h>


//typedef NS_ENUM(NSInteger, UIViewAnimationCurve) {
//    UIViewAnimationCurveEaseInOut,         // 开始时慢，中间快，结束时慢
//    UIViewAnimationCurveEaseIn,            // 开始慢，然后加速
//    UIViewAnimationCurveEaseOut,           // 逐渐减速
//    UIViewAnimationCurveLinear             // 匀速
//};


static const void *KSuspensionType = @"KSuspensionType";

@implementation UIView (ni_keyboard)

-(void)addKeyboardObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)addKeyboardObserverWithType:(SuspensionType)type {
    self.type = type;
    
    [self addKeyboardObserver];
}



- (void)removeKeyboardObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (SuspensionType)type {
    return  [objc_getAssociatedObject(self, &KSuspensionType) integerValue];
}

- (void)setType:(SuspensionType)type {
    objc_setAssociatedObject(self, &KSuspensionType, @(type), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(void)keyboardChangeFrame:(NSNotification*)noti;
{
    CGFloat heigt = self.superview.frame.size.height;
    CGRect bRect = self.frame;

    CGRect rect= [noti.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat keyboardheight = rect.size.height;
    CGFloat duration=[noti.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    CGFloat curve=[noti.userInfo[UIKeyboardAnimationCurveUserInfoKey]doubleValue];
    
    bRect.origin.y = heigt - bRect.size.height - keyboardheight;
    
    [UIView setAnimationCurve:curve];
    [UIView animateWithDuration:duration animations:^{
        self.frame = bRect;
    } completion:^(BOOL finished) {
        
    }];
    
}


-(void)keyboardHide:(NSNotification *)noti
{
    [self endEditing:YES];
    CGFloat heigt = self.superview.frame.size.height;
    CGRect rect = self.frame;
    if (self.type == SuspensionTypeBottom) {
        rect.origin.y = heigt - rect.size.height;
    }else {
        rect.origin.y = heigt ;
    }

    [UIView animateWithDuration:0.3 animations:^{
        self.frame = rect;
    } completion:^(BOOL finished) {
        
    }];
    
}
@end
