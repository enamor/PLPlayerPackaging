//
//  PackPlayerSlider.m
//  AVPlayer
//
//  Created by zhouen on 2017/6/1.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#import "PackPlayerSlider.h"

@interface PackPlayerSlider ()
@property (nonatomic,strong) UIProgressView *cacheProgress;
@property (nonatomic, strong) UISlider *cacheSlider;

@end

@implementation PackPlayerSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.continuous = NO ;
        self.maximumTrackTintColor = [UIColor clearColor];
        [self p_initUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.maximumTrackTintColor = [UIColor clearColor];
    [self p_initUI];
}



- (void)p_initUI {
    self.cacheSlider = [[PackPlayerCacheSlider alloc] init];
    _cacheSlider.thumbTintColor = [UIColor clearColor];
    [self addSubview:_cacheSlider];
    _cacheSlider.userInteractionEnabled = NO;

}
- (void)layoutSubviews {
    [super layoutSubviews];
    _cacheSlider.frame = self.bounds;
}

- (void)setCacheTrackTintColor:(UIColor *)cacheTrackTintColor {
    _cacheTrackTintColor = cacheTrackTintColor;
    self.cacheSlider.minimumTrackTintColor = _cacheTrackTintColor;
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    [super setMaximumTrackTintColor:[UIColor clearColor]];
    _cacheSlider.maximumTrackTintColor = maximumTrackTintColor;
}

- (void)setCacheValue:(CGFloat)cacheValue {
    _cacheValue = cacheValue;
    self.cacheSlider.value = _cacheValue;
}


- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    rect.origin.x = rect.origin.x - 3 ;
    rect.size.width = rect.size.width + 6;
    return [super thumbRectForBounds:bounds trackRect:rect value:value];
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
    bounds.origin.y = bounds.size.height / 2.0 - 1;
    bounds.size.height = 2;
    return bounds;
}

@end

@implementation PackPlayerCacheSlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    rect.origin.x = rect.origin.x - 11 ;
    rect.size.width = rect.size.width + 22;
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 11 , 11);
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
    bounds.origin.y = bounds.size.height / 2.0 - 1;
    bounds.size.height = 2;
    return bounds;
}

@end

