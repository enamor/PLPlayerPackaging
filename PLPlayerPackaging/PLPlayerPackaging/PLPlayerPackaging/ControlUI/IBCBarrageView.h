//
//  IBCBarrageView.h
//  FYJI
//
//  Created by zhouen on 2017/8/30.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IBCBarrageView : UIView
- (void)sendBarrage:(NSString *)text  isSelf:(BOOL)isSelf;

- (void)clearScreen;
@end
