//
//  IBCBarrageView.m
//  FYJI
//
//  Created by zhouen on 2017/8/30.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "IBCBarrageView.h"
#import "HJDanmaku.h"
#import "DemoDanmakuModel.h"
@interface IBCBarrageView ()<HJDanmakuViewDateSource, HJDanmakuViewDelegate>
@property (nonatomic, strong) HJDanmakuView *danmakuView;

@end
@implementation IBCBarrageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_initUI];
    }
    return self;
}

- (void)p_initUI {
    HJDanmakuConfiguration *config = [[HJDanmakuConfiguration alloc] initWithDanmakuMode:HJDanmakuModeLive];
    self.danmakuView = [[HJDanmakuView alloc] initWithFrame:self.bounds configuration:config];
    self.danmakuView.configuration.maxShowCount = 4;
    self.danmakuView.dataSource = self;
    self.danmakuView.delegate = self;
    [self.danmakuView registerClass:[HJDanmakuCell class] forCellReuseIdentifier:@"cell"];
    self.danmakuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.danmakuView];

}

- (void)sendBarrage:(NSString *)text isSelf:(BOOL)isSelf{
    if (!self.danmakuView.isPrepared) {
        [self.danmakuView prepareDanmakus:nil];
    }
    
    HJDanmakuType type = HJDanmakuTypeLR;
    DemoDanmakuModel *danmakuModel = [[DemoDanmakuModel alloc] initWithType:type];
    danmakuModel.selfFlag = isSelf;
    danmakuModel.text = text;
    danmakuModel.textFont = [UIFont systemFontOfSize:15];
    danmakuModel.textColor = [UIColor whiteColor];
    [self.danmakuView sendDanmaku:danmakuModel forceRender:NO];
}

#pragma mark - delegate

- (void)prepareCompletedWithDanmakuView:(HJDanmakuView *)danmakuView {
    [self.danmakuView play];
}

- (BOOL)danmakuView:(HJDanmakuView *)danmakuView shouldSelectCell:(HJDanmakuCell *)cell danmaku:(HJDanmakuModel *)danmaku {
    return danmaku.danmakuType == HJDanmakuTypeLR;
}

- (void)danmakuView:(HJDanmakuView *)danmakuView didSelectCell:(HJDanmakuCell *)cell danmaku:(HJDanmakuModel *)danmaku {
    NSLog(@"select=> %@", cell.textLabel.text);
}

#pragma mark - dataSource

- (CGFloat)danmakuView:(HJDanmakuView *)danmakuView widthForDanmaku:(HJDanmakuModel *)danmaku {
    DemoDanmakuModel *model = (DemoDanmakuModel *)danmaku;
    return [model.text sizeWithAttributes:@{NSFontAttributeName: model.textFont}].width + 1.0f;
}

- (HJDanmakuCell *)danmakuView:(HJDanmakuView *)danmakuView cellForDanmaku:(HJDanmakuModel *)danmaku {
    DemoDanmakuModel *model = (DemoDanmakuModel *)danmaku;
    HJDanmakuCell *cell = [danmakuView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = HJDanmakuCellSelectionStyleDefault;
//    cell.alpha = 0.5;
    if (model.selfFlag) {
        cell.zIndex = 30;
        cell.layer.borderWidth = 1;
        cell.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    cell.textLabel.font = model.textFont;
    cell.textLabel.textColor = model.textColor;
    cell.textLabel.text = model.text;
    return cell;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.danmakuView.frame = self.bounds;
}

- (void)clearScreen {
    [self.danmakuView clearScreen];
}


@end
