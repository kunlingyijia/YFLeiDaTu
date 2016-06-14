//
//  RadarView.m
//  雷达图
//
//  Created by 席亚坤 on 15/6/13.
//  Copyright © 2015年 席亚坤. All rights reserved.
//

#import "RadarView.h"

@implementation RadarView{
    //Value and key
    NSMutableDictionary *_valueDictionary;
    
    CGFloat _centerX;
    CGFloat _centerY;
    
    //Plotting and UI Array
    NSMutableArray *_pointsLengthArrayArray;
    NSMutableArray *_pointsToPlotArray;
    
    //Animation
    CADisplayLink *_displayLink;
    NSMutableDictionary *_animationStepValueDictionary;
    NSMutableDictionary *_targetValueDictionary;;
    
}


- (id)initWithFrame:(CGRect)frame valueDictionary:(NSDictionary *)valueDictionary
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        
        //Private iVar
        _valueDictionary = [valueDictionary mutableCopy];
        _pointsLengthArrayArray = [NSMutableArray array];
        _pointsToPlotArray = [NSMutableArray array];
        
        
        //Public iVar
        _maxValue = 0;
        _valueDivider = 1;
        _drawboardColor = [UIColor blackColor];
        _plotColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.9];
        
        [self calculateAllPoints];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    // cuts
    NSArray *largestPointArray = [_pointsLengthArrayArray lastObject];
    for (NSValue* pointValue in largestPointArray){
       // NSLog(@"%@",pointValue);
        CGContextRef graphContext = UIGraphicsGetCurrentContext();
        CGContextBeginPath(graphContext);
        CGContextMoveToPoint(graphContext, _centerX, _centerY);
        CGPoint point = [pointValue CGPointValue];
        CGContextAddLineToPoint(graphContext, point.x, point.y);
        CGContextSetStrokeColorWithColor(graphContext, _drawboardColor.CGColor);
        CGContextStrokePath(graphContext);
    }
    ///最小元的半径
    CGFloat  R=
    [self distanceFromPointX:self.center distanceToPointY:[[largestPointArray firstObject] CGPointValue]]/_pointsLengthArrayArray.count;
    //圆
    for (int i = 0 ; i<_pointsLengthArrayArray.count; i++) {
        CGContextRef graphContext = UIGraphicsGetCurrentContext();
        //边框圆
        CGContextSetRGBStrokeColor(graphContext,1,1,1,1.0);//画笔线的颜色
        CGContextSetLineWidth(graphContext, 1.0);//线的宽度
        
        CGContextAddArc(graphContext, self.bounds.size.width/2, self.bounds.size.height/2, R*(i+1), 0, 2*PI, 0); //添加一个圆
        CGContextSetStrokeColorWithColor(graphContext, _drawboardColor.CGColor);
        CGContextDrawPath(graphContext, kCGPathStroke); //绘制路径
        CGContextStrokePath(graphContext);
    }

    // plot
    if (YES) {
        CGContextRef graphContext = UIGraphicsGetCurrentContext();
        CGContextBeginPath(graphContext);
        CGPoint beginPoint = [[_pointsToPlotArray objectAtIndex:0] CGPointValue];
        CGContextMoveToPoint(graphContext, beginPoint.x, beginPoint.y);
        for (NSValue* pointValue in _pointsToPlotArray){
            CGPoint point = [pointValue CGPointValue];
            CGContextAddLineToPoint(graphContext, point.x, point.y);
        }
        CGContextSetFillColorWithColor(graphContext, _plotColor.CGColor);
        CGContextFillPath(graphContext);
    }
    
}
//两点之间的距离
-(float)distanceFromPointX:(CGPoint)start distanceToPointY:(CGPoint)end{
    float distance;
    //下面就是高中的数学，不详细解释了
    CGFloat xDist = (end.x - start.x);
    CGFloat yDist = (end.y - start.y);
    distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}
#pragma mark - Main Function
- (void)calculateAllPoints
{
    [_pointsLengthArrayArray removeAllObjects];
    [_pointsToPlotArray removeAllObjects];
    
    //init Angle, Key and Value
    NSArray *keyArray = [_valueDictionary allKeys];
    NSArray *valueArray = [self getValueArrayFromDictionary:_valueDictionary keyArray:keyArray];
    _maxValue = [self getMaxValueFromValueArray:valueArray];
    NSArray *angleArray = [self getAngleArrayFromNumberOfSection:(int)[keyArray count]];
    
    //Calculate all the lengths
    CGFloat boundWidth = self.bounds.size.width;
    CGFloat boundHeight =  self.bounds.size.height;
    _centerX = boundWidth/2;
    _centerY = boundHeight/2;
    CGFloat maxLength = MIN(boundWidth, boundHeight) * 17/40;
    NSLog(@"%f",maxLength);
    int plotCircles = (_maxValue/_valueDivider);
    CGFloat lengthUnit = maxLength/plotCircles;
    NSArray *lengthArray = [self getLengthArrayWithLengthUnit:lengthUnit maxLength:maxLength];
    
    //get all the points and plot
    for (NSNumber *lengthNumber in lengthArray) {
        CGFloat length = [lengthNumber floatValue];
        [_pointsLengthArrayArray addObject:[self getPlotPointWithLength:length angleArray:angleArray]];
    }
    
    int section = 0;
    for (id value in valueArray) {
        CGFloat valueFloat = [value floatValue];
        if (valueFloat > _maxValue) {
            NSLog(@"ERROR - Value number is higher than max value - value: %f - maxValue: %f", valueFloat, _maxValue);
            return;
        }
        
        CGFloat length = valueFloat/_maxValue * maxLength;
        CGFloat angle = [[angleArray objectAtIndex:section] floatValue];
        CGFloat x = _centerX + length*cos(angle);
        CGFloat y = _centerY + length*sin(angle);
        [_pointsToPlotArray addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        section++;
    }
    
    //label
    [self drawLabelWithMaxLength:maxLength labelArray:keyArray angleArray:angleArray];
    
}

#pragma mark - Helper Function
- (NSArray *)getAngleArrayFromNumberOfSection:(int)numberOfSection
{
    NSMutableArray *angleArray = [NSMutableArray array];
    for (int section = 0; section < numberOfSection; section++) {
        [angleArray addObject:[NSNumber numberWithFloat:(float)section/(float)[_valueDictionary count] * 2*M_PI]];
    }
    return angleArray;
}

- (NSArray *)getValueArrayFromDictionary:(NSDictionary *)dictionary keyArray:(NSArray *) keyArray
{
    NSMutableArray *valueArray = [NSMutableArray array];
    for (NSString *key in keyArray) {
        CGFloat value = [[dictionary objectForKey:key] floatValue];
        [valueArray addObject:[NSNumber numberWithFloat:value]];
    }
    return valueArray;
}

- (CGFloat)getMaxValueFromValueArray:(NSArray *)valueArray
{
    CGFloat maxValue = _maxValue;
    for (NSNumber *valueNumber in valueArray) {
        CGFloat valueFloat = [valueNumber floatValue];
        maxValue = valueFloat>maxValue?valueFloat:maxValue;
    }
    return ceilf(maxValue);
}

- (NSArray *)getLengthArrayWithLengthUnit:(CGFloat)lengthUnit maxLength:(CGFloat)maxLength
{
    NSMutableArray *lengthArray = [NSMutableArray array];
    for (CGFloat length = lengthUnit; length <= maxLength; length += lengthUnit) {
        [lengthArray addObject:[NSNumber numberWithFloat:length]];
    }
    return lengthArray;
}

- (NSArray *)getPlotPointWithLength:(CGFloat)length angleArray:(NSArray *)angleArray
{
    NSMutableArray *pointArray = [NSMutableArray array];
    //each length find the point
    for (NSNumber *angleNumber in angleArray) {
        CGFloat angle = [angleNumber floatValue];
        CGFloat x = _centerX + length*cos(angle);
        CGFloat y = _centerY + length*sin(angle);
        [pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
    //store
    return pointArray;
}

- (void)drawLabelWithMaxLength:(CGFloat)maxLength labelArray:(NSArray *)labelArray angleArray:(NSArray *)angleArray
{
    int labelTag = 921;
    while (true) {
        UIView *label = [self viewWithTag:labelTag];
        label.backgroundColor = [UIColor greenColor];
        if (!label) break;
        [label removeFromSuperview];
    }
    
    int section = 0;
    CGFloat fontSize = (maxLength/10)*5/4;
    
    CGFloat labelLength = maxLength + maxLength/10;
    for (NSString *labelString in labelArray) {
        CGFloat angle = [[angleArray objectAtIndex:section] floatValue];
        CGFloat x = _centerX + labelLength*cos(angle);
        CGFloat y = _centerY + labelLength*sin(angle);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x - 5*fontSize/2, y - fontSize/2, 5*fontSize, fontSize)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:fontSize];
    label.transform = CGAffineTransformMakeRotation(((float)section/[labelArray count]) *
                                           (2*M_PI) + M_PI_2);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = labelString;
        label.tag = labelTag;
        [label sizeToFit];
        [self addSubview: label];
        
        section++;
    }
}

#pragma mark - Animation: Contributed by Cdtschange - https://github.com/cdtschange
- (void)animateWithDuration:(NSTimeInterval)duration valueDictionary:(NSDictionary *)valueDictionary
{
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(reportProgress:)];
        _displayLink.frameInterval = 1/20.0;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    _targetValueDictionary = [NSMutableDictionary dictionaryWithDictionary:valueDictionary];
    long long times = duration*40;
    _displayLink.paused = YES;
    _animationStepValueDictionary  = [NSMutableDictionary new];
    NSArray *keyArray1 = [_valueDictionary allKeys];
    NSArray *valueArray1 = [self getValueArrayFromDictionary:_valueDictionary keyArray:keyArray1];
    NSArray *keyArray2 = [valueDictionary allKeys];
    NSArray *valueArray2 = [self getValueArrayFromDictionary:valueDictionary keyArray:keyArray2];
    if (keyArray1.count!=keyArray2.count) {
        return;
    }
    for (int i = 0; i < keyArray2.count; i++) {
        _animationStepValueDictionary [keyArray2[i]] = [NSString stringWithFormat:@"%f",([valueArray2[i] floatValue]-[valueArray1[i] floatValue])/times];
    }
    _displayLink.paused = NO;
}
- (void)reportProgress:(CADisplayLink *)dl
{
    NSArray *keyArray = [_valueDictionary allKeys];
    for (NSString *key in keyArray) {
        double delta = [_targetValueDictionary[key] floatValue] - [_valueDictionary[key] floatValue];
        double minusDelta =  [_animationStepValueDictionary [key] floatValue];
        if ((delta >= 0 && minusDelta <= 0) || (delta <= 0 && minusDelta >= 0)) {
            if ([self checkIsToTarget]) {
                _displayLink.paused = YES;
                _valueDictionary = _targetValueDictionary;
                [self calculateAllPoints];
                [self setNeedsDisplay];
                return;
            }else{
                continue;
            }
        }
        float value = [_valueDictionary[key] floatValue]+[_animationStepValueDictionary[key] floatValue];
        _valueDictionary[key] = [NSString stringWithFormat:@"%f",value];
    }
    [self calculateAllPoints];
    [self setNeedsDisplay];
}

- (BOOL)checkIsToTarget
{
    NSArray *keyArray = [_valueDictionary allKeys];
    for (NSString *key in keyArray) {
        double delta = [_targetValueDictionary[key] floatValue] - [_valueDictionary[key] floatValue];
        double minusDelta =  [_animationStepValueDictionary [key] floatValue];
        if ((delta > 0 && minusDelta > 0) || (delta < 0 && minusDelta < 0)) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - setters
- (void)setValueDivider:(CGFloat)valueDivider
{
    _valueDivider = valueDivider;
    [self calculateAllPoints];
    [self setNeedsDisplay];
}

- (void)setMaxValue:(CGFloat)maxValue
{
    _maxValue = maxValue;
    [self calculateAllPoints];
    [self setNeedsDisplay];
}

- (void)setDrawboardColor:(UIColor *)drawboardColor
{
    _drawboardColor = drawboardColor;
    [self calculateAllPoints];
    [self setNeedsDisplay];
}

- (void)setPlotColor:(UIColor *)plotColor
{
    _plotColor = plotColor;
    [self calculateAllPoints];
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_valueDictionary) {
        [self calculateAllPoints];
        [self setNeedsDisplay];
    }
    
}
@end

