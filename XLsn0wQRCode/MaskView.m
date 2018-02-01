//
//  MaskView.m
//  EnNew
//
//  Created by xm on 16/3/23.
//  Copyright © 2016年 EnNew. All rights reserved.
//

#import "MaskView.h"

@interface MaskView ()

@property (nonatomic, strong) UIImageView *paneImageView;

@end

@implementation MaskView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, self.maskRect);
    CGContextAddRect(context, rect);
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] setFill];
    CGContextDrawPath(context, kCGPathEOFill);
}

- (void)setMaskRect:(CGRect)maskRect {
    _maskRect = maskRect;
    self.paneImageView.frame = maskRect;
    [self addSubview:self.paneImageView];
    [self setNeedsDisplay];
}

- (UIImageView *)paneImageView {
    if (!_paneImageView) {
        _paneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan"]];
    }
    return _paneImageView;
}

@end
