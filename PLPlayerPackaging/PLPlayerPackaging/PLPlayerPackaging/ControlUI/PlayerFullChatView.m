//
//  PlayerFullChatView.m
//  PLPlayerPackaging
//
//  Created by zhouen on 2017/8/30.
//  Copyright © 2017年 nina. All rights reserved.
//

#import "PlayerFullChatView.h"

@interface PlayerFullChatView ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;

@end
@implementation PlayerFullChatView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_initUI];
    }
    return self;
}

- (void)p_initUI {
    self.textField = [[UITextField alloc] init];
    self.textField.delegate = self;
    [self addSubview:_textField];
    
    self.textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 1)];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.textField.placeholder = @"我来说两句...";
    
    self.textField.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    self.textField.returnKeyType = UIReturnKeySend;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat margin = 6;
    self.textField.frame = CGRectMake(10, margin, self.frame.size.width - 20 ,self.frame.size.height - 2*margin);
    
    self.textField.layer.cornerRadius = _textField.frame.size.height / 2.0;
    self.textField.layer.masksToBounds = YES;
    
}


- (void)setPlaceHolder:(NSString *)placeHolder {
    self.textField.placeholder = placeHolder;
}

- (void)becomeResponder {
    [self.textField becomeFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(chatView:sendAction:)]) {
        [_delegate chatView:self sendAction:textField];
    }
    [self.textField resignFirstResponder];
    return YES;
}

- (void)resignResponder {
    [self.textField resignFirstResponder];
}

- (BOOL)isFirstResponder {
    return [self.textField isFirstResponder];
}
@end
