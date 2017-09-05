//
//  UIView+NI_SuperVC.m
//  PLPlayerPackaging
//
//  Created by zhouen on 2017/9/4.
//  Copyright © 2017年 nina. All rights reserved.
//

#import "UIView+NI_SuperVC.h"

@implementation UIView (NI_SuperVC)
//获取控制器
- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}
@end
