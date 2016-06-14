//
//  CircleView.m
//  雷达图
//
//  Created by 席亚坤 on 15/6/13.
//  Copyright © 2015年 席亚坤. All rights reserved.
//

#import "CircleView.h"
#define LineWidth 2

@implementation CircleView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _startAngle = -90; // 从圆的最顶部开始
        _startRate = 0;
        _vWidth = frame.size.width;
        _bPath = [UIBezierPath bezierPath];
        // label
        [self configLbl];
        // 先画一个底部的圆
        [self configBgCircle];
        // 配置CAShapeLayer
        [self configShapeLayer];
        // 配置CADisplayLink
        [self configDisplayLink];
    }
    return self;
}

#pragma mark - event response

- (void)drawCircle {
    if (_startRate >= _rate) {
        _bPath = [UIBezierPath bezierPath];
        _displayLink.paused = YES;
        return;
    }
    _startRate ++;
    _rateLbl.text = [NSString stringWithFormat:@"%ld%%", _startRate];
    [_bPath addArcWithCenter:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5) radius:_vWidth * 0.5 startAngle:(M_PI / 180.0) * _startAngle endAngle:(M_PI / 180.0) * (_startAngle + 3.6) clockwise:YES];
    _shapeLayer.path = _bPath.CGPath;
    _startAngle += 3.6;
}

#pragma mark - public methods

- (void)startAnimation {
    if (_displayLink.paused == YES) {
        _startAngle = -90;
        _startRate = 0;
        _displayLink.paused = NO;
    }
}

#pragma mark - private methods

#pragma mark 中间显示数字的Label
- (void)configLbl {
    CGFloat rateLblX = 10;
    CGFloat rateLblW = self.frame.size.width - 2 * rateLblX;
    CGFloat rateLblH = 40;
    CGFloat rateLblY = (self.frame.size.height - rateLblH) * 0.5;
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(rateLblX, rateLblY, rateLblW, rateLblH)];
    _rateLbl = lbl;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.textColor = [UIColor blackColor];
    lbl.text = @"0%";
    [self addSubview:lbl];
}

#pragma mark 底下灰色的圆
- (void)configBgCircle {
    UIBezierPath *bPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5) radius:_vWidth * 0.5 startAngle:0 endAngle:360 clockwise:YES];
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
    shaperLayer.fillColor = [UIColor clearColor].CGColor;
    shaperLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    shaperLayer.lineWidth = LineWidth;
    shaperLayer.path = bPath.CGPath;
    [self.layer addSublayer:shaperLayer];
}

#pragma mark 配置CAShaperLayer
- (void)configShapeLayer {
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.strokeColor = [UIColor redColor].CGColor;
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;
    _shapeLayer.lineWidth = LineWidth;
    [self.layer addSublayer:_shapeLayer];
}

#pragma mark 配置CADisplayLink
- (void)configDisplayLink {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawCircle)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _displayLink.paused = YES; // 默认暂停
}

#pragma mark - getter/setter

- (void)setRate:(NSInteger)rate {
    if (rate <= 0 || rate > 100) {
        rate = 100;
    } else {
        _rate = rate;
    }
}

@end
