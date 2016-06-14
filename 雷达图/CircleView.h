//
//  CircleView.h
//  雷达图
//
//  Created by 席亚坤 on 15/6/13.
//  Copyright © 2015年 席亚坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleView : UIView
{
    CGFloat _startAngle; // 开始的角度
    NSInteger _startRate;
}
@property (nonatomic, assign) CGFloat vWidth;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIBezierPath *bPath;
@property (nonatomic, strong) UILabel *rateLbl;
@property (nonatomic, assign) NSInteger rate; // 中间显示的数字

- (void)startAnimation; // 开始动画

@end
